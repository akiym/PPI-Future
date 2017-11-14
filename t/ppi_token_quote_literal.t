#!/usr/bin/perl

# Unit testing for PPI::Future::Token::Quote::Literal

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 14 + ( $ENV{AUTHOR_TESTING} ? 1 : 0 );
use B 'perlstring';

use PPI::Future;


STRING: {
	my $Document = PPI::Future::Document->new( \"print q{foo}, q!bar!, q <foo>;" );
	isa_ok( $Document, 'PPI::Future::Document' );
	my $literal = $Document->find('Token::Quote::Literal');
	is( scalar(@$literal), 3, '->find returns three objects' );
	isa_ok( $literal->[0], 'PPI::Future::Token::Quote::Literal' );
	isa_ok( $literal->[1], 'PPI::Future::Token::Quote::Literal' );
	isa_ok( $literal->[2], 'PPI::Future::Token::Quote::Literal' );
	is( $literal->[0]->string, 'foo', '->string returns as expected' );
	is( $literal->[1]->string, 'bar', '->string returns as expected' );
	is( $literal->[2]->string, 'foo', '->string returns as expected' );
}


LITERAL: {
	my $Document = PPI::Future::Document->new( \"print q{foo}, q!bar!, q <foo>;" );
	isa_ok( $Document, 'PPI::Future::Document' );
	my $literal = $Document->find('Token::Quote::Literal');
	is( $literal->[0]->literal, 'foo', '->literal returns as expected' );
	is( $literal->[1]->literal, 'bar', '->literal returns as expected' );
	is( $literal->[2]->literal, 'foo', '->literal returns as expected' );
}

test_statement(
	"use 'SomeModule';",
	[
		'PPI::Future::Statement::Include'   => "use 'SomeModule';",
		'PPI::Future::Token::Word'          => 'use',
		'PPI::Future::Token::Quote::Single' => "'SomeModule'",
		'PPI::Future::Token::Structure'     => ';',
	]
);

test_statement(
	"use q{OtherModule.pm};",
	[
		'PPI::Future::Statement::Include'     => 'use q{OtherModule.pm};',
		'PPI::Future::Token::Word'            => 'use',
		'PPI::Future::Token::Word'            => 'q',
		'PPI::Future::Structure::Constructor' => '{OtherModule.pm}',
		'PPI::Future::Token::Structure'       => '{',
		'PPI::Future::Statement'              => 'OtherModule.pm',
		'PPI::Future::Token::Word'            => 'OtherModule',
		'PPI::Future::Token::Operator'        => '.',
		'PPI::Future::Token::Word'            => 'pm',
		'PPI::Future::Token::Structure'       => '}',
		'PPI::Future::Token::Structure'       => ';',
	],
	"invalid syntax is identified correctly",
);

sub one_line_explain {
	my ( $data ) = @_;
	my @explain = explain $data;
	s/\n//g for @explain;
	return join "", @explain;
}

sub main_level_line {
	return "" if not $TODO;
	my @outer_final;
	my $level = 0;
	while ( my @outer = caller( $level++ ) ) {
		@outer_final = @outer;
	}
	return "l $outer_final[2] - ";
}

sub test_statement {
	local $Test::Builder::Level = $Test::Builder::Level + 1;
	my ( $code, $expected, $msg ) = @_;
	$msg = perlstring $code if !defined $msg;

	my $d = PPI::Future::Document->new( \$code );
	my $tokens = $d->find( sub { $_[1]->significant } );
	$tokens = [ map { ref( $_ ), $_->content } @$tokens ];

	if ( $expected->[0] !~ /^PPI::Future::Statement/ ) {
		$expected = [ 'PPI::Future::Statement', $code, @$expected ];
	}
	my $ok = is_deeply( $tokens, $expected, main_level_line . $msg );
	if ( !$ok ) {
		diag ">>> $code -- $msg\n";
		diag one_line_explain $tokens;
		diag one_line_explain $expected;
	}

	return;
}
