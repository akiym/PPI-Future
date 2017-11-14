package PPI::Future::Token::ArrayIndex;

=pod

=head1 NAME

PPI::Future::Token::ArrayIndex - Token getting the last index for an array

=head1 INHERITANCE

  PPI::Future::Token::ArrayIndex
  isa PPI::Future::Token
      isa PPI::Future::Element

=head1 DESCRIPTION

The C<PPI::Future::Token::ArrayIndex> token represents an attempt to get the
last index of an array, such as C<$#array>.

=head1 METHODS

There are no additional methods beyond those provided by the parent
L<PPI::Future::Token> and L<PPI::Future::Element> classes.

=cut

use strict;
use PPI::Future::Token ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Token";





#####################################################################
# Tokenizer Methods

sub __TOKENIZER__on_char {
	my $t = $_[1];

	# Suck in till the end of the arrayindex
	pos $t->{line} = $t->{line_cursor};
	if ( $t->{line} =~ m/\G([\w:']+)/gc ) {
		$t->{token}->{content} .= $1;
		$t->{line_cursor} += length $1;
	}

	# End of token
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
