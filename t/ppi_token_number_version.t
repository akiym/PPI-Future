#!/usr/bin/perl

# Unit testing for PPI::Future::Token::Number::Version

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 735 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;
use PPI::Future::Singletons qw' %OPERATOR %QUOTELIKE %KEYWORDS ';


LITERAL: {
	my $doc1 = new_ok( 'PPI::Future::Document' => [ \'1.2.3.4'  ] );
	my $doc2 = new_ok( 'PPI::Future::Document' => [ \'v1.2.3.4' ] );
	isa_ok( $doc1->child(0), 'PPI::Future::Statement' );
	isa_ok( $doc2->child(0), 'PPI::Future::Statement' );
	isa_ok( $doc1->child(0)->child(0), 'PPI::Future::Token::Number::Version' );
	isa_ok( $doc2->child(0)->child(0), 'PPI::Future::Token::Number::Version' );

	my $literal1 = $doc1->child(0)->child(0)->literal;
	my $literal2 = $doc2->child(0)->child(0)->literal;
	is( length($literal1), 4, 'The literal length of doc1 is 4' );
	is( length($literal2), 4, 'The literal length of doc1 is 4' );
	is( $literal1, $literal2, 'Literals match for 1.2.3.4 vs v1.2.3.4' );
}


VSTRING_ENDS_CORRECTLY: {
	my @tests = (
		(
			map {
				{
					desc=>"no . in 'v49$_', so not a version string",
					code=>"v49$_",
					expected=>[ 'PPI::Future::Token::Word' => "v49$_" ],
				}
			} (
				'x3', # not fooled by faux x operator with operand
				'e10', # not fooled by faux scientific notation
				keys %KEYWORDS,
			),
		),
		(
			map {
				{
					desc => "version string in 'v49.49$_' stops after number",
					code => "v49.49$_",
					expected => [
						'PPI::Future::Token::Number::Version' => 'v49.49',
						get_class($_) => $_,
					],
				},
			} (
				keys %KEYWORDS,
			),
		),
		(
			map {
				{
					desc => "version string in '49.49.49$_' stops after number",
					code => "49.49.49$_",
					expected => [
						'PPI::Future::Token::Number::Version' => '49.49.49',
						get_class($_) => $_,
					],
				},
			} (
				keys %KEYWORDS,
			),
		),
		{
			desc => 'version string, x, and operand',
			code => 'v49.49.49x3',
			expected => [
				'PPI::Future::Token::Number::Version' => 'v49.49.49',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '3',
			],
		},
	);
	for my $test ( @tests ) {
		my $code = $test->{code};

		my $d = PPI::Future::Document->new( \$test->{code} );
		my $tokens = $d->find( sub { 1; } );
		$tokens = [ map { ref($_), $_->content() } @$tokens ];
		my $expected = $test->{expected};
		unshift @$expected, 'PPI::Future::Statement', $test->{code};
		my $ok = is_deeply( $tokens, $expected, $test->{desc} );
		if ( !$ok ) {
			diag "$test->{code} ($test->{desc})\n";
			diag explain $tokens;
			diag explain $test->{expected};
		}
	}
}

sub get_class {
	my ( $t ) = @_;
	my $ql = $QUOTELIKE{$t};
	return "PPI::Future::Token::$ql" if $ql;
	return 'PPI::Future::Token::Operator' if $OPERATOR{$t};
	return 'PPI::Future::Token::Word';
}
