package PPI::Future::Statement::Expression;

=pod

=head1 NAME

PPI::Future::Statement::Expression - A generic and non-specialised statement

=head1 SYNOPSIS

  $foo = bar;
  ("Hello World!");
  do_this();

=head1 INHERITANCE

  PPI::Future::Statement::Expression
  isa PPI::Future::Statement
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

A C<PPI::Future::Statement::Expression> is a normal statement that is evaluated,
may or may not assign, may or may not have side effects, and has no special
or redeeming features whatsoever.

It provides a default for all statements that don't fit into any other
classes.

=head1 METHODS

C<PPI::Future::Statement::Expression> has no additional methods beyond the default ones
provided by L<PPI::Future::Statement>, L<PPI::Future::Node> and L<PPI::Future::Element>.

=cut

use strict;
use PPI::Future::Statement ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Statement";

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
