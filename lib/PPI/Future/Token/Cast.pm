package PPI::Future::Token::Cast;

=pod

=head1 NAME

PPI::Future::Token::Cast - A prefix which forces a value into a different context

=head1 INHERITANCE

  PPI::Future::Token::Cast
  isa PPI::Future::Token
      isa PPI::Future::Element

=head1 DESCRIPTION

A "cast" in PPI::Future terms is one of more characters used as a prefix which force
a value into a different class or context.

This includes referencing, dereferencing, and a few other minor cases.

For expressions such as C<@$foo> or C<@{ $foo{bar} }> the C<@> in both cases
represents a cast. In this case, an array dereference.

=head1 METHODS

There are no additional methods beyond those provided by the parent
L<PPI::Future::Token> and L<PPI::Future::Element> classes.

=cut

use strict;
use PPI::Future::Token ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Token";

our %POSTFIX = map { $_ => 1 } (
	qw{
	%* @* $* $#*
	}
	);




#####################################################################
# Tokenizer Methods

# A cast is either % @ $ or $#
# and also postfix dereference are %* @* $* $#*
sub __TOKENIZER__on_char {
	my $t    = $_[1];
	my $char = substr( $t->{line}, $t->{line_cursor}, 1 );

	# Are we still an operator if we add the next character
	my $content = $t->{token}->{content};
	return 1 if $POSTFIX{ $content . $char };

	$t->_finalize_token->__TOKENIZER__on_char( $t );
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
