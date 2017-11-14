package PPI::Future::Statement::Given;

=pod

=head1 NAME

PPI::Future::Statement::Given - A given-when statement

=head1 SYNOPSIS

  given ( foo ) {
      say $_;
  }

=head1 INHERITANCE

  PPI::Future::Statement::Given
  isa PPI::Future::Statement
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

C<PPI::Future::Statement::Given> objects are used to describe switch statements, as
described in L<perlsyn>.

=head1 METHODS

C<PPI::Future::Statement::Given> has no methods beyond those provided by the
standard L<PPI::Future::Structure>, L<PPI::Future::Node> and L<PPI::Future::Element> methods.

=cut

use strict;
use PPI::Future::Statement ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Statement";

# Lexer clues
sub __LEXER__normal() { '' }

sub _complete {
	my $child = $_[0]->schild(-1);
	return !! (
		defined $child
		and
		$child->isa('PPI::Future::Structure::Block')
		and
		$child->complete
	);
}





#####################################################################
# PPI::Future::Node Methods

sub scope() { 1 }

1;

=pod

=head1 TO DO

- Write unit tests for this package

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
