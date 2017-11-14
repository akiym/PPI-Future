#!/usr/bin/perl

# Regression test of a Perl 5 grammar that exploded
# with a "98 subroutine recursion" error in 1.201

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 8 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use File::Spec::Functions ':ALL';
use PPI::Future;

foreach my $file ( qw{
	Simple.pm
	Grammar.pm
} ) {
	my $path = catfile( qw{ t data 24_v6 }, $file );
	ok( -f $path, "Found test file $file" );

	my $doc = PPI::Future::Document->new( $path );
	isa_ok( $doc, 'PPI::Future::Document' );

	# Find the first Perl6 include
	my $include = $doc->find_first( 'PPI::Future::Statement::Include::Perl6' );
	isa_ok( $include, 'PPI::Future::Statement::Include::Perl6' );
	ok(
		scalar($include->perl6),
		'use v6 statement has a working ->perl6 method',
	);
}
