#!/usr/bin/perl

# Unit testing for PPI::Future::Token::Quote::Single

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 24 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;


STRING: {
	my $Document = PPI::Future::Document->new( \"print 'foo';" );
	isa_ok( $Document, 'PPI::Future::Document' );
	my $Single = $Document->find_first('Token::Quote::Single');
	isa_ok( $Single, 'PPI::Future::Token::Quote::Single' );
	is( $Single->string, 'foo', '->string returns as expected' );
}


LITERAL: {
	my @pairs = (
		"''",          '',
		"'f'",         'f',
		"'f\\'b'",     "f\'b",
		"'f\\nb'",     "f\\nb",
		"'f\\\\b'",    "f\\b",
		"'f\\\\\\b'", "f\\\\b",
		"'f\\\\\\\''", "f\\'",
	);
	while ( @pairs ) {
		my $from  = shift @pairs;
		my $to    = shift @pairs;
		my $doc   = PPI::Future::Document->new( \"print $from;" );
		isa_ok( $doc, 'PPI::Future::Document' );
		my $quote = $doc->find_first('Token::Quote::Single');
		isa_ok( $quote, 'PPI::Future::Token::Quote::Single' );
		is( $quote->literal, $to, "The source $from becomes $to ok" );
	}
}
