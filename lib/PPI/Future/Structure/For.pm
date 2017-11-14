package PPI::Future::Structure::For;

=pod

=head1 NAME

PPI::Future::Structure::For - Circular braces for a for expression

=head1 SYNOPSIS

  for ( var $i = 0; $i < $max; $i++ ) {
      ...
  }

=head1 INHERITANCE

  PPI::Future::Structure::For
  isa PPI::Future::Structure
      isa PPI::Future::Node
          isa PPI::Future::Element

=head1 DESCRIPTION

C<PPI::Future::Structure::For> is the class used for circular braces that
contain the three part C<for> expression.

=head1 METHODS

C<PPI::Future::Structure::For> has no methods beyond those provided by the
standard L<PPI::Future::Structure>, L<PPI::Future::Node> and L<PPI::Future::Element> methods.

=cut

use strict;
use PPI::Future::Structure ();

our $VERSION = '1.236';

our @ISA = "PPI::Future::Structure";

# Highly special custom isa method that will continue to respond
# positively to ->isa('PPI::Future::Structure::ForLoop') but warns.
my $has_warned = 0;
sub isa {
	if ( $_[1] and $_[1] eq 'PPI::Future::Structure::ForLoop' ) {
		unless ( $has_warned ) {
			warn("PPI::Future::Structure::ForLoop has been deprecated");
			$has_warned = 1;
		}
		return 1;
	}
	return shift->SUPER::isa(@_);
}

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
