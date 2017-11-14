package PPI::Future::Lexer;

=pod

=head1 NAME

PPI::Future::Lexer - The PPI::Future Lexer

=head1 SYNOPSIS

  use PPI::Future;
  
  # Create a new Lexer
  my $Lexer = PPI::Future::Lexer->new;
  
  # Build a PPI::Future::Document object from a Token stream
  my $Tokenizer = PPI::Future::Tokenizer->load('My/Module.pm');
  my $Document = $Lexer->lex_tokenizer($Tokenizer);
  
  # Build a PPI::Future::Document object for some raw source
  my $source = "print 'Hello World!'; kill(Humans->all);";
  $Document = $Lexer->lex_source($source);
  
  # Build a PPI::Future::Document object for a particular file name
  $Document = $Lexer->lex_file('My/Module.pm');

=head1 DESCRIPTION

The is the L<PPI::Future> Lexer. In the larger scheme of things, its job is to take
token streams, in a variety of forms, and "lex" them into nested structures.

Pretty much everything in this module happens behind the scenes at this
point. In fact, at the moment you don't really need to instantiate the lexer
at all, the three main methods will auto-instantiate themselves a
C<PPI::Future::Lexer> object as needed.

All methods do a one-shot "lex this and give me a L<PPI::Future::Document> object".

In fact, if you are reading this, what you B<probably> want to do is to
just "load a document", in which case you can do this in a much more
direct and concise manner with one of the following.

  use PPI::Future;
  
  $Document = PPI::Future::Document->load( $filename );
  $Document = PPI::Future::Document->new( $string );

See L<PPI::Future::Document> for more details.

For more unusual tasks, by all means forge onwards.

=head1 METHODS

=cut

use strict;
use Scalar::Util    ();
use Params::Util    qw{_STRING _INSTANCE};
use PPI::Future             ();
use PPI::Future::Exception  ();
use PPI::Future::Singletons '%_PARENT';

our $VERSION = '1.236';

our $errstr = "";

# Keyword -> Structure class maps
my %ROUND = (
	# Conditions
	'if'     => 'PPI::Future::Structure::Condition',
	'elsif'  => 'PPI::Future::Structure::Condition',
	'unless' => 'PPI::Future::Structure::Condition',
	'while'  => 'PPI::Future::Structure::Condition',
	'until'  => 'PPI::Future::Structure::Condition',

	# For(each)
	'for'     => 'PPI::Future::Structure::For',
	'foreach' => 'PPI::Future::Structure::For',
);

# Opening brace to refining method
my %RESOLVE = (
	'(' => '_round',
	'[' => '_square',
	'{' => '_curly',
);

# Allows for experimental overriding of the tokenizer
our $X_TOKENIZER = "PPI::Future::Tokenizer";
sub X_TOKENIZER { $X_TOKENIZER }





#####################################################################
# Constructor

=pod

=head2 new

The C<new> constructor creates a new C<PPI::Future::Lexer> object. The object itself
is merely used to hold various buffers and state data during the lexing
process, and holds no significant data between -E<gt>lex_xxxxx calls.

Returns a new C<PPI::Future::Lexer> object

=cut

sub new {
	my $class = shift->_clear;
	bless {
		Tokenizer => undef, # Where we store the tokenizer for a run
		buffer    => [],    # The input token buffer
		delayed   => [],    # The "delayed insignificant tokens" buffer
	}, $class;
}





#####################################################################
# Main Lexing Methods

=pod

=head2 lex_file $filename

The C<lex_file> method takes a filename as argument. It then loads the file,
creates a L<PPI::Future::Tokenizer> for the content and lexes the token stream
produced by the tokenizer. Basically, a sort of all-in-one method for
getting a L<PPI::Future::Document> object from a file name.

Returns a L<PPI::Future::Document> object, or C<undef> on error.

=cut

sub lex_file {
	my $self = ref $_[0] ? shift : shift->new;
	my $file = _STRING(shift);
	unless ( defined $file ) {
		return $self->_error("Did not pass a filename to PPI::Future::Lexer::lex_file");
	}

	# Create the Tokenizer
	my $Tokenizer = eval {
		X_TOKENIZER->new($file);
	};
	if ( _INSTANCE($@, 'PPI::Future::Exception') ) {
		return $self->_error( $@->message );
	} elsif ( $@ ) {
		return $self->_error( $errstr );
	}

	$self->lex_tokenizer( $Tokenizer );
}

=pod

=head2 lex_source $string

The C<lex_source> method takes a normal scalar string as argument. It
creates a L<PPI::Future::Tokenizer> object for the string, and then lexes the
resulting token stream.

Returns a L<PPI::Future::Document> object, or C<undef> on error.

=cut

sub lex_source {
	my $self   = ref $_[0] ? shift : shift->new;
	my $source = shift;
	unless ( defined $source and not ref $source ) {
		return $self->_error("Did not pass a string to PPI::Future::Lexer::lex_source");
	}

	# Create the Tokenizer and hand off to the next method
	my $Tokenizer = eval {
		X_TOKENIZER->new(\$source);
	};
	if ( _INSTANCE($@, 'PPI::Future::Exception') ) {
		return $self->_error( $@->message );
	} elsif ( $@ ) {
		return $self->_error( $errstr );
	}

	$self->lex_tokenizer( $Tokenizer );
}

=pod

=head2 lex_tokenizer $Tokenizer

The C<lex_tokenizer> takes as argument a L<PPI::Future::Tokenizer> object. It
lexes the token stream from the tokenizer into a L<PPI::Future::Document> object.

Returns a L<PPI::Future::Document> object, or C<undef> on error.

=cut

sub lex_tokenizer {
	my $self      = ref $_[0] ? shift : shift->new;
	my $Tokenizer = _INSTANCE(shift, 'PPI::Future::Tokenizer');
	return $self->_error(
		"Did not pass a PPI::Future::Tokenizer object to PPI::Future::Lexer::lex_tokenizer"
	) unless $Tokenizer;

	# Create the empty document
	my $Document = PPI::Future::Document->new;

	# Lex the token stream into the document
	$self->{Tokenizer} = $Tokenizer;
	if ( !eval { $self->_lex_document($Document); 1 } ) {
		# If an error occurs DESTROY the partially built document.
		undef $Document;
		if ( _INSTANCE($@, 'PPI::Future::Exception') ) {
			return $self->_error( $@->message );
		} else {
			return $self->_error( $errstr );
		}
	}

	return $Document;
}





#####################################################################
# Lex Methods - Document Object

sub _lex_document {
	my ($self, $Document) = @_;
	# my $self     = shift;
	# my $Document = _INSTANCE(shift, 'PPI::Future::Document') or return undef;

	# Start the processing loop
	my $Token;
	while ( ref($Token = $self->_get_token) ) {
		# Add insignificant tokens directly beneath us
		unless ( $Token->significant ) {
			$self->_add_element( $Document, $Token );
			next;
		}

		if ( $Token->content eq ';' ) {
			# It's a semi-colon on it's own.
			# We call this a null statement.
			$self->_add_element(
				$Document,
				PPI::Future::Statement::Null->new($Token),
			);
			next;
		}

		# Handle anything other than a structural element
		unless ( ref $Token eq 'PPI::Future::Token::Structure' ) {
			# Determine the class for the Statement, and create it
			my $Statement = $self->_statement($Document, $Token)->new($Token);

			# Move the lexing down into the statement
			$self->_add_delayed( $Document );
			$self->_add_element( $Document, $Statement );
			$self->_lex_statement( $Statement );

			next;
		}

		# Is this the opening of a structure?
		if ( $Token->__LEXER__opens ) {
			# This should actually have a Statement instead
			$self->_rollback( $Token );
			my $Statement = PPI::Future::Statement->new;
			$self->_add_element( $Document, $Statement );
			$self->_lex_statement( $Statement );
			next;
		}

		# Is this the close of a structure.
		if ( $Token->__LEXER__closes ) {
			# Because we are at the top of the tree, this is an error.
			# This means either a mis-parsing, or a mistake in the code.
			# To handle this, we create a "Naked Close" statement
			$self->_add_element( $Document,
				PPI::Future::Statement::UnmatchedBrace->new($Token)
			);
			next;
		}

		# Shouldn't be able to get here
		PPI::Future::Exception->throw('Lexer reached an illegal state');
	}

	# Did we leave the main loop because of a Tokenizer error?
	unless ( defined $Token ) {
		my $errstr = $self->{Tokenizer} ? $self->{Tokenizer}->errstr : '';
		$errstr ||= 'Unknown Tokenizer Error';
		PPI::Future::Exception->throw($errstr);
	}

	# No error, it's just the end of file.
	# Add any insignificant trailing tokens.
	$self->_add_delayed( $Document );

	# If the Tokenizer has any v6 blocks to attach, do so now.
	# Checking once at the end is faster than adding a special
	# case check for every statement parsed.
	my $perl6 = $self->{Tokenizer}->{'perl6'};
	if ( @$perl6 ) {
		my $includes = $Document->find( 'PPI::Future::Statement::Include::Perl6' );
		foreach my $include ( @$includes ) {
			unless ( @$perl6 ) {
				PPI::Future::Exception->throw('Failed to find a perl6 section');
			}
			$include->{perl6} = shift @$perl6;
		}
	}

	return 1;
}





#####################################################################
# Lex Methods - Statement Object

# Keyword -> Statement Subclass
my %STATEMENT_CLASSES = (
	# Things that affect the timing of execution
	'BEGIN'     => 'PPI::Future::Statement::Scheduled',
	'CHECK'     => 'PPI::Future::Statement::Scheduled',
	'UNITCHECK' => 'PPI::Future::Statement::Scheduled',
	'INIT'      => 'PPI::Future::Statement::Scheduled',
	'END'       => 'PPI::Future::Statement::Scheduled',

	# Special subroutines for which 'sub' is optional
	'AUTOLOAD'  => 'PPI::Future::Statement::Sub',
	'DESTROY'   => 'PPI::Future::Statement::Sub',

	# Loading and context statement
	'package'   => 'PPI::Future::Statement::Package',
	# 'use'       => 'PPI::Future::Statement::Include',
	'no'        => 'PPI::Future::Statement::Include',
	'require'   => 'PPI::Future::Statement::Include',

	# Various declarations
	'my'        => 'PPI::Future::Statement::Variable',
	'local'     => 'PPI::Future::Statement::Variable',
	'our'       => 'PPI::Future::Statement::Variable',
	'state'     => 'PPI::Future::Statement::Variable',
	# Statements starting with 'sub' could be any one of...
	# 'sub'     => 'PPI::Future::Statement::Sub',
	# 'sub'     => 'PPI::Future::Statement::Scheduled',
	# 'sub'     => 'PPI::Future::Statement',

	# Compound statement
	'if'        => 'PPI::Future::Statement::Compound',
	'unless'    => 'PPI::Future::Statement::Compound',
	'for'       => 'PPI::Future::Statement::Compound',
	'foreach'   => 'PPI::Future::Statement::Compound',
	'while'     => 'PPI::Future::Statement::Compound',
	'until'     => 'PPI::Future::Statement::Compound',

	# Switch statement
	'given'     => 'PPI::Future::Statement::Given',
	'when'      => 'PPI::Future::Statement::When',
	'default'   => 'PPI::Future::Statement::When',

	# Various ways of breaking out of scope
	'redo'      => 'PPI::Future::Statement::Break',
	'next'      => 'PPI::Future::Statement::Break',
	'last'      => 'PPI::Future::Statement::Break',
	'return'    => 'PPI::Future::Statement::Break',
	'goto'      => 'PPI::Future::Statement::Break',

	# Special sections of the file
	'__DATA__'  => 'PPI::Future::Statement::Data',
	'__END__'   => 'PPI::Future::Statement::End',
);

sub _statement {
	my ($self, $Parent, $Token) = @_;
	# my $self   = shift;
	# my $Parent = _INSTANCE(shift, 'PPI::Future::Node')  or die "Bad param 1";
	# my $Token  = _INSTANCE(shift, 'PPI::Future::Token') or die "Bad param 2";

	# Check for things like ( parent => ... )
	if (
		$Parent->isa('PPI::Future::Structure::List')
		or
		$Parent->isa('PPI::Future::Structure::Constructor')
	) {
		if ( $Token->isa('PPI::Future::Token::Word') ) {
			# Is the next significant token a =>
			# Read ahead to the next significant token
			my $Next;
			while ( $Next = $self->_get_token ) {
				unless ( $Next->significant ) {
					push @{$self->{delayed}}, $Next;
					# $self->_delay_element( $Next );
					next;
				}

				# Got the next token
				if (
					$Next->isa('PPI::Future::Token::Operator')
					and
					$Next->content eq '=>'
				) {
					# Is an ordinary expression
					$self->_rollback( $Next );
					return 'PPI::Future::Statement::Expression';
				} else {
					last;
				}
			}

			# Rollback and continue
			$self->_rollback( $Next );
		}
	}

	my $is_lexsub = 0;

	# Is it a token in our known classes list
	my $class = $STATEMENT_CLASSES{$Token->content};
	if ( $class ) {
		# Is the next significant token a =>
		# Read ahead to the next significant token
		my $Next;
		while ( $Next = $self->_get_token ) {
			if ( !$Next->significant ) {
				push @{$self->{delayed}}, $Next;
				next;
			}

			# Lexical subroutine
			if (
				$Token->content =~ /^(?:my|our|state)$/
				and $Next->isa( 'PPI::Token::Word' ) and $Next->content eq 'sub'
			) {
				# This should be PPI::Statement::Sub rather than PPI::Statement::Variable
				$class = undef;
				$is_lexsub = 1;
				last;
			}

			last if
				!$Next->isa( 'PPI::Future::Token::Operator' ) or $Next->content ne '=>';

			# Got the next token
			# Is an ordinary expression
			$self->_rollback( $Next );
			return 'PPI::Future::Statement';
		}

		# Rollback and continue
		$self->_rollback( $Next );
	}

	# Handle potential barewords for subscripts
	if ( $Parent->isa('PPI::Future::Structure::Subscript') ) {
		# Fast obvious case, just an expression
		unless ( $class and $class->isa('PPI::Future::Statement::Expression') ) {
			return 'PPI::Future::Statement::Expression';
		}

		# This is something like "my" or "our" etc... more subtle.
		# Check if the next token is a closing curly brace.
		# This means we are something like $h{my}
		my $Next;
		while ( $Next = $self->_get_token ) {
			unless ( $Next->significant ) {
				push @{$self->{delayed}}, $Next;
				# $self->_delay_element( $Next );
				next;
			}

			# Found the next significant token.
			# Is it a closing curly brace?
			if ( $Next->content eq '}' ) {
				$self->_rollback( $Next );
				return 'PPI::Future::Statement::Expression';
			} else {
				$self->_rollback( $Next );
				return $class;
			}
		}

		# End of file... this means it is something like $h{our
		# which is probably going to be $h{our} ... I think
		$self->_rollback( $Next );
		return 'PPI::Future::Statement::Expression';
	}

	# If it's a token in our list, use that class
	return $class if $class;

	# Handle the more in-depth sub detection
	if ( $is_lexsub || $Token->content eq 'sub' ) {
		# Read ahead to the next significant token
		my $Next;
		while ( $Next = $self->_get_token ) {
			unless ( $Next->significant ) {
				push @{$self->{delayed}}, $Next;
				# $self->_delay_element( $Next );
				next;
			}

			# Got the next significant token
			my $sclass = $STATEMENT_CLASSES{$Next->content};
			if ( $sclass and $sclass eq 'PPI::Future::Statement::Scheduled' ) {
				$self->_rollback( $Next );
				return 'PPI::Future::Statement::Scheduled';
			}
			if ( $Next->isa('PPI::Future::Token::Word') ) {
				$self->_rollback( $Next );
				return 'PPI::Future::Statement::Sub';
			}

			### Comment out these two, as they would return PPI::Future::Statement anyway
			# if ( $content eq '{' ) {
			#	Anonymous sub at start of statement
			#	return 'PPI::Future::Statement';
			# }
			#
			# if ( $Next->isa('PPI::Future::Token::Prototype') ) {
			#	Anonymous sub at start of statement
			#	return 'PPI::Future::Statement';
			# }

			# PPI::Future::Statement is the safest fall-through
			$self->_rollback( $Next );
			return 'PPI::Future::Statement';
		}

		# End of file... PPI::Future::Statement::Sub is the most likely
		$self->_rollback( $Next );
		return 'PPI::Future::Statement::Sub';
	}

	if ( $Token->content eq 'use' ) {
		# Add a special case for "use v6" lines.
		my $Next;
		while ( $Next = $self->_get_token ) {
			unless ( $Next->significant ) {
				push @{$self->{delayed}}, $Next;
				# $self->_delay_element( $Next );
				next;
			}

			# Found the next significant token.
			if (
				$Next->isa('PPI::Future::Token::Operator')
				and
				$Next->content eq '=>'
			) {
				# Is an ordinary expression
				$self->_rollback( $Next );
				return 'PPI::Future::Statement';
			# Is it a v6 use?
			} elsif ( $Next->content eq 'v6' ) {
				$self->_rollback( $Next );
				return 'PPI::Future::Statement::Include::Perl6';
			} else {
				$self->_rollback( $Next );
				return 'PPI::Future::Statement::Include';
			}
		}

		# End of file... this means it is an incomplete use
		# line, just treat it as a normal include.
		$self->_rollback( $Next );
		return 'PPI::Future::Statement::Include';
	}

	# If our parent is a Condition, we are an Expression
	if ( $Parent->isa('PPI::Future::Structure::Condition') ) {
		return 'PPI::Future::Statement::Expression';
	}

	# If our parent is a List, we are also an expression
	if ( $Parent->isa('PPI::Future::Structure::List') ) {
		return 'PPI::Future::Statement::Expression';
	}

	# Switch statements use expressions, as well.
	if (
		$Parent->isa('PPI::Future::Structure::Given')
		or
		$Parent->isa('PPI::Future::Structure::When')
	) {
		return 'PPI::Future::Statement::Expression';
	}

	if ( _INSTANCE($Token, 'PPI::Future::Token::Label') ) {
		return 'PPI::Future::Statement::Compound';
	}

	# Beyond that, I have no idea for the moment.
	# Just keep adding more conditions above this.
	return 'PPI::Future::Statement';
}

sub _lex_statement {
	my ($self, $Statement) = @_;
	# my $self      = shift;
	# my $Statement = _INSTANCE(shift, 'PPI::Future::Statement') or die "Bad param 1";

	# Handle some special statements
	if ( $Statement->isa('PPI::Future::Statement::End') ) {
		return $self->_lex_end( $Statement );
	}

	# Begin processing tokens
	my $Token;
	while ( ref( $Token = $self->_get_token ) ) {
		# Delay whitespace and comment tokens
		unless ( $Token->significant ) {
			push @{$self->{delayed}}, $Token;
			# $self->_delay_element( $Token );
			next;
		}

		# Structual closes, and __DATA__ and __END__ tags implicitly
		# end every type of statement
		if (
			$Token->__LEXER__closes
			or
			$Token->isa('PPI::Future::Token::Separator')
		) {
			# Rollback and end the statement
			return $self->_rollback( $Token );
		}

		# Normal statements never implicitly end
		unless ( $Statement->__LEXER__normal ) {
			# Have we hit an implicit end to the statement
			unless ( $self->_continues( $Statement, $Token ) ) {
				# Rollback and finish the statement
				return $self->_rollback( $Token );
			}
		}

		# Any normal character just gets added
		unless ( $Token->isa('PPI::Future::Token::Structure') ) {
			$self->_add_element( $Statement, $Token );
			next;
		}

		# Handle normal statement terminators
		if ( $Token->content eq ';' ) {
			$self->_add_element( $Statement, $Token );
			return 1;
		}

		# Which leaves us with a new structure

		# Determine the class for the structure and create it
		my $method    = $RESOLVE{$Token->content};
		my $Structure = $self->$method($Statement)->new($Token);

		# Move the lexing down into the Structure
		$self->_add_delayed( $Statement );
		$self->_add_element( $Statement, $Structure );
		$self->_lex_structure( $Structure );
	}

	# Was it an error in the tokenizer?
	unless ( defined $Token ) {
		PPI::Future::Exception->throw;
	}

	# No, it's just the end of the file...
	# Roll back any insignificant tokens, they'll get added at the Document level
	$self->_rollback;
}

sub _lex_end {
	my ($self, $Statement) = @_;
	# my $self      = shift;
	# my $Statement = _INSTANCE(shift, 'PPI::Future::Statement::End') or die "Bad param 1";

	# End of the file, EVERYTHING is ours
	my $Token;
	while ( $Token = $self->_get_token ) {
		# Inlined $Statement->__add_element($Token);
		Scalar::Util::weaken(
			$_PARENT{Scalar::Util::refaddr $Token} = $Statement
		);
		push @{$Statement->{children}}, $Token;
	}

	# Was it an error in the tokenizer?
	unless ( defined $Token ) {
		PPI::Future::Exception->throw;
	}

	# No, it's just the end of the file...
	# Roll back any insignificant tokens, they get added at the Document level
	$self->_rollback;
}

# For many statements, it can be difficult to determine the end-point.
# This method takes a statement and the next significant token, and attempts
# to determine if the there is a statement boundary between the two, or if
# the statement can continue with the token.
sub _continues {
	my ($self, $Statement, $Token) = @_;
	# my $self      = shift;
	# my $Statement = _INSTANCE(shift, 'PPI::Future::Statement') or die "Bad param 1";
	# my $Token     = _INSTANCE(shift, 'PPI::Future::Token')     or die "Bad param 2";

	# Handle the simple block case
	# { print 1; }
	if (
		$Statement->schildren == 1
		and
		$Statement->schild(0)->isa('PPI::Future::Structure::Block')
	) {
		return '';
	}

	# Alrighty then, there are six implied-end statement types:
	# ::Scheduled blocks, ::Sub declarations, ::Compound, ::Given, ::When,
	# and ::Package statements.
	return 1
		if ref $Statement !~ /\b(?:Scheduled|Sub|Compound|Given|When|Package)$/;

	# Of these six, ::Scheduled, ::Sub, ::Given, and ::When follow the same
	# simple rule and can be handled first.  The block form of ::Package
	# follows the rule, too.  (The non-block form of ::Package
	# requires a statement terminator, and thus doesn't need to have
	# an implied end detected.)
	my @part      = $Statement->schildren;
	my $LastChild = $part[-1];
	# If the last significant element of the statement is a block,
	# then an implied-end statement is done, no questions asked.
	return !$LastChild->isa('PPI::Future::Structure::Block')
		if !$Statement->isa('PPI::Future::Statement::Compound');

	# Now we get to compound statements, which kind of suck (to lex).
	# However, of them all, the 'if' type, which includes unless, are
	# relatively easy to handle compared to the others.
	my $type = $Statement->type;
	if ( $type eq 'if' ) {
		# This should be one of the following
		# if (EXPR) BLOCK
		# if (EXPR) BLOCK else BLOCK
		# if (EXPR) BLOCK elsif (EXPR) BLOCK ... else BLOCK

		# We only implicitly end on a block
		unless ( $LastChild->isa('PPI::Future::Structure::Block') ) {
			# if (EXPR) ...
			# if (EXPR) BLOCK else ...
			# if (EXPR) BLOCK elsif (EXPR) BLOCK ...
			return 1;
		}

		# If the token before the block is an 'else',
		# it's over, no matter what.
		my $NextLast = $Statement->schild(-2);
		if (
			$NextLast
			and
			$NextLast->isa('PPI::Future::Token')
			and
			$NextLast->isa('PPI::Future::Token::Word')
			and
			$NextLast->content eq 'else'
		) {
			return '';
		}

		# Otherwise, we continue for 'elsif' or 'else' only.
		if (
			$Token->isa('PPI::Future::Token::Word')
			and (
				$Token->content eq 'else'
				or
				$Token->content eq 'elsif'
			)
		) {
			return 1;
		}

		return '';
	}

	if ( $type eq 'label' ) {
		# We only have the label so far, could be any of
		# LABEL while (EXPR) BLOCK
		# LABEL while (EXPR) BLOCK continue BLOCK
		# LABEL for (EXPR; EXPR; EXPR) BLOCK
		# LABEL foreach VAR (LIST) BLOCK
		# LABEL foreach VAR (LIST) BLOCK continue BLOCK
		# LABEL BLOCK continue BLOCK

		# Handle cases with a word after the label
		if (
			$Token->isa('PPI::Future::Token::Word')
			and
			$Token->content =~ /^(?:while|until|for|foreach)$/
		) {
			return 1;
		}

		# Handle labelled blocks
		if ( $Token->isa('PPI::Future::Token::Structure') && $Token->content eq '{' ) {
			return 1;
		}

		return '';
	}

	# Handle the common "after round braces" case
	if ( $LastChild->isa('PPI::Future::Structure') and $LastChild->braces eq '()' ) {
		# LABEL while (EXPR) ...
		# LABEL while (EXPR) ...
		# LABEL for (EXPR; EXPR; EXPR) ...
		# LABEL for VAR (LIST) ...
		# LABEL foreach VAR (LIST) ...
		# Only a block will do
		return $Token->isa('PPI::Future::Token::Structure') && $Token->content eq '{';
	}

	if ( $type eq 'for' ) {
		# LABEL for (EXPR; EXPR; EXPR) BLOCK
		if (
			$LastChild->isa('PPI::Future::Token::Word')
			and
			$LastChild->content =~ /^for(?:each)?\z/
		) {
			# LABEL for ...
			if (
				(
					$Token->isa('PPI::Future::Token::Structure')
					and
					$Token->content eq '('
				)
				or
				$Token->isa('PPI::Future::Token::QuoteLike::Words')
			) {
				return 1;
			}

			if ( $LastChild->isa('PPI::Future::Token::QuoteLike::Words') ) {
				# LABEL for VAR QW{} ...
				# LABEL foreach VAR QW{} ...
				# Only a block will do
				return $Token->isa('PPI::Future::Token::Structure') && $Token->content eq '{';
			}

			# In this case, we can also behave like a foreach
			$type = 'foreach';

		} elsif ( $LastChild->isa('PPI::Future::Structure::Block') ) {
			# LABEL for (EXPR; EXPR; EXPR) BLOCK
			# That's it, nothing can continue
			return '';

		} elsif ( $LastChild->isa('PPI::Future::Token::QuoteLike::Words') ) {
			# LABEL for VAR QW{} ...
			# LABEL foreach VAR QW{} ...
			# Only a block will do
			return $Token->isa('PPI::Future::Token::Structure') && $Token->content eq '{';
		}
	}

	# Handle the common continue case
	if ( $LastChild->isa('PPI::Future::Token::Word') and $LastChild->content eq 'continue' ) {
		# LABEL while (EXPR) BLOCK continue ...
		# LABEL foreach VAR (LIST) BLOCK continue ...
		# LABEL BLOCK continue ...
		# Only a block will do
		return $Token->isa('PPI::Future::Token::Structure') && $Token->content eq '{';
	}

	# Handle the common continuable block case
	if ( $LastChild->isa('PPI::Future::Structure::Block') ) {
		# LABEL while (EXPR) BLOCK
		# LABEL while (EXPR) BLOCK ...
		# LABEL for (EXPR; EXPR; EXPR) BLOCK
		# LABEL foreach VAR (LIST) BLOCK
		# LABEL foreach VAR (LIST) BLOCK ...
		# LABEL BLOCK ...
		# Is this the block for a continue?
		if ( _INSTANCE($part[-2], 'PPI::Future::Token::Word') and $part[-2]->content eq 'continue' ) {
			# LABEL while (EXPR) BLOCK continue BLOCK
			# LABEL foreach VAR (LIST) BLOCK continue BLOCK
			# LABEL BLOCK continue BLOCK
			# That's it, nothing can continue this
			return '';
		}

		# Only a continue will do
		return $Token->isa('PPI::Future::Token::Word') && $Token->content eq 'continue';
	}

	if ( $type eq 'block' ) {
		# LABEL BLOCK continue BLOCK
		# Every possible case is covered in the common cases above
	}

	if ( $type eq 'while' ) {
		# LABEL while (EXPR) BLOCK
		# LABEL while (EXPR) BLOCK continue BLOCK
		# LABEL until (EXPR) BLOCK
		# LABEL until (EXPR) BLOCK continue BLOCK
		# The only case not covered is the while ...
		if (
			$LastChild->isa('PPI::Future::Token::Word')
			and (
				$LastChild->content eq 'while'
				or
				$LastChild->content eq 'until'
			)
		) {
			# LABEL while ...
			# LABEL until ...
			# Only a condition structure will do
			return $Token->isa('PPI::Future::Token::Structure') && $Token->content eq '(';
		}
	}

	if ( $type eq 'foreach' ) {
		# LABEL foreach VAR (LIST) BLOCK
		# LABEL foreach VAR (LIST) BLOCK continue BLOCK
		# The only two cases that have not been covered already are
		# 'foreach ...' and 'foreach VAR ...'

		if ( $LastChild->isa('PPI::Future::Token::Symbol') ) {
			# LABEL foreach my $scalar ...
			# Open round brace, or a quotewords
			return 1 if $Token->isa('PPI::Future::Token::Structure') && $Token->content eq '(';
			return 1 if $Token->isa('PPI::Future::Token::QuoteLike::Words');
			return '';
		}

		if ( $LastChild->content eq 'foreach' or $LastChild->content eq 'for' ) {
			# There are three possibilities here
			if (
				$Token->isa('PPI::Future::Token::Word')
				and (
					($STATEMENT_CLASSES{ $Token->content } || '')
					eq
					'PPI::Future::Statement::Variable'
				)
			) {
				# VAR == 'my ...'
				return 1;
			} elsif ( $Token->content =~ /^\$/ ) {
				# VAR == '$scalar'
				return 1;
			} elsif ( $Token->isa('PPI::Future::Token::Structure') and $Token->content eq '(' ) {
				return 1;
			} elsif ( $Token->isa('PPI::Future::Token::QuoteLike::Words') ) {
				return 1;
			} else {
				return '';
			}
		}

		if (
			($STATEMENT_CLASSES{ $LastChild->content } || '')
			eq
			'PPI::Future::Statement::Variable'
		) {
			# LABEL foreach my ...
			# Only a scalar will do
			return $Token->content =~ /^\$/;
		}

		# Handle the rare for my $foo qw{bar} ... case
		if ( $LastChild->isa('PPI::Future::Token::QuoteLike::Words') ) {
			# LABEL for VAR QW ...
			# LABEL foreach VAR QW ...
			# Only a block will do
			return $Token->isa('PPI::Future::Token::Structure') && $Token->content eq '{';
		}
	}

	# Something we don't know about... what could it be
	PPI::Future::Exception->throw("Illegal state in '$type' compound statement");
}





#####################################################################
# Lex Methods - Structure Object

# Given a parent element, and a ( token to open a structure, determine
# the class that the structure should be.
sub _round {
	my ($self, $Parent) = @_;
	# my $self   = shift;
	# my $Parent = _INSTANCE(shift, 'PPI::Future::Node') or die "Bad param 1";

	# Get the last significant element in the parent
	my $Element = $Parent->schild(-1);
	if ( _INSTANCE($Element, 'PPI::Future::Token::Word') ) {
		# Can it be determined because it is a keyword?
		my $rclass = $ROUND{$Element->content};
		return $rclass if $rclass;
	}

	# If we are part of a for or foreach statement, we are a ForLoop
	if ( $Parent->isa('PPI::Future::Statement::Compound') ) {
		if ( $Parent->type =~ /^for(?:each)?$/ ) {
			return 'PPI::Future::Structure::For';
		}
	} elsif ( $Parent->isa('PPI::Future::Statement::Given') ) {
		return 'PPI::Future::Structure::Given';
	} elsif ( $Parent->isa('PPI::Future::Statement::When') ) {
		return 'PPI::Future::Structure::When';
	}

	# Otherwise, it must be a list

	# If the previous element is -> then we mark it as a dereference
	if ( _INSTANCE($Element, 'PPI::Future::Token::Operator') and $Element->content eq '->' ) {
		$Element->{_dereference} = 1;
	}

	'PPI::Future::Structure::List'
}

# Given a parent element, and a [ token to open a structure, determine
# the class that the structure should be.
sub _square {
	my ($self, $Parent) = @_;
	# my $self   = shift;
	# my $Parent = _INSTANCE(shift, 'PPI::Future::Node') or die "Bad param 1";

	# Get the last significant element in the parent
	my $Element = $Parent->schild(-1);

	# Is this a subscript, like $foo[1] or $foo{expr}
	
	if ( $Element ) {
		if ( $Element->isa('PPI::Future::Token::Operator') and $Element->content eq '->' ) {
			# $foo->[]
			$Element->{_dereference} = 1;
			return 'PPI::Future::Structure::Subscript';
		}
		if ( $Element->isa('PPI::Future::Structure::Subscript') ) {
			# $foo{}[]
			return 'PPI::Future::Structure::Subscript';
		}
		if ( $Element->isa('PPI::Future::Token::Symbol') and $Element->content =~ /^(?:\$|\@)/ ) {
			# $foo[], @foo[]
			return 'PPI::Future::Structure::Subscript';
		}
		if ( $Element->isa('PPI::Future::Token::Cast') and $Element->content =~ /^(?:\@|\%)/ ) {
			my $prior = $Parent->schild(-2);
			if ( $prior and $prior->isa('PPI::Future::Token::Operator') and $prior->content eq '->' ) {
				# Postfix dereference: ->@[...] ->%[...]
				return 'PPI::Future::Structure::Subscript';
			}
		}
		# FIXME - More cases to catch
	}

	# Otherwise, we assume that it's an anonymous arrayref constructor
	'PPI::Future::Structure::Constructor';
}

# Keyword -> Structure class maps
my %CURLY_CLASSES = (
	# Blocks
	'sub'  => 'PPI::Future::Structure::Block',
	'grep' => 'PPI::Future::Structure::Block',
	'map'  => 'PPI::Future::Structure::Block',
	'sort' => 'PPI::Future::Structure::Block',
	'do'   => 'PPI::Future::Structure::Block',
	# rely on 'continue' + block being handled elsewhere
	# rely on 'eval' + block being handled elsewhere

	# Hash constructors
	'scalar' => 'PPI::Future::Structure::Constructor',
	'='      => 'PPI::Future::Structure::Constructor',
	'||='    => 'PPI::Future::Structure::Constructor',
	'&&='    => 'PPI::Future::Structure::Constructor',
	'//='    => 'PPI::Future::Structure::Constructor',
	'||'     => 'PPI::Future::Structure::Constructor',
	'&&'     => 'PPI::Future::Structure::Constructor',
	'//'     => 'PPI::Future::Structure::Constructor',
	'?'      => 'PPI::Future::Structure::Constructor',
	':'      => 'PPI::Future::Structure::Constructor',
	','      => 'PPI::Future::Structure::Constructor',
	'=>'     => 'PPI::Future::Structure::Constructor',
	'+'      => 'PPI::Future::Structure::Constructor', # per perlref
	'return' => 'PPI::Future::Structure::Constructor', # per perlref
	'bless'  => 'PPI::Future::Structure::Constructor', # pragmatic --
				# perlfunc says first arg is a reference, and
			# bless {; ... } fails to compile.
);

my @CURLY_LOOKAHEAD_CLASSES = (
	{},	# not used
	{
	';'    => 'PPI::Future::Structure::Block', # per perlref
	'}'    => 'PPI::Future::Structure::Constructor',
	},
	{
	'=>'   => 'PPI::Future::Structure::Constructor',
	},
);


# Given a parent element, and a { token to open a structure, determine
# the class that the structure should be.
sub _curly {
	my ($self, $Parent) = @_;
	# my $self   = shift;
	# my $Parent = _INSTANCE(shift, 'PPI::Future::Node') or die "Bad param 1";

	# Get the last significant element in the parent
	my $Element = $Parent->schild(-1);
	my $content = $Element ? $Element->content : '';

	# Is this a subscript, like $foo[1] or $foo{expr}
	if ( $Element ) {
		if ( $content eq '->' and $Element->isa('PPI::Future::Token::Operator') ) {
			# $foo->{}
			$Element->{_dereference} = 1;
			return 'PPI::Future::Structure::Subscript';
		}
		if ( $Element->isa('PPI::Future::Structure::Subscript') ) {
			# $foo[]{}
			return 'PPI::Future::Structure::Subscript';
		}
		if ( $content =~ /^(?:\$|\@)/ and $Element->isa('PPI::Future::Token::Symbol') ) {
			# $foo{}, @foo{}
			return 'PPI::Future::Structure::Subscript';
		}
		if ( $Element->isa('PPI::Future::Token::Cast') and $Element->content =~ /^(?:\@|\%|\*)/ ) {
			my $prior = $Parent->schild(-2);
			if ( $prior and $prior->isa('PPI::Future::Token::Operator') and $prior->content eq '->' ) {
				# Postfix dereference: ->@{...} ->%{...} ->*{...}
				return 'PPI::Future::Structure::Subscript';
			}
		}
		if ( $Element->isa('PPI::Future::Structure::Block') ) {
			# deference - ${$hash_ref}{foo}
			#     or even ${burfle}{foo}
			# hash slice - @{$hash_ref}{'foo', 'bar'}
			if ( my $prior = $Parent->schild(-2) ) {
				my $prior_content = $prior->content();
				$prior->isa( 'PPI::Future::Token::Cast' )
					and ( $prior_content eq '@' ||
						$prior_content eq '$' )
					and return 'PPI::Future::Structure::Subscript';
			}
		}

		# Are we the last argument of sub?
		# E.g.: 'sub foo {}', 'sub foo ($) {}'
		return 'PPI::Future::Structure::Block' if $Parent->isa('PPI::Future::Statement::Sub');

		# Are we the second or third argument of package?
		# E.g.: 'package Foo {}' or 'package Foo v1.2.3 {}'
		return 'PPI::Future::Structure::Block'
			if $Parent->isa('PPI::Future::Statement::Package');

		if ( $CURLY_CLASSES{$content} ) {
			# Known type
			return $CURLY_CLASSES{$content};
		}
	}

	# Are we in a compound statement
	if ( $Parent->isa('PPI::Future::Statement::Compound') ) {
		# We will only encounter blocks in compound statements
		return 'PPI::Future::Structure::Block';
	}

	# Are we the second or third argument of use
	if ( $Parent->isa('PPI::Future::Statement::Include') ) {
		if ( $Parent->schildren == 2 ||
		    $Parent->schildren == 3 &&
			$Parent->schild(2)->isa('PPI::Future::Token::Number')
		) {
			# This is something like use constant { ... };
			return 'PPI::Future::Structure::Constructor';
		}
	}

	# Unless we are at the start of the statement, everything else should be a block
	### FIXME This is possibly a bad choice, but will have to do for now.
	return 'PPI::Future::Structure::Block' if $Element;

	# Special case: Are we the param of a core function
	# i.e. map({ $_ => 1 } @foo)
	if (
		$Parent->isa('PPI::Future::Statement')
		and
		_INSTANCE($Parent->parent, 'PPI::Future::Structure::List')
	) {
		my $function = $Parent->parent->parent->schild(-2);
		if ( $function and $function->content =~ /^(?:map|grep|sort)$/ ) {
			return 'PPI::Future::Structure::Block';
		}
	}

	# We need to scan ahead.
	my $Next;
	my $position = 0;
	my @delayed;
	while ( $Next = $self->_get_token ) {
		unless ( $Next->significant ) {
			push @delayed, $Next;
			next;
		}

		# If we are off the end of the lookahead array,
		if ( ++$position >= @CURLY_LOOKAHEAD_CLASSES ) {
			# default to block.
			$self->_buffer( splice(@delayed), $Next );
			last;
		# If the content at this position is known
		} elsif ( my $class = $CURLY_LOOKAHEAD_CLASSES[$position]
			{$Next->content} ) {
			# return the associated class.
			$self->_buffer( splice(@delayed), $Next );
			return $class;
		}

		# Delay and continue
		push @delayed, $Next;
	}

	# Hit the end of the document, or bailed out, go with block
	$self->_buffer( splice(@delayed) );
	if ( ref $Parent eq 'PPI::Future::Statement' ) {
		bless $Parent, 'PPI::Future::Statement::Compound';
	}
	return 'PPI::Future::Structure::Block';
}


sub _lex_structure {
	my ($self, $Structure) = @_;
	# my $self      = shift;
	# my $Structure = _INSTANCE(shift, 'PPI::Future::Structure') or die "Bad param 1";

	# Start the processing loop
	my $Token;
	while ( ref($Token = $self->_get_token) ) {
		# Is this a direct type token
		unless ( $Token->significant ) {
			push @{$self->{delayed}}, $Token;
			# $self->_delay_element( $Token );
			next;
		}

		# Anything other than a Structure starts a Statement
		unless ( $Token->isa('PPI::Future::Token::Structure') ) {
			# Because _statement may well delay and rollback itself,
			# we need to add the delayed tokens early
			$self->_add_delayed( $Structure );

			# Determine the class for the Statement and create it
			my $Statement = $self->_statement($Structure, $Token)->new($Token);

			# Move the lexing down into the Statement
			$self->_add_element( $Structure, $Statement );
			$self->_lex_statement( $Statement );

			next;
		}

		# Is this the opening of another structure directly inside us?
		if ( $Token->__LEXER__opens ) {
			# Rollback the Token, and recurse into the statement
			$self->_rollback( $Token );
			my $Statement = PPI::Future::Statement->new;
			$self->_add_element( $Structure, $Statement );
			$self->_lex_statement( $Statement );
			next;
		}

		# Is this the close of a structure ( which would be an error )
		if ( $Token->__LEXER__closes ) {
			# Is this OUR closing structure
			if ( $Token->content eq $Structure->start->__LEXER__opposite ) {
				# Add any delayed tokens, and the finishing token (the ugly way)
				$self->_add_delayed( $Structure );
				$Structure->{finish} = $Token;
				Scalar::Util::weaken(
					$_PARENT{Scalar::Util::refaddr $Token} = $Structure
				);

				# Confirm that ForLoop structures are actually so, and
				# aren't really a list.
				if ( $Structure->isa('PPI::Future::Structure::For') ) {
					if ( 2 > scalar grep {
						$_->isa('PPI::Future::Statement')
					} $Structure->children ) {
						bless($Structure, 'PPI::Future::Structure::List');
					}
				}
				return 1;
			}

			# Unmatched closing brace.
			# Either they typed the wrong thing, or haven't put
			# one at all. Either way it's an error we need to
			# somehow handle gracefully. For now, we'll treat it
			# as implicitly ending the structure. This causes the
			# least damage across the various reasons why this
			# might have happened.
			return $self->_rollback( $Token );
		}

		# It's a semi-colon on it's own, just inside the block.
		# This is a null statement.
		$self->_add_element(
			$Structure,
			PPI::Future::Statement::Null->new($Token),
		);
	}

	# Is this an error
	unless ( defined $Token ) {
		PPI::Future::Exception->throw;
	}

	# No, it's just the end of file.
	# Add any insignificant trailing tokens.
	$self->_add_delayed( $Structure );
}





#####################################################################
# Support Methods

# Get the next token for processing, handling buffering
sub _get_token {
	shift(@{$_[0]->{buffer}}) or $_[0]->{Tokenizer}->get_token;
}

# Old long version of the above
# my $self = shift;
#     # First from the buffer
#     if ( @{$self->{buffer}} ) {
#         return shift @{$self->{buffer}};
#     }
#
#     # Then from the Tokenizer
#     $self->{Tokenizer}->get_token;
# }

# Delay the addition of insignificant elements.
# This ended up being inlined.
# sub _delay_element {
#     my $self    = shift;
#     my $Element = _INSTANCE(shift, 'PPI::Future::Element') or die "Bad param 1";
#     push @{ $_[0]->{delayed} }, $_[1];
# }

# Add an Element to a Node, including any delayed Elements
sub _add_element {
	my ($self, $Parent, $Element) = @_;
	# my $self    = shift;
	# my $Parent  = _INSTANCE(shift, 'PPI::Future::Node')    or die "Bad param 1";
	# my $Element = _INSTANCE(shift, 'PPI::Future::Element') or die "Bad param 2";

	# Handle a special case, where a statement is not fully resolved
	if ( ref $Parent eq 'PPI::Future::Statement'
		   and my $first = $Parent->schild(0) ) {
		if ( $first->isa('PPI::Future::Token::Label')
			   and !(my $second = $Parent->schild(1)) ) {
			my $new_class = $STATEMENT_CLASSES{$second->content};
			# It's a labelled statement
			bless $Parent, $new_class if $new_class;
		}
	}

	# Add first the delayed, from the front, then the passed element
	foreach my $el ( @{$self->{delayed}} ) {
		Scalar::Util::weaken(
			$_PARENT{Scalar::Util::refaddr $el} = $Parent
		);
		# Inlined $Parent->__add_element($el);
	}
	Scalar::Util::weaken(
		$_PARENT{Scalar::Util::refaddr $Element} = $Parent
	);
	push @{$Parent->{children}}, @{$self->{delayed}}, $Element;

	# Clear the delayed elements
	$self->{delayed} = [];
}

# Specifically just add any delayed tokens, if any.
sub _add_delayed {
	my ($self, $Parent) = @_;
	# my $self   = shift;
	# my $Parent = _INSTANCE(shift, 'PPI::Future::Node') or die "Bad param 1";

	# Add any delayed
	foreach my $el ( @{$self->{delayed}} ) {
		Scalar::Util::weaken(
			$_PARENT{Scalar::Util::refaddr $el} = $Parent
		);
		# Inlined $Parent->__add_element($el);
	}
	push @{$Parent->{children}}, @{$self->{delayed}};

	# Clear the delayed elements
	$self->{delayed} = [];
}

# Rollback the delayed tokens, plus any passed. Once all the tokens
# have been moved back on to the buffer, the order should be.
# <--- @{$self->{delayed}}, @_, @{$self->{buffer}} <----
sub _rollback {
	my $self = shift;

	# First, put any passed objects back
	if ( @_ ) {
		unshift @{$self->{buffer}}, splice @_;
	}

	# Then, put back anything delayed
	if ( @{$self->{delayed}} ) {
		unshift @{$self->{buffer}}, splice @{$self->{delayed}};
	}

	1;
}

# Partial rollback, just return a single list to the buffer
sub _buffer {
	my $self = shift;

	# Put any passed objects back
	if ( @_ ) {
		unshift @{$self->{buffer}}, splice @_;
	}

	1;
}





#####################################################################
# Error Handling

# Set the error message
sub _error {
	$errstr = $_[1];
	undef;
}

# Clear the error message.
# Returns the object as a convenience.
sub _clear {
	$errstr = '';
	$_[0];
}

=pod

=head2 errstr

For any error that occurs, you can use the C<errstr>, as either
a static or object method, to access the error message.

If no error occurs for any particular action, C<errstr> will return false.

=cut

sub errstr {
	$errstr;
}





#####################################################################
# PDOM Extensions
#
# This is something of a future expansion... ignore it for now :)
#
# use PPI::Future::Statement::Sub ();
#
# sub PPI::Future::Statement::Sub::__LEXER__normal { '' }

1;

=pod

=head1 TO DO

- Add optional support for some of the more common source filters

- Some additional checks for blessing things into various Statement
and Structure subclasses.

=head1 SUPPORT

See the L<support section|PPI::Future/SUPPORT> in the main module.

=head1 AUTHOR

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2001 - 2011 Adam Kennedy.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
