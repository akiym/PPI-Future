package PPI::Future::Statement::Data;

=pod

=head1 NAME

PPI::Future::Statement::Data - The __DATA__ section of a file

=head1 SYNOPSIS

  # Normal content
  
  __DATA__
  This: data
  is: part
  of: the
  PPI::Future::Statement::Data: object

=head1 INHERITANCE

  PPI::Future::Statement::Compound
  isa PPI::Future::Statement
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

C<PPI::Future::Statement::Data> is a utility class designed to hold content in
the __DATA__ section of a file. It provides a single statement to hold
B<all> of the data.

=head1 METHODS

C<PPI::Future::Statement::Data> has no additional methods beyond the default ones
provided by L<PPI::Future::Statement>, L<PPI::Future::Node> and L<PPI::Future::Element>.

However, it is expected to gain methods for accessing the data directly,
(as a filehandle for example) just as you would access the data in the
Perl code itself.

=cut

use strict;
use PPI::Future::Statement ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Statement";

# Data is never complete
sub _complete () { '' }

1;

=pod

=head1 TO DO

- Add the methods to read in the data

- Add some proper unit testing

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
