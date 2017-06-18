package PPI::Future::Statement;

=pod

=head1 NAME

PPI::Future::Statement - The base class for Perl statements

=head1 INHERITANCE

  PPI::Future::Statement
  isa PPI::Future::Node
      isa PPI::Future::Element

=head1 DESCRIPTION

PPI::Future::Statement is the root class for all Perl statements. This includes (from
L<perlsyn>) "Declarations", "Simple Statements" and "Compound Statements".

The class PPI::Future::Statement itself represents a "Simple Statement" as defined
in the L<perlsyn> manpage.

=head1 STATEMENT CLASSES

Please note that unless documented themselves, these classes are yet to be
frozen/finalised. Names may change slightly or be added or removed.

=head2 L<PPI::Future::Statement::Scheduled>

This covers all "scheduled" blocks, chunks of code that are executed separately
from the main body of the code, at a particular time. This includes all
C<BEGIN>, C<CHECK>, C<UNITCHECK>, C<INIT> and C<END> blocks.

=head2 L<PPI::Future::Statement::Package>

A package declaration, as defined in L<perlfunc|perlfunc/package>.

=head2 L<PPI::Future::Statement::Include>

A statement that loads or unloads another module.

This includes 'use', 'no', and 'require' statements.

=head2 L<PPI::Future::Statement::Sub>

A named subroutine declaration, or forward declaration

=head2 L<PPI::Future::Statement::Variable>

A variable declaration statement. This could be either a straight
declaration or also be an expression.

This includes all 'my', 'state', 'local' and 'our' statements.

=head2 L<PPI::Future::Statement::Compound>

This covers the whole family of 'compound' statements, as described in
L<perlsyn|perlsyn>.

This includes all statements starting with 'if', 'unless', 'for', 'foreach'
and 'while'. Note that this does NOT include 'do', as it is treated
differently.

All compound statements have implicit ends. That is, they do not end with
a ';' statement terminator.

=head2 L<PPI::Future::Statement::Break>

A statement that breaks out of a structure.

This includes all of 'redo', 'goto', 'next', 'last' and 'return' statements.

=head2 L<PPI::Future::Statement::Given>

The kind of statement introduced in Perl 5.10 that starts with 'given'.  This
has an implicit end.

=head2 L<PPI::Future::Statement::When>

The kind of statement introduced in Perl 5.10 that starts with 'when' or
'default'.  This also has an implicit end.

=head2 L<PPI::Future::Statement::Data>

A special statement which encompasses an entire C<__DATA__> block, including
the initial C<'__DATA__'> token itself and the entire contents.

=head2 L<PPI::Future::Statement::End>

A special statement which encompasses an entire __END__ block, including
the initial '__END__' token itself and the entire contents, including any
parsed PPI::Future::Token::POD that may occur in it.

=head2 L<PPI::Future::Statement::Expression>

L<PPI::Future::Statement::Expression> is a little more speculative, and is intended
to help represent the special rules relating to "expressions" such as in:

  # Several examples of expression statements
  
  # Boolean conditions
  if ( expression ) { ... }
  
  # Lists, such as for arguments
  Foo->bar( expression )

=head2 L<PPI::Future::Statement::Null>

A null statement is a special case for where we encounter two consecutive
statement terminators. ( ;; )

The second terminator is given an entire statement of its own, but one
that serves no purpose. Hence a 'null' statement.

Theoretically, assuming a correct parsing of a perl file, all null statements
are superfluous and should be able to be removed without damage to the file.

But don't do that, in case PPI::Future has parsed something wrong.

=head2 L<PPI::Future::Statement::UnmatchedBrace>

Because L<PPI::Future> is intended for use when parsing incorrect or incomplete code,
the problem arises of what to do with a stray closing brace.

Rather than die, it is allocated its own "unmatched brace" statement,
which really means "unmatched closing brace". An unmatched open brace at the
end of a file would become a structure with no contents and no closing brace.

If the document loaded is intended to be correct and valid, finding a
L<PPI::Future::Statement::UnmatchedBrace> in the PDOM is generally indicative of a
misparse.

=head2 L<PPI::Future::Statement::Unknown>

This is used temporarily mid-parsing to hold statements for which the lexer
cannot yet determine what class it should be, usually because there are
insufficient clues, or it might be more than one thing.

You should never encounter these in a fully parsed PDOM tree.

=head1 METHODS

C<PPI::Future::Statement> itself has very few methods. Most of the time, you will be
working with the more generic L<PPI::Future::Element> or L<PPI::Future::Node> methods, or one
of the methods that are subclass-specific.

=cut

use strict;
use Scalar::Util   ();
use Params::Util   qw{_INSTANCE};
use PPI::Future::Node      ();
use PPI::Future::Exception ();
use PPI::Future::Singletons '%_PARENT';

our $VERSION = '1.236';

our @ISA = "PPI::Future::Node";

use PPI::Future::Statement::Break          ();
use PPI::Future::Statement::Compound       ();
use PPI::Future::Statement::Data           ();
use PPI::Future::Statement::End            ();
use PPI::Future::Statement::Expression     ();
use PPI::Future::Statement::Include        ();
use PPI::Future::Statement::Null           ();
use PPI::Future::Statement::Package        ();
use PPI::Future::Statement::Scheduled      ();
use PPI::Future::Statement::Sub            ();
use PPI::Future::Statement::Given         ();
use PPI::Future::Statement::UnmatchedBrace ();
use PPI::Future::Statement::Unknown        ();
use PPI::Future::Statement::Variable       ();
use PPI::Future::Statement::When           ();

# "Normal" statements end at a statement terminator ;
# Some are not, and need the more rigorous _continues to see
# if we are at an implicit statement boundary.
sub __LEXER__normal() { 1 }





#####################################################################
# Constructor

sub new {
	my $class = shift;
	if ( ref $class ) {
		PPI::Future::Exception->throw;
	}

	# Create the object
	my $self = bless { 
		children => [],
	}, $class;

	# If we have been passed what should be an initial token, add it
	my $token = shift;
	if ( _INSTANCE($token, 'PPI::Future::Token') ) {
		# Inlined $self->__add_element(shift);
		Scalar::Util::weaken(
			$_PARENT{Scalar::Util::refaddr $token} = $self
		);
		push @{$self->{children}}, $token;
	}

	$self;
}

=pod

=head2 label

One factor common to most statements is their ability to be labeled.

The C<label> method returns the label for a statement, if one has been
defined, but without the trailing colon. Take the following example

  MYLABEL: while ( 1 .. 10 ) { last MYLABEL if $_ > 5 }

For the above statement, the C<label> method would return 'MYLABEL'.

Returns false if the statement does not have a label.

=cut

sub label {
	my $first = shift->schild(1) or return '';
	$first->isa('PPI::Future::Token::Label')
		? substr($first, 0, length($first) - 1)
		: '';
}

=pod

=head2 specialized

Answer whether this is a plain statement or one that has more
significance.

Returns true if the statement is a subclass of this one, false
otherwise.

=cut

# Yes, this is doing precisely what it's intending to prevent
# client code from doing.  However, since it's here, if the
# implementation changes, code outside PPI::Future doesn't care.
sub specialized {
	__PACKAGE__ ne ref $_[0];
}

=pod

=head2 stable

Much like the L<PPI::Future::Document> method of the same name, the ->stable
method converts a statement to source and back again, to determine if
a modified statement is still legal, and won't be interpreted in a
different way.

Returns true if the statement is stable, false if not, or C<undef> on
error.

=cut

sub stable {
	die "The ->stable method has not yet been implemented";	
}





#####################################################################
# PPI::Future::Element Methods

# Is the statement complete.
# By default for a statement, we need a semi-colon at the end.
sub _complete {
	my $self = shift;
	my $semi = $self->schild(-1);
	return !! (
		defined $semi
		and
		$semi->isa('PPI::Future::Token::Structure')
		and
		$semi->content eq ';'
	);
}

# You can insert either a statement or a non-significant token.
sub insert_before {
	my $self    = shift;
	my $Element = _INSTANCE(shift, 'PPI::Future::Element') or return undef;
	if ( $Element->isa('PPI::Future::Statement') ) {
		return $self->__insert_before($Element);
	} elsif ( $Element->isa('PPI::Future::Token') and ! $Element->significant ) {
		return $self->__insert_before($Element);
	}
	'';
}

# As above, you can insert a statement, or a non-significant token
sub insert_after {
	my $self    = shift;
	my $Element = _INSTANCE(shift, 'PPI::Future::Element') or return undef;
	if ( $Element->isa('PPI::Future::Statement') ) {
		return $self->__insert_after($Element);
	} elsif ( $Element->isa('PPI::Future::Token') and ! $Element->significant ) {
		return $self->__insert_after($Element);
	}
	'';
}

1;

=pod

=head1 TO DO

- Complete, freeze and document the remaining classes

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