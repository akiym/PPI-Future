package PPI::Future::Structure::Block;

=pod

=head1 NAME

PPI::Future::Structure::Block - Curly braces representing a code block

=head1 SYNOPSIS

  sub foo { ... }
  
  grep { ... } @list;
  
  if ( condition ) {
      ...
  }
  
  LABEL: {
      ...
  }

=head1 INHERITANCE

  PPI::Future::Structure::Block
  isa PPI::Future::Structure
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

C<PPI::Future::Structure::Block> is the class used for all curly braces that
represent code blocks. This includes subroutines, compound statements
and any other block braces.

=head1 METHODS

C<PPI::Future::Structure::Block> has no methods beyond those provided by the
standard L<PPI::Future::Structure>, L<PPI::Future::Node> and L<PPI::Future::Element> methods.

=cut

use strict;
use PPI::Future::Structure ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Structure";





#####################################################################
# PPI::Future::Element Methods

# This is a scope boundary
sub scope() { 1 }

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
