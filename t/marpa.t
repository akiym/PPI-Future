#!/usr/bin/perl

# Unit testing for PPI::Future::Token::Unknown

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 23 + ( $ENV{AUTHOR_TESTING} ? 1 : 0 );
use B 'perlstring';

use PPI::Future;

test_statement(
    'use v5 ;',
    [
        'PPI::Future::Statement::Include'     => 'use v5 ;',
        'PPI::Future::Token::Word'            => 'use',
        'PPI::Future::Token::Number::Version' => 'v5',
        'PPI::Future::Token::Structure'       => ';'
    ]
);

test_statement(
    'use 5 ;',
    [
        'PPI::Future::Statement::Include' => 'use 5 ;',
        'PPI::Future::Token::Word'        => 'use',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Structure'   => ';'
    ]
);

test_statement(
    'use 5.1 ;',
    [
        'PPI::Future::Statement::Include'   => 'use 5.1 ;',
        'PPI::Future::Token::Word'          => 'use',
        'PPI::Future::Token::Number::Float' => '5.1',
        'PPI::Future::Token::Structure'     => ';'
    ]
);

test_statement(
    'use xyz () ;',
    [
        'PPI::Future::Statement::Include' => 'use xyz () ;',
        'PPI::Future::Token::Word'        => 'use',
        'PPI::Future::Token::Word'        => 'xyz',
        'PPI::Future::Structure::List'    => '()',
        'PPI::Future::Token::Structure'   => '(',
        'PPI::Future::Token::Structure'   => ')',
        'PPI::Future::Token::Structure'   => ';'
    ]
);

test_statement(
    'use v5 xyz () ;',
    [
        'PPI::Future::Statement::Include'     => 'use v5 xyz () ;',
        'PPI::Future::Token::Word'            => 'use',
        'PPI::Future::Token::Number::Version' => 'v5',
        'PPI::Future::Token::Word'            => 'xyz',
        'PPI::Future::Structure::List'        => '()',
        'PPI::Future::Token::Structure'       => '(',
        'PPI::Future::Token::Structure'       => ')',
        'PPI::Future::Token::Structure'       => ';'
    ]
);

test_statement(
    'use 5 xyz () ;',
    [
        'PPI::Future::Statement::Include' => 'use 5 xyz () ;',
        'PPI::Future::Token::Word'        => 'use',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Word'        => 'xyz',
        'PPI::Future::Structure::List'    => '()',
        'PPI::Future::Token::Structure'   => '(',
        'PPI::Future::Token::Structure'   => ')',
        'PPI::Future::Token::Structure'   => ';'
    ]
);

test_statement(
    'use 5.1 xyz () ;',
    [
        'PPI::Future::Statement::Include'   => 'use 5.1 xyz () ;',
        'PPI::Future::Token::Word'          => 'use',
        'PPI::Future::Token::Number::Float' => '5.1',
        'PPI::Future::Token::Word'          => 'xyz',
        'PPI::Future::Structure::List'      => '()',
        'PPI::Future::Token::Structure'     => '(',
        'PPI::Future::Token::Structure'     => ')',
        'PPI::Future::Token::Structure'     => ';'
    ]
);

test_statement(
    'use xyz v5 () ;',
    [
        'PPI::Future::Statement::Include'     => 'use xyz v5 () ;',
        'PPI::Future::Token::Word'            => 'use',
        'PPI::Future::Token::Word'            => 'xyz',
        'PPI::Future::Token::Number::Version' => 'v5',
        'PPI::Future::Structure::List'        => '()',
        'PPI::Future::Token::Structure'       => '(',
        'PPI::Future::Token::Structure'       => ')',
        'PPI::Future::Token::Structure'       => ';'
    ]
);

test_statement(
    'use xyz 5 () ;',
    [
        'PPI::Future::Statement::Include' => 'use xyz 5 () ;',
        'PPI::Future::Token::Word'        => 'use',
        'PPI::Future::Token::Word'        => 'xyz',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Structure::List'    => '()',
        'PPI::Future::Token::Structure'   => '(',
        'PPI::Future::Token::Structure'   => ')',
        'PPI::Future::Token::Structure'   => ';'
    ]
);

test_statement(
    'use xyz 5.1 () ;',
    [
        'PPI::Future::Statement::Include'   => 'use xyz 5.1 () ;',
        'PPI::Future::Token::Word'          => 'use',
        'PPI::Future::Token::Word'          => 'xyz',
        'PPI::Future::Token::Number::Float' => '5.1',
        'PPI::Future::Structure::List'      => '()',
        'PPI::Future::Token::Structure'     => '(',
        'PPI::Future::Token::Structure'     => ')',
        'PPI::Future::Token::Structure'     => ';'
    ]
);

test_statement(
    'use v5 xyz 5 ;',
    [
        'PPI::Future::Statement::Include'     => 'use v5 xyz 5 ;',
        'PPI::Future::Token::Word'            => 'use',
        'PPI::Future::Token::Number::Version' => 'v5',
        'PPI::Future::Token::Word'            => 'xyz',
        'PPI::Future::Token::Number'          => '5',
        'PPI::Future::Token::Structure'       => ';'
    ]
);

test_statement(
    'use 5 xyz 5 ;',
    [
        'PPI::Future::Statement::Include' => 'use 5 xyz 5 ;',
        'PPI::Future::Token::Word'        => 'use',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Word'        => 'xyz',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Structure'   => ';'
    ]
);

test_statement(
    'use 5.1 xyz 5 ;',
    [
        'PPI::Future::Statement::Include'   => 'use 5.1 xyz 5 ;',
        'PPI::Future::Token::Word'          => 'use',
        'PPI::Future::Token::Number::Float' => '5.1',
        'PPI::Future::Token::Word'          => 'xyz',
        'PPI::Future::Token::Number'        => '5',
        'PPI::Future::Token::Structure'     => ';'
    ]
);

test_statement(
    'use xyz v5 5 ;',
    [
        'PPI::Future::Statement::Include'     => 'use xyz v5 5 ;',
        'PPI::Future::Token::Word'            => 'use',
        'PPI::Future::Token::Word'            => 'xyz',
        'PPI::Future::Token::Number::Version' => 'v5',
        'PPI::Future::Token::Number'          => '5',
        'PPI::Future::Token::Structure'       => ';'
    ]
);

test_statement(
    'use xyz 5 5 ;',
    [
        'PPI::Future::Statement::Include' => 'use xyz 5 5 ;',
        'PPI::Future::Token::Word'        => 'use',
        'PPI::Future::Token::Word'        => 'xyz',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Structure'   => ';'
    ]
);

test_statement(
    'use xyz 5.1 5 ;',
    [
        'PPI::Future::Statement::Include'   => 'use xyz 5.1 5 ;',
        'PPI::Future::Token::Word'          => 'use',
        'PPI::Future::Token::Word'          => 'xyz',
        'PPI::Future::Token::Number::Float' => '5.1',
        'PPI::Future::Token::Number'        => '5',
        'PPI::Future::Token::Structure'     => ';'
    ]
);

test_statement(
    'use v5 xyz 5,5 ;',
    [
        'PPI::Future::Statement::Include'     => 'use v5 xyz 5,5 ;',
        'PPI::Future::Token::Word'            => 'use',
        'PPI::Future::Token::Number::Version' => 'v5',
        'PPI::Future::Token::Word'            => 'xyz',
        'PPI::Future::Token::Number'          => '5',
        'PPI::Future::Token::Operator'        => ',',
        'PPI::Future::Token::Number'          => '5',
        'PPI::Future::Token::Structure'       => ';'
    ]
);

test_statement(
    'use 5 xyz 5,5 ;',
    [
        'PPI::Future::Statement::Include' => 'use 5 xyz 5,5 ;',
        'PPI::Future::Token::Word'        => 'use',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Word'        => 'xyz',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Operator'    => ',',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Structure'   => ';'
    ]
);

test_statement(
    'use 5.1 xyz 5,5 ;',
    [
        'PPI::Future::Statement::Include'   => 'use 5.1 xyz 5,5 ;',
        'PPI::Future::Token::Word'          => 'use',
        'PPI::Future::Token::Number::Float' => '5.1',
        'PPI::Future::Token::Word'          => 'xyz',
        'PPI::Future::Token::Number'        => '5',
        'PPI::Future::Token::Operator'      => ',',
        'PPI::Future::Token::Number'        => '5',
        'PPI::Future::Token::Structure'     => ';'
    ]
);

test_statement(
    'use xyz v5 5,5 ;',
    [
        'PPI::Future::Statement::Include'     => 'use xyz v5 5,5 ;',
        'PPI::Future::Token::Word'            => 'use',
        'PPI::Future::Token::Word'            => 'xyz',
        'PPI::Future::Token::Number::Version' => 'v5',
        'PPI::Future::Token::Number'          => '5',
        'PPI::Future::Token::Operator'        => ',',
        'PPI::Future::Token::Number'          => '5',
        'PPI::Future::Token::Structure'       => ';'
    ]
);

test_statement(
    'use xyz 5 5,5 ;',
    [
        'PPI::Future::Statement::Include' => 'use xyz 5 5,5 ;',
        'PPI::Future::Token::Word'        => 'use',
        'PPI::Future::Token::Word'        => 'xyz',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Operator'    => ',',
        'PPI::Future::Token::Number'      => '5',
        'PPI::Future::Token::Structure'   => ';'
    ]
);

test_statement(
    'use xyz 5.1 5,5 ;',
    [
        'PPI::Future::Statement::Include'   => 'use xyz 5.1 5,5 ;',
        'PPI::Future::Token::Word'          => 'use',
        'PPI::Future::Token::Word'          => 'xyz',
        'PPI::Future::Token::Number::Float' => '5.1',
        'PPI::Future::Token::Number'        => '5',
        'PPI::Future::Token::Operator'      => ',',
        'PPI::Future::Token::Number'        => '5',
        'PPI::Future::Token::Structure'     => ';'
    ]
);

test_statement(
    'use xyz 5.1 @a ;',
    [
        'PPI::Future::Statement::Include'   => 'use xyz 5.1 @a ;',
        'PPI::Future::Token::Word'          => 'use',
        'PPI::Future::Token::Word'          => 'xyz',
        'PPI::Future::Token::Number::Float' => '5.1',
        'PPI::Future::Token::Symbol'        => '@a',
        'PPI::Future::Token::Structure'     => ';'
    ]
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
        diag "GOT: " . one_line_explain $tokens;
        diag "EXP: " . one_line_explain $expected;
    }

    return;
}
