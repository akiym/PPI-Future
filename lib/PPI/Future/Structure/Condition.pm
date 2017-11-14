package PPI::Future::Structure::Condition;

=pod

=head1 NAME

PPI::Future::Structure::Condition - Round braces for boolean context conditions

=head1 SYNOPSIS

  if ( condition ) {
      ...
  }
  
  while ( condition ) {
      ...
  }

=head1 INHERITANCE

  PPI::Future::Structure::Condition
  isa PPI::Future::Structure
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

C<PPI::Future::Structure::Condition> is the class used for all round braces
that represent boolean contexts used in various conditions.

=head1 METHODS

C<PPI::Future::Structure::Condition> has no methods beyond those provided by
the standard L<PPI::Future::Structure>, L<PPI::Future::Node> and L<PPI::Future::Element> methods.

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
