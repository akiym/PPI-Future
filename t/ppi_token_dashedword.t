#!/usr/bin/perl

# Unit testing for PPI::Future::Token::DashedWord

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 9 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;


LITERAL: {
	my @pairs = (
		"-foo",        '-foo',
		"-Foo::Bar",   '-Foo::Bar',
		"-Foo'Bar",    '-Foo::Bar',
	);
	while ( @pairs ) {
		my $from  = shift @pairs;
		my $to    = shift @pairs;
		my $doc   = PPI::Future::Document->new( \"( $from => 1 );" );
		isa_ok( $doc, 'PPI::Future::Document' );
		my $word = $doc->find_first('Token::DashedWord');
		SKIP: {
			skip( "PPI::Future::Token::DashedWord is deactivated", 2 );
			isa_ok( $word, 'PPI::Future::Token::DashedWord' );
			is( $word && $word->literal, $to, "The source $from becomes $to ok" );
		}
	}
}
