#!/usr/bin/perl

# Unit testing for PPI::Future::Token::Pod

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 8 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;


MERGE: {
	# Create the test fragments
	my $one = PPI::Future::Token::Pod->new("=pod\n\nOne\n\n=cut\n");
	my $two = PPI::Future::Token::Pod->new("=pod\n\nTwo");
	isa_ok( $one, 'PPI::Future::Token::Pod' );
	isa_ok( $two, 'PPI::Future::Token::Pod' );

	# Create the combined Pod
	my $merged = PPI::Future::Token::Pod->merge($one, $two);
	isa_ok( $merged, 'PPI::Future::Token::Pod' );
	is( $merged->content, "=pod\n\nOne\n\nTwo\n\n=cut\n", 'Merged POD looks ok' );
}


TOKENIZE: {
	foreach my $test (
		[ "=pod\n=cut", [ 'PPI::Future::Token::Pod' ] ],
		[ "=pod\n=cut\n", [ 'PPI::Future::Token::Pod' ] ],
		[ "=pod\n=cut\n\n", [ 'PPI::Future::Token::Pod', 'PPI::Future::Token::Whitespace' ] ],
		[ "=pod\n=Cut\n\n", [ 'PPI::Future::Token::Pod' ] ],  # pod doesn't end, so no whitespace token
	) {
		my $T = PPI::Future::Tokenizer->new( \$test->[0] );
		my @tokens = map { ref $_ } @{ $T->all_tokens };
		is_deeply( \@tokens, $test->[1], 'all tokens as expected' );
	}
}
