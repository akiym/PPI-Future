#!/usr/bin/perl

# Unit testing for PPI::Future::Token::Unknown

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 776 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;
use B 'perlstring';
our %known_bad_seps;

OPERATOR_CAST: {
	my @nothing = ( '',  [] );
	my @number =  ( '1', [ 'PPI::Future::Token::Number' => '1' ] );

	my @asterisk_op =    ( '*',  [ 'PPI::Future::Token::Operator' => '*' ] );
	my @asteriskeq_op =  ( '*=', [ 'PPI::Future::Token::Operator' => '*=' ] );
	my @percent_op =     ( '%',  [ 'PPI::Future::Token::Operator' => '%' ] );
	my @percenteq_op =   ( '%=', [ 'PPI::Future::Token::Operator' => '%=' ] );
	my @ampersand_op =   ( '&',  [ 'PPI::Future::Token::Operator' => '&' ] );
	my @ampersandeq_op = ( '&=', [ 'PPI::Future::Token::Operator' => '&=' ] );
	my @exp_op =         ( '**', [ 'PPI::Future::Token::Operator' => '**' ] );

	my @asterisk_cast =  ( '*', [ 'PPI::Future::Token::Cast' => '*' ] );
	my @percent_cast =   ( '%', [ 'PPI::Future::Token::Cast' => '%' ] );
	my @ampersand_cast = ( '&', [ 'PPI::Future::Token::Cast' => '&' ] );
	my @at_cast =        ( '@',  [ 'PPI::Future::Token::Cast' => '@' ] );

	my @scalar = ( '$a', [ 'PPI::Future::Token::Symbol' => '$a' ] );
	my @list = ( '@a', [ 'PPI::Future::Token::Symbol' => '@a' ] );
	my @hash = ( '%a', [ 'PPI::Future::Token::Symbol' => '%a' ] );
	my @glob = ( '*a', [ 'PPI::Future::Token::Symbol' => '*a' ] );
	my @bareword = ( 'word', [ 'PPI::Future::Token::Word' => 'word' ] );
	my @hashctor1 = (
		'{2}',
		[
#			'PPI::Future::Structure::Constructor' => '{2}',
			'PPI::Future::Structure::Block' => '{2}',  # should be constructor
			'PPI::Future::Token::Structure' => '{',
#			'PPI::Future::Statement::Expression' => '2',
			'PPI::Future::Statement' => '2',  # should be expression
			'PPI::Future::Token::Number' => '2',
			'PPI::Future::Token::Structure' => '}',
		]
	);
	my @hashctor2 = (
		'{x=>2}',
		[
#			'PPI::Future::Structure::Constructor' => '{x=>2}',
			'PPI::Future::Structure::Block' => '{x=>2}',  # should be constructor
			'PPI::Future::Token::Structure' => '{',
#			'PPI::Future::Statement::Expression' => 'x=>2',
			'PPI::Future::Statement' => 'x=>2',  # should be expression
			'PPI::Future::Token::Word' => 'x',
			'PPI::Future::Token::Operator' => '=>',
			'PPI::Future::Token::Number' => '2',
			'PPI::Future::Token::Structure' => '}',
		]
	);
	my @hashctor3 = (
		'{$args}',
		[
#			'PPI::Future::Structure::Constructor' => '{$args}',
			'PPI::Future::Structure::Block' => '{$args}',  # should be constructor
			'PPI::Future::Token::Structure' => '{',
#			'PPI::Future::Statement::Expression' => '$args',
			'PPI::Future::Statement' => '$args',  # should be expression
			'PPI::Future::Token::Symbol' => '$args',
			'PPI::Future::Token::Structure' => '}',
		]
	);
	my @listctor = (
		'[$args]',
		[
			'PPI::Future::Structure::Constructor' => '[$args]',
			'PPI::Future::Token::Structure' => '[',
#			'PPI::Future::Statement::Expression' => '$args',
			'PPI::Future::Statement' => '$args',  # should be expression
			'PPI::Future::Token::Symbol' => '$args',
			'PPI::Future::Token::Structure' => ']',
		]
	);

	test_varying_whitespace( @number, @asterisk_op, @scalar );
	test_varying_whitespace( @number, @asterisk_op, @list );
	test_varying_whitespace( @number, @asterisk_op, @hash );
	test_varying_whitespace( @number, @asterisk_op, @hashctor1 );
	test_varying_whitespace( @number, @asterisk_op, @hashctor2 );
	test_varying_whitespace( @number, @asterisk_op, @hashctor3 );
	test_varying_whitespace( @number, @exp_op, @bareword );
	test_varying_whitespace( @number, @exp_op, @hashctor3 );  # doesn't compile, but make sure ** is operator
	test_varying_whitespace( @number, @asteriskeq_op, @bareword );
	test_varying_whitespace( @number, @asteriskeq_op, @hashctor3 );  # doesn't compile, but make sure it's an operator
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @nothing, @asterisk_cast, @scalar );
}

	test_varying_whitespace( @number, @percent_op, @scalar );
	test_varying_whitespace( @number, @percent_op, @list );
	test_varying_whitespace( @number, @percent_op, @hash );
	test_varying_whitespace( @number, @percent_op, @glob );
	test_varying_whitespace( @number, @percent_op, @hashctor1 );
	test_varying_whitespace( @number, @percent_op, @hashctor2 );
	test_varying_whitespace( @number, @percent_op, @hashctor3 );
	test_varying_whitespace( @number, @percenteq_op, @bareword );
	test_varying_whitespace( @number, @percenteq_op, @hashctor3 );  # doesn't compile, but make sure it's an operator
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @nothing, @percent_cast, @scalar );
}

	test_varying_whitespace( @number, @ampersand_op, @scalar );
	test_varying_whitespace( @number, @ampersand_op, @list );
	test_varying_whitespace( @number, @ampersand_op, @hash );

	test_varying_whitespace( @number, @ampersand_op, @glob );
	test_varying_whitespace( @number, @ampersand_op, @hashctor1 );
	test_varying_whitespace( @number, @ampersand_op, @hashctor2 );
	test_varying_whitespace( @number, @ampersand_op, @hashctor3 );
	test_varying_whitespace( @number, @ampersandeq_op, @bareword );
	test_varying_whitespace( @number, @ampersandeq_op, @hashctor3 );  # doesn't compile, but make sure it's an operator
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @nothing, @ampersand_cast, @scalar );
}

	my @plus = ( '+', [ 'PPI::Future::Token::Operator' => '+', ] );
	my @ex = ( 'x', [ 'PPI::Future::Token::Word' => 'x', ] );
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @plus, @asterisk_cast, @scalar );
	test_varying_whitespace( @plus, @asterisk_cast, @hashctor3 );
	test_varying_whitespace( @plus, @percent_cast, @scalar );
	test_varying_whitespace( @plus, @percent_cast, @hashctor3 );
	test_varying_whitespace( @plus, @ampersand_cast, @scalar );
	test_varying_whitespace( @plus, @ampersand_cast, @hashctor3 );
	test_varying_whitespace( @ex, @asterisk_cast, @scalar );
	test_varying_whitespace( @ex, @asterisk_cast, @hashctor3 );
	test_varying_whitespace( @ex, @percent_cast, @scalar );
	test_varying_whitespace( @ex, @percent_cast, @hashctor3 );
	test_varying_whitespace( @ex, @ampersand_cast, @scalar );
	test_varying_whitespace( @ex, @ampersand_cast, @hashctor3 );
}

	my @single = ( "'3'", [ 'PPI::Future::Token::Quote::Single' => "'3'", ] );
	test_varying_whitespace( @single, @asterisk_op, @scalar );
	test_varying_whitespace( @single, @asterisk_op, @hashctor3 );
	test_varying_whitespace( @single, @percent_op, @scalar );
	test_varying_whitespace( @single, @percent_op, @hashctor3 );
	test_varying_whitespace( @single, @ampersand_op, @scalar );
	test_varying_whitespace( @single, @ampersand_op, @hashctor3 );

	my @double = ( '"3"', [ 'PPI::Future::Token::Quote::Double' => '"3"', ] );
	test_varying_whitespace( @double, @asterisk_op, @scalar );
	test_varying_whitespace( @double, @asterisk_op, @hashctor3 );
	test_varying_whitespace( @double, @percent_op, @scalar );
	test_varying_whitespace( @double, @percent_op, @hashctor3 );
	test_varying_whitespace( @double, @ampersand_op, @scalar );
	test_varying_whitespace( @double, @ampersand_op, @hashctor3 );

	test_varying_whitespace( @scalar, @asterisk_op, @scalar );
	test_varying_whitespace( @scalar, @percent_op, @scalar );
	test_varying_whitespace( @scalar, @ampersand_op, @scalar );

	my @package = (
		'package foo {}',
		[
			'PPI::Future::Statement::Package' => 'package foo {}',
			'PPI::Future::Token::Word' => 'package',
			'PPI::Future::Token::Word' => 'foo',
			'PPI::Future::Structure::Block' => '{}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Token::Structure' => '}',
		]
	);
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @package, @asterisk_cast, @scalar, 1 );
	test_varying_whitespace( @package, @asterisk_cast, @hashctor3, 1 );
	test_varying_whitespace( @package, @percent_cast, @scalar, 1 );
	test_varying_whitespace( @package, @percent_cast, @hashctor3, 1 );
	test_varying_whitespace( @package, @ampersand_cast, @scalar, 1 );
	test_varying_whitespace( @package, @ampersand_cast, @hashctor3, 1 );
}
	test_varying_whitespace( @package, @at_cast, @scalar, 1 );
	test_varying_whitespace( @package, @at_cast, @listctor, 1 );

	my @sub = (
		'sub foo {}',
		[
			'PPI::Future::Statement::Sub' => 'sub foo {}',
			'PPI::Future::Token::Word' => 'sub',
			'PPI::Future::Token::Word' => 'foo',
			'PPI::Future::Structure::Block' => '{}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Token::Structure' => '}',
		]
	);
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @sub, @asterisk_cast, @scalar, 1 );
	test_varying_whitespace( @sub, @asterisk_cast, @hashctor3, 1 );
	test_varying_whitespace( @sub, @percent_cast, @scalar, 1 );
	test_varying_whitespace( @sub, @percent_cast, @hashctor3, 1 );
	test_varying_whitespace( @sub, @ampersand_cast, @scalar, 1 );
	test_varying_whitespace( @sub, @ampersand_cast, @hashctor3, 1 );
}
	test_varying_whitespace( @sub, @at_cast, @scalar, 1 );
	test_varying_whitespace( @sub, @at_cast, @listctor, 1 );

	my @statement = (
		'1;',
		[
			'PPI::Future::Statement' => '1;',
			'PPI::Future::Token::Number' => '1',
			'PPI::Future::Token::Structure' => ';',
		]
	);
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @statement, @asterisk_cast, @scalar, 1 );
	test_varying_whitespace( @statement, @asterisk_cast, @hashctor3, 1 );
	test_varying_whitespace( @statement, @percent_cast, @scalar, 1 );
	test_varying_whitespace( @statement, @percent_cast, @hashctor3, 1 );
	test_varying_whitespace( @statement, @ampersand_cast, @scalar, 1 );
	test_varying_whitespace( @statement, @ampersand_cast, @hashctor3, 1 );
}
	test_varying_whitespace( @statement, @at_cast, @scalar, 1 );
	test_varying_whitespace( @statement, @at_cast, @listctor, 1 );

	my @label = (
		'LABEL:',
		[
			'PPI::Future::Statement::Compound' => 'LABEL:',
			'PPI::Future::Token::Label' => 'LABEL:',
		]
	);
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @label, @asterisk_cast, @scalar, 1 );
	test_varying_whitespace( @label, @asterisk_cast, @hashctor3, 1 );
	test_varying_whitespace( @label, @percent_cast, @scalar, 1 );
	test_varying_whitespace( @label, @percent_cast, @hashctor3, 1 );
	test_varying_whitespace( @label, @ampersand_cast, @scalar, 1 );
	test_varying_whitespace( @label, @ampersand_cast, @hashctor3, 1 );
}
	test_varying_whitespace( @label, @at_cast, @scalar, 1 );
	test_varying_whitespace( @label, @at_cast, @listctor, 1 );

	my @map = (
		'map {1}',
		[
			'PPI::Future::Token::Word' => 'map',
			'PPI::Future::Structure::Block' => '{1}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement' => '1',
			'PPI::Future::Token::Number' => '1',
			'PPI::Future::Token::Structure' => '}',
		]
	);
{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( @map, @asterisk_cast, @scalar );
	test_varying_whitespace( @map, @asterisk_cast, @hashctor3 );
	test_varying_whitespace( @map, @percent_cast, @scalar );
	test_varying_whitespace( @map, @percent_cast, @hashctor3 );
	test_varying_whitespace( @map, @ampersand_cast, @scalar );
	test_varying_whitespace( @map, @ampersand_cast, @hashctor3 );
}
	test_varying_whitespace( @map, @at_cast, @scalar );
	test_varying_whitespace( @map, @at_cast, @listctor );

	my @evalblock = (
		'eval {2}',
		[
			'PPI::Future::Token::Word' => 'eval',
			'PPI::Future::Structure::Block' => '{2}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement' => '2',
			'PPI::Future::Token::Number' => '2',
			'PPI::Future::Token::Structure' => '}',
		]
	);
	test_varying_whitespace( @evalblock, @asterisk_op, @scalar );
	test_varying_whitespace( @double, @asterisk_op, @hashctor3 );
	test_varying_whitespace( @evalblock, @percent_op, @scalar );
	test_varying_whitespace( @evalblock, @percent_op, @hashctor3 );
	test_varying_whitespace( @evalblock, @ampersand_op, @scalar );
	test_varying_whitespace( @evalblock, @ampersand_op, @hashctor3 );

	my @evalstring = (
		'eval "2"',
		[
			'PPI::Future::Token::Word' => 'eval',
			'PPI::Future::Token::Quote::Double' => '"2"',
		]
	);
	test_varying_whitespace( @evalstring, @asterisk_op, @scalar );
	test_varying_whitespace( @evalstring, @asterisk_op, @hashctor3 );
	test_varying_whitespace( @evalstring, @percent_op, @scalar );
	test_varying_whitespace( @evalstring, @percent_op, @hashctor3 );
	test_varying_whitespace( @evalstring, @ampersand_op, @scalar );
	test_varying_whitespace( @evalstring, @ampersand_op, @hashctor3 );

	my @curly_subscript1 = (
		'$y->{x}',
		[
			'PPI::Future::Token::Symbol' => '$y',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Structure::Subscript' => '{x}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement::Expression' => 'x',
			'PPI::Future::Token::Word' => 'x',
			'PPI::Future::Token::Structure' => '}',
		]
	);
	my @curly_subscript2 = (
		'$y->{z}{x}',
		[
			'PPI::Future::Token::Symbol' => '$y',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Structure::Subscript' => '{z}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement::Expression' => 'z',
			'PPI::Future::Token::Word' => 'z',
			'PPI::Future::Token::Structure' => '}',
			'PPI::Future::Structure::Subscript' => '{x}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement::Expression' => 'x',
			'PPI::Future::Token::Word' => 'x',
			'PPI::Future::Token::Structure' => '}',
		]
	);
	my @curly_subscript3 = (
		'$y->[z]{x}',
		[
			'PPI::Future::Token::Symbol' => '$y',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Structure::Subscript' => '[z]',
			'PPI::Future::Token::Structure' => '[',
			'PPI::Future::Statement::Expression' => 'z',
			'PPI::Future::Token::Word' => 'z',
			'PPI::Future::Token::Structure' => ']',
			'PPI::Future::Structure::Subscript' => '{x}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement::Expression' => 'x',
			'PPI::Future::Token::Word' => 'x',
			'PPI::Future::Token::Structure' => '}',
		]
	);
	my @square_subscript1 = (
		'$y->[x]',
		[
			'PPI::Future::Token::Symbol' => '$y',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Structure::Subscript' => '[x]',
			'PPI::Future::Token::Structure' => '[',
			'PPI::Future::Statement::Expression' => 'x',
			'PPI::Future::Token::Word' => 'x',
			'PPI::Future::Token::Structure' => ']',
		]
	);

	test_varying_whitespace( @curly_subscript1, @asterisk_op, @scalar );
	test_varying_whitespace( @curly_subscript1, @percent_op, @scalar );
	test_varying_whitespace( @curly_subscript1, @ampersand_op, @scalar );
	test_varying_whitespace( @curly_subscript2, @asterisk_op, @scalar );
	test_varying_whitespace( @curly_subscript2, @percent_op, @scalar );
	test_varying_whitespace( @curly_subscript2, @ampersand_op, @scalar );
	test_varying_whitespace( @curly_subscript3, @asterisk_op, @scalar );
	test_varying_whitespace( @curly_subscript3, @percent_op, @scalar );
	test_varying_whitespace( @curly_subscript3, @ampersand_op, @scalar );
	test_varying_whitespace( @square_subscript1, @asterisk_op, @scalar );
	test_varying_whitespace( @square_subscript1, @percent_op, @scalar );
	test_varying_whitespace( @square_subscript1, @ampersand_op, @scalar );

{
	local %known_bad_seps = map { $_ => 1 } qw( space );
	test_varying_whitespace( 'keys', [ 'PPI::Future::Token::Word' => 'keys' ],     @percent_cast, @scalar );
	test_varying_whitespace( 'values', [ 'PPI::Future::Token::Word' => 'values' ], @percent_cast, @scalar );

	test_varying_whitespace( 'keys', [ 'PPI::Future::Token::Word' => 'keys' ],     @percent_cast, @hashctor3 );
	test_varying_whitespace( 'values', [ 'PPI::Future::Token::Word' => 'values' ], @percent_cast, @hashctor3 );
}

	test_statement(
		'} *$a', # unbalanced '}' before '*', arbitrary decision
		[
			'PPI::Future::Statement::UnmatchedBrace' => '}',
			'PPI::Future::Token::Structure' => '}',
			'PPI::Future::Statement' => '*$a',
			'PPI::Future::Token::Operator' => '*',
			'PPI::Future::Token::Symbol' => '$a',
		]
	);

	test_statement(
		'$bar = \%*$foo', # multiple consecutive casts
		[
			'PPI::Future::Token::Symbol' => '$bar',
			'PPI::Future::Token::Operator' => '=',
			'PPI::Future::Token::Cast' => '\\',
			'PPI::Future::Token::Cast' => '%',
			'PPI::Future::Token::Cast' => '*',
			'PPI::Future::Token::Symbol' => '$foo',
		]
	);

	test_statement(
		'$#tmp*$#tmp2',
		[
			'PPI::Future::Token::ArrayIndex' => '$#tmp',
			'PPI::Future::Token::Operator' => '*',
			'PPI::Future::Token::ArrayIndex' => '$#tmp2',
		]
	);

	test_statement(
		'[ %{$req->parameters} ]',  # preceded by '['
		[
			'PPI::Future::Structure::Constructor' => '[ %{$req->parameters} ]',
			'PPI::Future::Token::Structure' => '[',
			'PPI::Future::Statement' => '%{$req->parameters}',
			'PPI::Future::Token::Cast' => '%',
			'PPI::Future::Structure::Block' => '{$req->parameters}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement' => '$req->parameters',
			'PPI::Future::Token::Symbol' => '$req',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Word' => 'parameters',
			'PPI::Future::Token::Structure' => '}',
			'PPI::Future::Token::Structure' => ']',
		]
	);
	test_statement(
		'( %{$req->parameters} )',  # preceded by '('
		[
			'PPI::Future::Structure::List' => '( %{$req->parameters} )',
			'PPI::Future::Token::Structure' => '(',
			'PPI::Future::Statement::Expression' => '%{$req->parameters}',
			'PPI::Future::Token::Cast' => '%',
			'PPI::Future::Structure::Block' => '{$req->parameters}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement' => '$req->parameters',
			'PPI::Future::Token::Symbol' => '$req',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Word' => 'parameters',
			'PPI::Future::Token::Structure' => '}',
			'PPI::Future::Token::Structure' => ')',
		]
	);

	test_statement(
		'++$i%$f',  # '%' wrongly a cast through 1.220.
		[
			'PPI::Future::Statement' => '++$i%$f',
			'PPI::Future::Token::Operator' => '++',
			'PPI::Future::Token::Symbol' => '$i',
			'PPI::Future::Token::Operator' => '%',
			'PPI::Future::Token::Symbol' => '$f',
		]
	);

	# Postfix dereference

	test_statement(
		'$foo->$*',
		[
			'PPI::Future::Statement' => '$foo->$*',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '$*',
		]
	);

	test_statement(
		'$foo->@*',
		[
			'PPI::Future::Statement' => '$foo->@*',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '@*',
		]
	);

	test_statement(
		'$foo->$#*',
		[
			'PPI::Future::Statement' => '$foo->$#*',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '$#*',
		]
	);

	test_statement(
		'$foo->%*',
		[
			'PPI::Future::Statement' => '$foo->%*',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '%*',
		]
	);

	test_statement(
		'$foo->&*',
		[
			'PPI::Future::Statement' => '$foo->&*',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '&*',
		]
	);

	test_statement(
		'$foo->**',
		[
			'PPI::Future::Statement' => '$foo->**',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '**',
		]
	);

	test_statement(
		'$foo->@[0]',
		[
			'PPI::Future::Statement' => '$foo->@[0]',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '@',
			'PPI::Future::Structure::Subscript' => '[0]',
			'PPI::Future::Token::Structure' => '[',
			'PPI::Future::Statement::Expression' => '0',
			'PPI::Future::Token::Number' => '0',
			'PPI::Future::Token::Structure' => ']',
		]
	);

	test_statement(
		'$foo->@{0}',
		[
			'PPI::Future::Statement' => '$foo->@{0}',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '@',
			'PPI::Future::Structure::Subscript' => '{0}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement::Expression' => '0',
			'PPI::Future::Token::Number' => '0',
			'PPI::Future::Token::Structure' => '}',
		]
	);

	test_statement(
		'$foo->%["bar"]',
		[
			'PPI::Future::Statement' => '$foo->%["bar"]',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '%',
			'PPI::Future::Structure::Subscript' => '["bar"]',
			'PPI::Future::Token::Structure' => '[',
			'PPI::Future::Statement::Expression' => '"bar"',
			'PPI::Future::Token::Quote::Double' => '"bar"',
			'PPI::Future::Token::Structure' => ']',
		]
	);

	test_statement(
		'$foo->%{bar}',
		[
			'PPI::Future::Statement' => '$foo->%{bar}',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '%',
			'PPI::Future::Structure::Subscript' => '{bar}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement::Expression' => 'bar',
			'PPI::Future::Token::Word' => 'bar',
			'PPI::Future::Token::Structure' => '}',
		]
	);

	test_statement(
		'$foo->*{CODE}',
		[
			'PPI::Future::Statement' => '$foo->*{CODE}',
			'PPI::Future::Token::Symbol' => '$foo',
			'PPI::Future::Token::Operator' => '->',
			'PPI::Future::Token::Cast' => '*',
			'PPI::Future::Structure::Subscript' => '{CODE}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement::Expression' => 'CODE',
			'PPI::Future::Token::Word' => 'CODE',
			'PPI::Future::Token::Structure' => '}',
		]
	);

{   # these need to be fixed in PPI::Future::Lexer->_statement, fixing these will break other tests that need to be changed
	local $TODO = "clarify type of statement in constructor";
	test_statement(
		'[$args]',
		[
			'PPI::Future::Structure::Constructor' => '[$args]',
			'PPI::Future::Token::Structure' => '[',
			'PPI::Future::Statement::Expression' => '$args',
			'PPI::Future::Token::Symbol' => '$args',
			'PPI::Future::Token::Structure' => ']',
		]
	);
	test_statement(
		'{$args}',
		[
			'PPI::Future::Structure::Constructor' => '{$args}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement::Expression' => '$args',
			'PPI::Future::Token::Symbol' => '$args',
			'PPI::Future::Token::Structure' => '}',
		]
	);
	local $TODO = "hash constructors are currently mistaken for blocks";
	test_statement(
		'1 * {2}',
		[
			'PPI::Future::Token::Number' => '1' ,
			'PPI::Future::Token::Operator' => '*',
			'PPI::Future::Structure::Constructor' => '{2}',
			'PPI::Future::Token::Structure' => '{',
			'PPI::Future::Statement' => '2',
			'PPI::Future::Token::Number' => '2',
			'PPI::Future::Token::Structure' => '}',
		]
	)
}
}

sub one_line_explain {
	my ($data) = @_;
	my @explain = explain $data;
	s/\n//g for @explain;
	return join "", @explain;
}

sub main_level_line {
	return "" if not $TODO;
	my @outer_final;
	my $level = 0;
	while ( my @outer = caller($level++) ) {
		@outer_final = @outer;
	}
	return "l $outer_final[2] - ";
}

sub test_statement {
	local $Test::Builder::Level = $Test::Builder::Level+1;
	my ( $code, $expected, $msg ) = @_;
	$msg = perlstring $code if !defined $msg;

	my $d = PPI::Future::Document->new( \$code );
	my $tokens = $d->find( sub { $_[1]->significant } );
	$tokens = [ map { ref($_), $_->content } @$tokens ];

	if ( $expected->[0] !~ /^PPI::Future::Statement/ ) {
		$expected = [ 'PPI::Future::Statement', $code, @$expected ];
	}
	my $ok = is_deeply( $tokens, $expected, main_level_line.$msg );
	if ( !$ok ) {
		diag ">>> $code -- $msg\n";
		diag one_line_explain $tokens;
		diag one_line_explain $expected;
	}

	return;
}

sub test_varying_whitespace {
	local $Test::Builder::Level = $Test::Builder::Level+1;
	my( $left, $left_expected, $cast_or_op, $cast_or_op_expected, $right, $right_expected, $right_is_statement ) = @_;

{
	local $TODO = "known bug" if $known_bad_seps{null};
	assemble_and_test( "",  $left, $left_expected, $cast_or_op, $cast_or_op_expected, $right, $right_expected, $right_is_statement );
}
{
	local $TODO = "known bug" if $known_bad_seps{space};
	assemble_and_test( " ", $left, $left_expected, $cast_or_op, $cast_or_op_expected, $right, $right_expected, $right_is_statement );
	assemble_and_test( "\t", $left, $left_expected, $cast_or_op, $cast_or_op_expected, $right, $right_expected, $right_is_statement );
	assemble_and_test( "\n", $left, $left_expected, $cast_or_op, $cast_or_op_expected, $right, $right_expected, $right_is_statement );
	assemble_and_test( "\f", $left, $left_expected, $cast_or_op, $cast_or_op_expected, $right, $right_expected, $right_is_statement );
}
	local $TODO = "\\r is being nuked to \\n, need to fix that first";
	assemble_and_test( "\r", $left, $left_expected, $cast_or_op, $cast_or_op_expected, $right, $right_expected, $right_is_statement );  # fix this -- different breakage from \n, \t, etc.

	return;
}


sub assemble_and_test {
	local $Test::Builder::Level = $Test::Builder::Level+1;
	my( $whitespace, $left, $left_expected, $cast_or_op, $cast_or_op_expected, $right, $right_expected, $right_is_statement ) = @_;

	my $code = $left eq '' ? "$cast_or_op$whitespace$right" : "$left$whitespace$cast_or_op$whitespace$right";

	if ( $right_is_statement ) {
		$cast_or_op_expected = [ 'PPI::Future::Statement' => "$cast_or_op$whitespace$right", @$cast_or_op_expected ];
	}

	my $expected = [
		@$left_expected,
		@$cast_or_op_expected,
		@$right_expected,
	];
	test_statement( $code, $expected );

	return;
}
