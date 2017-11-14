#!/usr/bin/perl

# Testing for the PPI::Future::Document ->complete method

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More; # Plan comes later

use File::Spec::Functions ':ALL';
use PPI::Future;
use PPI::Future::Test 'find_files';

# This test uses a series of ordered files, containing test code.
# The letter after the number acts as a boolean yes/no answer to
# "Is this code complete"
my @files = find_files( catdir( 't', 'data', '27_complete' ) );
my $tests = (scalar(@files) * 2) + 1 + ($ENV{AUTHOR_TESTING} ? 1 : 0);
plan( tests => $tests );





#####################################################################
# Resource Location

ok( scalar(@files), 'Found at least one ->complete test file' );
foreach my $file ( @files ) {
	# Load the document
	my $document = PPI::Future::Document->new( $file );
	isa_ok( $document, 'PPI::Future::Document' );

	# Test if complete or not
	my $got      = !! ($document->complete);
	my $expected = !! ($file =~ /\d+y\w+\.code$/);
	my $isnot    = ($got == $expected) ? 'is' : 'is NOT';
	is( $got, $expected, "File $file $isnot complete" );
}
