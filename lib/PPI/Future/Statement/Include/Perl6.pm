package PPI::Future::Statement::Include::Perl6;

=pod

=head1 NAME

PPI::Future::Statement::Include::Perl6 - Inline Perl 6 file section

=head1 SYNOPSIS

  use v6-alpha;
  
  grammar My::Grammar {
      ...
  }

=head1 INHERITANCE

  PPI::Future::Statement::Include::Perl6
  isa PPI::Future::Statement::Include
      isa PPI::Future::Statement
          isa PPI::Future::Node
              isa PPI::Future::Element

=head1 DESCRIPTION

A C<PPI::Future::Statement::Include::Perl6> is a special include statement that
indicates the start of a section of Perl 6 code inlined into a regular
Perl 5 code file.

The primary purpose of the class is to allow L<PPI::Future> to provide at least
basic support for "6 in 5" modules like v6.pm;

Currently, PPI::Future only supports starting a Perl 6 block. It does not
currently support changing back to Perl 5 again. Additionally all POD
and __DATA__ blocks and __END__ blocks will be included in the Perl 6
string and will not be parsed by PPI::Future.

=cut

use strict;
use PPI::Future::Statement::Include ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Statement::Include";

=pod

=head2 perl6

The C<perl6> method returns the block of Perl 6 code that is attached to
the "use v6...;" command.

=cut

sub perl6 {
	$_[0]->{perl6};
}

1;

=pod

=head1 TO DO

- Write specific unit tests for this package

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
