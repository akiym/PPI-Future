package PPI::Future::Token::Separator;

=pod

=head1 NAME

PPI::Future::Token::Separator - The __DATA__ and __END__ tags

=head1 INHERITANCE

  PPI::Future::Token::Separator
  isa PPI::Future::Token::Word
      isa PPI::Future::Token
          isa PPI::Future::Element

=head1 DESCRIPTION

Although superficially looking like a normal L<PPI::Future::Token::Word> object,
when the C<__DATA__> and C<__END__> compiler tags appear at the beginning of
a line (on supposedly) their own line, these tags become file section
separators.

The indicate that the time for Perl code is over, and the rest of the
file is dedicated to something else (data in the case of C<__DATA__>) or
to nothing at all (in the case of C<__END__>).

=head1 METHODS

This class has no methods beyond what is provided by its
L<PPI::Future::Token::Word>, L<PPI::Future::Token> and L<PPI::Future::Element>
parent classes.

=cut

use strict;
use PPI::Future::Token::Word ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Token";

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
