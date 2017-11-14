package PPI::Future::Statement::UnmatchedBrace;

=pod

=head1 NAME

PPI::Future::Statement::UnmatchedBrace - Isolated unmatched brace

=head1 SYNOPSIS

  sub foo {
      1;
  }
  
  } # <--- This is an unmatched brace

=head1 INHERITANCE

  PPI::Future::Statement::UnmatchedBrace
  isa PPI::Future::Statement
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

The C<PPI::Future::Statement::UnmatchedBrace> class is a miscellaneous utility
class. Objects of this type should be rare, or not exist at all in normal
valid L<PPI::Future::Document> objects.

It can be either a round ')', square ']' or curly '}' brace, this class
does not distinguish. Objects of this type are only allocated at a
structural level, not a lexical level (as they are lexically invalid
anyway).

The presence of a C<PPI::Future::Statement::UnmatchedBrace> indicated a broken
or invalid document. Or maybe a bug in PPI::Future, but B<far> more likely a
broken Document. :)

=head1 METHODS

C<PPI::Future::Statement::UnmatchedBrace> has no additional methods beyond the
default ones provided by L<PPI::Future::Statement>, L<PPI::Future::Node> and
L<PPI::Future::Element>.

=cut

use strict;
use PPI::Future::Statement ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Statement";

# Once we've hit a naked unmatched brace we can never truly be complete.
# So instead we always just call it a day...
sub _complete () { 1 }

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
