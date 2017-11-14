#!/usr/bin/perl

# Unit testing for PPI::Future::Token::Quote::Interpolate

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 8 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;


STRING: {
	my $Document = PPI::Future::Document->new( \"print qq{foo}, qq!bar!, qq <foo>;" );
	isa_ok( $Document, 'PPI::Future::Document' );
	my $Interpolate = $Document->find('Token::Quote::Interpolate');
	is( scalar(@$Interpolate), 3, '->find returns three objects' );
	isa_ok( $Interpolate->[0], 'PPI::Future::Token::Quote::Interpolate' );
	isa_ok( $Interpolate->[1], 'PPI::Future::Token::Quote::Interpolate' );
	isa_ok( $Interpolate->[2], 'PPI::Future::Token::Quote::Interpolate' );
	is( $Interpolate->[0]->string, 'foo', '->string returns as expected' );
	is( $Interpolate->[1]->string, 'bar', '->string returns as expected' );
	is( $Interpolate->[2]->string, 'foo', '->string returns as expected' );
}
