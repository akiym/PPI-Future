package PPI::Future::Structure::Subscript;

=pod

=head1 NAME

PPI::Future::Structure::Subscript - Braces that represent an array or hash subscript

=head1 SYNOPSIS

  # The end braces for all of the following are subscripts
  $foo->[...]
  $foo[...]
  $foo{...}[...]
  $foo->{...}
  $foo{...}
  $foo[]{...}

=head1 INHERITANCE

  PPI::Future::Structure::Subscript
  isa PPI::Future::Structure
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

C<PPI::Future::Structure::Subscript> is the class used for square and curly
braces that specify one element of an array or hash (or a slice/subset
of an array or hash)

=head1 METHODS

C<PPI::Future::Structure::Subscript> has no methods beyond those provided by the
standard L<PPI::Future::Structure>, L<PPI::Future::Node> and L<PPI::Future::Element> methods.

=cut

use strict;
use PPI::Future::Structure ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Structure";

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
