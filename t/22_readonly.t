#!/usr/bin/perl

# Testing of readonly functionality

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 8 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future::Document;





#####################################################################
# Creating Documents

SCOPE: {
	# Blank document	
	my $empty = PPI::Future::Document->new;
	isa_ok( $empty, 'PPI::Future::Document' );
	is( $empty->readonly, '', '->readonly is false for blank' );

	# From source
	my $source = 'print "Hello World!\n"';
	my $doc1 = PPI::Future::Document->new( \$source );
	isa_ok( $doc1, 'PPI::Future::Document' );
	is( $doc1->readonly, '', '->readonly is false by default' );

	# With explicit false
	my $doc2 = PPI::Future::Document->new( \$source,
		readonly => undef,
		);
	isa_ok( $doc2, 'PPI::Future::Document' );
	is( $doc2->readonly, '', '->readonly is false for explicit false' );

	# With explicit true
	my $doc3 = PPI::Future::Document->new( \$source,
		readonly => 2,
		);
	isa_ok( $doc3, 'PPI::Future::Document' );
	is( $doc3->readonly, 1, '->readonly is true for explicit true' );
}
