package PPI::Future::Token;

=pod

=head1 NAME

PPI::Future::Token - A single token of Perl source code

=head1 INHERITANCE

  PPI::Future::Token
  isa PPI::Future::Element

=head1 DESCRIPTION

C<PPI::Future::Token> is the abstract base class for all Tokens. In PPI::Future terms, a "Token" is
a L<PPI::Future::Element> that directly represents bytes of source code.

=head1 METHODS

=cut

use strict;
use Params::Util   qw{_INSTANCE};
use PPI::Future::Element   ();
use PPI::Future::Exception ();

our $VERSION = '1.236';

our @ISA = 'PPI::Future::Element';

# We don't load the abstracts, they are loaded
# as part of the inheritance process.

# Load the token classes
use PPI::Future::Token::BOM                   ();
use PPI::Future::Token::Whitespace            ();
use PPI::Future::Token::Comment               ();
use PPI::Future::Token::Pod                   ();
use PPI::Future::Token::Number                ();
use PPI::Future::Token::Number::Binary        ();
use PPI::Future::Token::Number::Octal         ();
use PPI::Future::Token::Number::Hex           ();
use PPI::Future::Token::Number::Float         ();
use PPI::Future::Token::Number::Exp           ();
use PPI::Future::Token::Number::Version       ();
use PPI::Future::Token::Word                  ();
use PPI::Future::Token::DashedWord            ();
use PPI::Future::Token::Symbol                ();
use PPI::Future::Token::ArrayIndex            ();
use PPI::Future::Token::Magic                 ();
use PPI::Future::Token::Quote::Single         ();
use PPI::Future::Token::Quote::Double         ();
use PPI::Future::Token::Quote::Literal        ();
use PPI::Future::Token::Quote::Interpolate    ();
use PPI::Future::Token::QuoteLike::Backtick   ();
use PPI::Future::Token::QuoteLike::Command    ();
use PPI::Future::Token::QuoteLike::Regexp     ();
use PPI::Future::Token::QuoteLike::Words      ();
use PPI::Future::Token::QuoteLike::Readline   ();
use PPI::Future::Token::Regexp::Match         ();
use PPI::Future::Token::Regexp::Substitute    ();
use PPI::Future::Token::Regexp::Transliterate ();
use PPI::Future::Token::Operator              ();
use PPI::Future::Token::Cast                  ();
use PPI::Future::Token::Structure             ();
use PPI::Future::Token::Label                 ();
use PPI::Future::Token::HereDoc               ();
use PPI::Future::Token::Separator             ();
use PPI::Future::Token::Data                  ();
use PPI::Future::Token::End                   ();
use PPI::Future::Token::Prototype             ();
use PPI::Future::Token::Attribute             ();
use PPI::Future::Token::Unknown               ();





#####################################################################
# Constructor and Related

sub new {
	bless { content => (defined $_[1] ? "$_[1]" : '') }, $_[0];
}

sub set_class {
	my $self  = shift;
	# @_ or throw Exception("No arguments to set_class");
	my $class = substr( $_[0], 0, 12 ) eq 'PPI::Future::Token::' ? shift : 'PPI::Future::Token::' . shift;

	# Find out if the current and new classes are complex
	my $old_quote = (ref($self) =~ /\b(?:Quote|Regex)\b/o) ? 1 : 0;
	my $new_quote = ($class =~ /\b(?:Quote|Regex)\b/o)     ? 1 : 0;

	# No matter what happens, we will have to rebless
	bless $self, $class;

	# If we are changing to or from a Quote style token, we
	# can't just rebless and need to do some extra thing
	# Otherwise, we have done enough
	return $class if ($old_quote - $new_quote) == 0;

	# Make a new token from the old content, and overwrite the current
	# token's attributes with the new token's attributes.
	my $token = $class->new( $self->{content} );
	%$self = %$token;

	# Return the class as a convenience
	return $class;
}





#####################################################################
# PPI::Future::Token Methods

=pod

=head2 set_content $string

The C<set_content> method allows you to set/change the string that the
C<PPI::Future::Token> object represents.

Returns the string you set the Token to

=cut

sub set_content {
	$_[0]->{content} = $_[1];
}

=pod

=head2 add_content $string

The C<add_content> method allows you to add additional bytes of code
to the end of the Token.

Returns the new full string after the bytes have been added.

=cut

sub add_content { $_[0]->{content} .= $_[1] }

=pod

=head2 length

The C<length> method returns the length of the string in a Token.

=cut

sub length { CORE::length($_[0]->{content}) }





#####################################################################
# Overloaded PPI::Future::Element methods

sub content {
	$_[0]->{content};
}

# You can insert either a statement, or a non-significant token.
sub insert_before {
	my $self    = shift;
	my $Element = _INSTANCE(shift, 'PPI::Future::Element')  or return undef;
	if ( $Element->isa('PPI::Future::Structure') ) {
		return $self->__insert_before($Element);
	} elsif ( $Element->isa('PPI::Future::Token') ) {
		return $self->__insert_before($Element);
	}
	'';
}

# As above, you can insert a statement, or a non-significant token
sub insert_after {
	my $self    = shift;
	my $Element = _INSTANCE(shift, 'PPI::Future::Element') or return undef;
	if ( $Element->isa('PPI::Future::Structure') ) {
		return $self->__insert_after($Element);
	} elsif ( $Element->isa('PPI::Future::Token') ) {
		return $self->__insert_after($Element);
	}
	'';
}





#####################################################################
# Tokenizer Methods

sub __TOKENIZER__on_line_start() { 1 }
sub __TOKENIZER__on_line_end()   { 1 }
sub __TOKENIZER__on_char()       { 'Unknown' }





#####################################################################
# Lexer Methods

sub __LEXER__opens {
	ref($_[0]) eq 'PPI::Future::Token::Structure'
	and
	$_[0]->{content} =~ /(?:\(|\[|\{)/
}

sub __LEXER__closes {
	ref($_[0]) eq 'PPI::Future::Token::Structure'
	and
	$_[0]->{content} =~ /(?:\)|\]|\})/
}

1;

=pod

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
