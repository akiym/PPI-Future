#!/usr/bin/perl

# Unit testing for PPI::Future::Token::Operator

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 1146 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;
use PPI::Future::Singletons qw' %OPERATOR %KEYWORDS ';

FIND_ONE_OP: {
	my $source = '$a = .987;';
	my $doc = PPI::Future::Document->new( \$source );
	isa_ok( $doc, 'PPI::Future::Document', "parsed '$source'" );
	my $ops = $doc->find( 'Token::Number::Float' );
	is( ref $ops, 'ARRAY', "found number" );
	is( @$ops, 1, "number found exactly once" );
	is( $ops->[0]->content(), '.987', "text matches" );

	$ops = $doc->find( 'Token::Operator' );
	is( ref $ops, 'ARRAY', "operator = found operators in number test" );
	is( @$ops, 1, "operator = found exactly once in number test" );
}


PARSE_ALL_OPERATORS: {
	foreach my $op ( sort keys %OPERATOR ) {
		my $source = $op eq '<>' ? '<>;' : "\$foo $op 2;";
		my $doc = PPI::Future::Document->new( \$source );
		isa_ok( $doc, 'PPI::Future::Document', "operator $op parsed '$source'" );
		my $ops = $doc->find( $op eq '<>' ? 'Token::QuoteLike::Readline' : 'Token::Operator' );
		is( ref $ops, 'ARRAY', "operator $op found operators" );
		is( @$ops, 1, "operator $op found exactly once" );
		is( $ops->[0]->content(), $op, "operator $op operator text matches" );
	}
}


OPERATOR_X: {
	my @tests = (
		{
			desc => 'generic bareword with integer',  # github #133
			code => 'bareword x 3',
			expected => [
				'PPI::Future::Token::Word' => 'bareword',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'generic bareword with integer run together',  # github #133
			code => 'bareword x3',
			expected => [
				'PPI::Future::Token::Word' => 'bareword',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'preceding word looks like a force but is not',  # github #133
			code => '$a->package x3',
			expected => [
				'PPI::Future::Token::Symbol' => '$a',
				'PPI::Future::Token::Operator' => '->',
				'PPI::Future::Token::Word' => 'package',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'method with method',
			code => 'sort { $a->package cmp $b->package } ();',
			expected => [
				'PPI::Future::Token::Word' => 'sort',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Structure::Block'=> '{ $a->package cmp $b->package }',
				'PPI::Future::Token::Structure'=> '{',
				'PPI::Future::Token::Whitespace'=> ' ',
				'PPI::Future::Statement'=> '$a->package cmp $b->package',
				'PPI::Future::Token::Symbol'=> '$a',
				'PPI::Future::Token::Operator'=> '->',
				'PPI::Future::Token::Word'=> 'package',
				'PPI::Future::Token::Whitespace'=> ' ',
				'PPI::Future::Token::Operator'=> 'cmp',
				'PPI::Future::Token::Whitespace'=> ' ',
				'PPI::Future::Token::Symbol'=> '$b',
				'PPI::Future::Token::Operator'=> '->',
				'PPI::Future::Token::Word'=> 'package',
				'PPI::Future::Token::Whitespace'=> ' ',
				'PPI::Future::Token::Structure'=> '}',
				'PPI::Future::Token::Whitespace'=> ' ',
				'PPI::Future::Structure::List'=> '()',
				'PPI::Future::Token::Structure'=> '(',
				'PPI::Future::Token::Structure'=> ')',
				'PPI::Future::Token::Structure'=> ';'
			],
		},
		{
			desc => 'method with integer',
			code => 'c->d x 3',
			expected => [
				'PPI::Future::Token::Word' => 'c',
				'PPI::Future::Token::Operator' => '->',
				'PPI::Future::Token::Word' => 'd',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'integer with integer',
			code => '1 x 3',
			expected => [
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'string with integer',
			code => '"y" x 3',
			expected => [
				'PPI::Future::Token::Quote::Double' => '"y"',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'string with integer',
			code => 'qq{y} x 3',
			expected => [
				'PPI::Future::Token::Quote::Interpolate' => 'qq{y}',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'string no whitespace with integer',
			code => '"y"x 3',
			expected => [
				'PPI::Future::Token::Quote::Double' => '"y"',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'variable with integer',
			code => '$a x 3',
			expected => [
				'PPI::Future::Token::Symbol' => '$a',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'variable with no whitespace integer',
			code => '$a x3',
			expected => [
				'PPI::Future::Token::Symbol' => '$a',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'variable, post ++, x, no whitespace anywhere',
			code => '$a++x3',
			expected => [
				'PPI::Future::Token::Symbol' => '$a',
				'PPI::Future::Token::Operator' => '++',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'double quote, no whitespace',
			code => '"y"x 3',
			expected => [
				'PPI::Future::Token::Quote::Double' => '"y"',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'single quote, no whitespace',
			code => "'y'x 3",
			expected => [
				'PPI::Future::Token::Quote::Single' => "'y'",
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'parens, no whitespace, number',
			code => "(5)x 3",
			expected => [
				'PPI::Future::Structure::List' => '(5)',
				'PPI::Future::Token::Structure' => '(',
				'PPI::Future::Statement::Expression' => '5',
				'PPI::Future::Token::Number' => '5',
				'PPI::Future::Token::Structure' => ')',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'number following x is hex',
			code => "1x0x1",
			expected => [
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number::Hex' => '0x1',
			],
		},
		{
			desc => 'x followed by symbol',
			code => '1 x$y',
			expected => [
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Symbol' => '$y',
			],
		},
		{
			desc => 'x= with no trailing whitespace, symbol',
			code => '$z x=3',
			expected => [
				'PPI::Future::Token::Symbol' => '$z',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x=',
				'PPI::Future::Token::Number' => '3',
			],
		},
		{
			desc => 'x= with no trailing whitespace, symbol',
			code => '$z x=$y',
			expected => [
				'PPI::Future::Token::Symbol' => '$z',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x=',
				'PPI::Future::Token::Symbol' => '$y',
			],
		},
		{
			desc => 'x plus whitespace on the left of => that is not the first token in the doc',
			code => '1;x =>1;',
			expected => [
				'PPI::Future::Statement' => '1;',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ';',
				'PPI::Future::Statement' => 'x =>1;',
				'PPI::Future::Token::Word' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ';',
			],
		},
		{
			desc => 'x on the left of => that is not the first token in the doc',
			code => '1;x=>1;',
			expected => [
				'PPI::Future::Statement' => '1;',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ';',
				'PPI::Future::Statement' => 'x=>1;',
				'PPI::Future::Token::Word' => 'x',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ';',
			],
		},
		{
			desc => 'x on the left of => that is not the first token in the doc',
			code => '$hash{x}=1;',
			expected => [
				'PPI::Future::Token::Symbol' => '$hash',
				'PPI::Future::Structure::Subscript' => '{x}',
				'PPI::Future::Token::Structure' => '{',
				'PPI::Future::Statement::Expression' => 'x',
				'PPI::Future::Token::Word' => 'x',
				'PPI::Future::Token::Structure' => '}',
				'PPI::Future::Token::Operator' => '=',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ';',
			],
		},
		{
			desc => 'x plus whitespace on the left of => is not an operator',
			code => 'x =>1',
			expected => [
				'PPI::Future::Token::Word' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Number' => '1',
			],
		},
		{
			desc => 'x immediately followed by => should not be mistaken for x=',
			code => 'x=>1',
			expected => [
				'PPI::Future::Token::Word' => 'x',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Number' => '1',
			],
		},
		{
			desc => 'xx on left of => not mistaken for an x operator',
			code => 'xx=>1',
			expected => [
				'PPI::Future::Token::Word' => 'xx',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Number' => '1',
			],
		},
		{
			desc => 'x right of => is not an operator',
			code => '1=>x',
			expected => [
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Word' => 'x',
			],
		},
		{
			desc => 'xor right of => is an operator',
			code => '1=>xor',
			expected => [
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Operator' => 'xor',
			],
		},
		{
			desc => 'RT 37892: list as arg to x operator 1',
			code => '(1) x 6',
			expected => [
				'PPI::Future::Structure::List' => '(1)',
				'PPI::Future::Token::Structure' => '(',
				'PPI::Future::Statement::Expression' => '1',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ')',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '6',
			],
		},
		{
			desc => 'RT 37892: list as arg to x operator 2',
			code => '(1) x6',
			expected => [
				'PPI::Future::Structure::List' => '(1)',
				'PPI::Future::Token::Structure' => '(',
				'PPI::Future::Statement::Expression' => '1',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ')',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '6',
			],
		},
		{
			desc => 'RT 37892: list as arg to x operator 3',
			code => '(1)x6',
			expected => [
				'PPI::Future::Structure::List' => '(1)',
				'PPI::Future::Token::Structure' => '(',
				'PPI::Future::Statement::Expression' => '1',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ')',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '6',
			],
		},
		{
			desc => 'RT 37892: x following function is operator',
			code => 'foo()x6',
			expected => [
				'PPI::Future::Token::Word' => 'foo',
				'PPI::Future::Structure::List' => '()',
				'PPI::Future::Token::Structure' => '(',
				'PPI::Future::Token::Structure' => ')',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '6',
			],
		},
		{
			desc => 'RT 37892: list as arg to x operator 4',
			code => 'qw(1)x6',
			expected => [
				'PPI::Future::Token::QuoteLike::Words' => 'qw(1)',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '6',
			],
		},
		{
			desc => 'RT 37892: list as arg to x operator 5',
			code => 'qw<1>x6',
			expected => [
				'PPI::Future::Token::QuoteLike::Words' => 'qw<1>',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '6',
			],
		},
		{
			desc => 'RT 37892: listref as arg to x operator 6',
			code => '[1]x6',
			expected => [
				'PPI::Future::Structure::Constructor' => '[1]',
				'PPI::Future::Token::Structure' => '[',
				'PPI::Future::Statement' => '1',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ']',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Number' => '6',
			],
		},
		{
			desc => 'x followed by sigil $ that is not also an operator',
			code => '1x$bar',
			expected => [
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Symbol' => '$bar',
			],
		},
		{
			desc => 'x followed by sigil @ that is not also an operator',
			code => '1x@bar',
			expected => [
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Operator' => 'x',
				'PPI::Future::Token::Symbol' => '@bar',
			],
		},
		{
			desc => 'sub name /^x/',
			code => 'sub xyzzy : _5x5 {1;}',
			expected => [
				'PPI::Future::Statement::Sub' => 'sub xyzzy : _5x5 {1;}',
				'PPI::Future::Token::Word' => 'sub',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Word' => 'xyzzy',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => ':',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Attribute' => '_5x5',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Structure::Block' => '{1;}',
				'PPI::Future::Token::Structure' => '{',
				'PPI::Future::Statement' => '1;',
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Structure' => ';',
				'PPI::Future::Token::Structure' => '}',
			]
		},
		{
			desc => 'label plus x',
			code => 'LABEL: x64',
			expected => [
				'PPI::Future::Statement::Compound' => 'LABEL:',
				'PPI::Future::Token::Label' => 'LABEL:',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Statement' => 'x64',
				'PPI::Future::Token::Word' => 'x64',
			]
		},
	);

	# Exhaustively test when a preceding operator implies following
	# 'x' is word not an operator. This detects the regression in
	# which '$obj->x86_convert()' was being parsed as an x
	# operator.
	my %operators = (
		%OPERATOR,
		map { $_ => 1 } qw( -r -w -x -o -R -W -X -O -e -z -s -f -d -l -p -S -b -c -t -u -g -k -T -B -M -A -C )
	);
	# Don't try to test operators for which PPI::Future currently (1.215)
	# doesn't recognize when they're followed immediately by a word.
	# E.g.:
	#     sub x3 {15;} my $z=6; print $z&x3;
	#     sub x3 {3;} my $z=2; print $z%x3;
	delete $operators{'&'};
	delete $operators{'%'};
	delete $operators{'*'};
	foreach my $operator ( keys %operators ) {

		my $code = '';
		my @expected;

		if ( $operator =~ /^\w/ ) {
			$code .= '$a ';
			push @expected, ( 'PPI::Future::Token::Symbol' => '$a' );
			push @expected, ( 'PPI::Future::Token::Whitespace' => ' ' );
		}
		elsif ( $operator !~ /^-\w/ ) {  # filetest operators
			$code .= '$a';
			push @expected, ( 'PPI::Future::Token::Symbol' => '$a' );
		}

		$code .= $operator;
		push @expected, ( ($operator eq '<>' ? 'PPI::Future::Token::QuoteLike::Readline' : 'PPI::Future::Token::Operator') => $operator );

		if ( $operator =~ /\w$/ || $operator eq '<<' ) {  # want << operator, not heredoc
			$code .= ' ';
			push @expected, ( 'PPI::Future::Token::Whitespace' => ' ' );
		}
		$code .= 'x3';
		my $desc;
		if ( $operator eq '--' || $operator eq '++' || $operator eq '<>' ) {
			push @expected, ( 'PPI::Future::Token::Operator' => 'x' );
			push @expected, ( 'PPI::Future::Token::Number' => '3' );
			$desc = "operator $operator does not imply following 'x' is a word";
		}
		else {
			push @expected, ( 'PPI::Future::Token::Word' => 'x3' );
			$desc = "operator $operator implies following 'x' is a word";
		}

		push @tests, { desc => $desc, code => $code, expected => \@expected };
	}


	# Test that Perl builtins known to have a null prototype do not
	# force a following 'x' to be a word.
	my %noprotos = map { $_ => 1 } qw(
		endgrent
		endhostent
		endnetent
		endprotoent
		endpwent
		endservent
		fork
		getgrent
		gethostent
		getlogin
		getnetent
		getppid
		getprotoent
		getpwent
		getservent
		setgrent
		setpwent
		time
		times
		wait
		wantarray
		__SUB__
	);
	foreach my $noproto ( keys %noprotos ) {
		my $code = "$noproto x3";
		my @expected = (
			'PPI::Future::Token::Word' => $noproto,
			'PPI::Future::Token::Whitespace' => ' ',
			'PPI::Future::Token::Operator' => 'x',
			'PPI::Future::Token::Number' => '3',
		);
		my $desc = "builtin $noproto does not force following x to be a word";
		push @tests, { desc => "builtin $noproto does not force following x to be a word", code => $code, expected => \@expected };
	}

	foreach my $test ( @tests ) {
		my $d = PPI::Future::Document->new( \$test->{code} );
		my $tokens = $d->find( sub { 1; } );
		$tokens = [ map { ref($_), $_->content() } @$tokens ];
		my $expected = $test->{expected};
		if ( $expected->[0] !~ /^PPI::Future::Statement/ ) {
			unshift @$expected, 'PPI::Future::Statement', $test->{code};
		}
		my $ok = is_deeply( $tokens, $expected, $test->{desc} );
		if ( !$ok ) {
			diag "$test->{code} ($test->{desc})\n";
			diag explain $tokens;
			diag explain $test->{expected};
		}
	}
}


OPERATOR_FAT_COMMA: {
	my @tests = (
		{
			desc => 'integer with integer',
			code => '1 => 2',
			expected => [
				'PPI::Future::Token::Number' => '1',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '2',
			],
		},
		{
			desc => 'word with integer',
			code => 'foo => 2',
			expected => [
				'PPI::Future::Token::Word' => 'foo',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '2',
			],
		},
		{
			desc => 'dashed word with integer',
			code => '-foo => 2',
			expected => [
				'PPI::Future::Token::Word' => '-foo',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Whitespace' => ' ',
				'PPI::Future::Token::Number' => '2',
			],
		},
		( map { {
			desc=>$_,
			code=>"$_=>2",
			expected=>[
				'PPI::Future::Token::Word' => $_,
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Number' => '2',
			]
		} } keys %KEYWORDS ),
		( map { {
			desc=>$_,
			code=>"($_=>2)",
			expected=>[
				'PPI::Future::Structure::List' => "($_=>2)",
				'PPI::Future::Token::Structure' => '(',
				'PPI::Future::Statement::Expression' => "$_=>2",
				'PPI::Future::Token::Word' => $_,
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Number' => '2',
				'PPI::Future::Token::Structure' => ')',
			]
		} } keys %KEYWORDS ),
		( map { {
			desc=>$_,
			code=>"{$_=>2}",
			expected=>[
				'PPI::Future::Structure::Constructor' => "{$_=>2}",
				'PPI::Future::Token::Structure' => '{',
				'PPI::Future::Statement::Expression' => "$_=>2",
				'PPI::Future::Token::Word' => $_,
				'PPI::Future::Token::Operator' => '=>',
				'PPI::Future::Token::Number' => '2',
				'PPI::Future::Token::Structure' => '}',
			]
		} } keys %KEYWORDS ),
	);

	for my $test ( @tests ) {
		my $code = $test->{code};

		my $d = PPI::Future::Document->new( \$test->{code} );
		my $tokens = $d->find( sub { 1; } );
		$tokens = [ map { ref($_), $_->content() } @$tokens ];
		my $expected = $test->{expected};
		if ( $expected->[0] !~ /^PPI::Future::Statement/ ) {
			unshift @$expected, 'PPI::Future::Statement', $test->{code};
		}
		my $ok = is_deeply( $tokens, $expected, $test->{desc} );
		if ( !$ok ) {
			diag "$test->{code} ($test->{desc})\n";
			diag explain $tokens;
			diag explain $test->{expected};
		}
	}
}

