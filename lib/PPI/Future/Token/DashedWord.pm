package PPI::Future::Token::DashedWord;

=pod

=head1 NAME

PPI::Future::Token::DashedWord - A dashed bareword token

=head1 INHERITANCE

  PPI::Future::Token::DashedWord
  isa PPI::Future::Token
      isa PPI::Future::Element

=head1 DESCRIPTION

The "dashed bareword" token represents literal values like C<-foo>.

NOTE: this class is currently unused.  All tokens that should be
PPI::Future::Token::DashedWords are just normal PPI::Future::Token::Word instead.
That actually makes sense, since there really is nothing special about
this class except that dashed words cannot be subroutine names or
keywords.  As such, this class may be removed from PPI::Future in the future.

=head1 METHODS

=cut

use strict;
use PPI::Future::Token ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Token";

=pod

=head2 literal

Returns the value of the dashed word as a string.  This differs from
C<content> because C<-Foo'Bar> expands to C<-Foo::Bar>.

=cut

*literal = *PPI::Future::Token::Word::literal;



#####################################################################
# Tokenizer Methods

sub __TOKENIZER__on_char {
	my $t = $_[1];

	# Suck to the end of the dashed bareword
	pos $t->{line} = $t->{line_cursor};
	if ( $t->{line} =~ m/\G(\w+)/gc ) {
		$t->{token}->{content} .= $1;
		$t->{line_cursor} += length $1;
	}

	# Are we a file test operator?
	if ( $t->{token}->{content} =~ /^\-[rwxoRWXOezsfdlpSbctugkTBMAC]$/ ) {
		# File test operator
		$t->{class} = $t->{token}->set_class( 'Operator' );
	} else {
		# No, normal dashed bareword
		$t->{class} = $t->{token}->set_class( 'Word' );
	}

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
