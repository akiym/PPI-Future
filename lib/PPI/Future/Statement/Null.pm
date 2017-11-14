package PPI::Future::Statement::Null;

=pod

=head1 NAME

PPI::Future::Statement::Null - A useless null statement

=head1 SYNOPSIS

  my $foo = 1;
  
  ; # <-- Null statement
  
  my $bar = 1;

=head1 INHERITANCE

  PPI::Future::Statement::Null
  isa PPI::Future::Statement
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

C<PPI::Future::Statement::Null> is a utility class designed to handle situations
where PPI::Future encounters a naked statement separator.

Although strictly speaking, the semicolon is a statement B<separator>
and not a statement B<terminator>, PPI::Future considers a semicolon to be a
statement terminator under most circumstances.

In any case, the null statement has no purpose, and can be safely deleted
with no ill effect.

=head1 METHODS

C<PPI::Future::Statement::Null> has no additional methods beyond the default ones
provided by L<PPI::Future::Statement>, L<PPI::Future::Node> and L<PPI::Future::Element>.

=cut

use strict;
use PPI::Future::Statement ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Statement";

# A null statement is not significant
sub significant() { '' }

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
