#!/usr/bin/perl

# Unit testing for PPI::Future::Statement

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 22 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;


SPECIALIZED: {
	my $Document = PPI::Future::Document->new(\<<'END_PERL');
package Foo;
use strict;
;
while (1) { last; }
BEGIN { }
sub foo { }
state $x;
$x = 5;
END_PERL

	isa_ok( $Document, 'PPI::Future::Document' );

	my $statements = $Document->find('Statement');
	is( scalar @{$statements}, 10, 'Found the 10 test statements' );

	isa_ok( $statements->[0], 'PPI::Future::Statement::Package',    'Statement 1: isa Package'            );
	ok( $statements->[0]->specialized,                      'Statement 1: is specialized'         );
	isa_ok( $statements->[1], 'PPI::Future::Statement::Include',    'Statement 2: isa Include'            );
	ok( $statements->[1]->specialized,                      'Statement 2: is specialized'         );
	isa_ok( $statements->[2], 'PPI::Future::Statement::Null',       'Statement 3: isa Null'               );
	ok( $statements->[2]->specialized,                      'Statement 3: is specialized'         );
	isa_ok( $statements->[3], 'PPI::Future::Statement::Compound',   'Statement 4: isa Compound'           );
	ok( $statements->[3]->specialized,                      'Statement 4: is specialized'         );
	isa_ok( $statements->[4], 'PPI::Future::Statement::Expression', 'Statement 5: isa Expression'         );
	ok( $statements->[4]->specialized,                      'Statement 5: is specialized'         );
	isa_ok( $statements->[5], 'PPI::Future::Statement::Break',      'Statement 6: isa Break'              );
	ok( $statements->[5]->specialized,                      'Statement 6: is specialized'         );
	isa_ok( $statements->[6], 'PPI::Future::Statement::Scheduled',  'Statement 7: isa Scheduled'          );
	ok( $statements->[6]->specialized,                      'Statement 7: is specialized'         );
	isa_ok( $statements->[7], 'PPI::Future::Statement::Sub',        'Statement 8: isa Sub'                );
	ok( $statements->[7]->specialized,                      'Statement 8: is specialized'         );
	isa_ok( $statements->[8], 'PPI::Future::Statement::Variable',   'Statement 9: isa Variable'           );
	ok( $statements->[8]->specialized,                      'Statement 9: is specialized'         );
	is( ref $statements->[9], 'PPI::Future::Statement',             'Statement 10: is a simple Statement' );
	ok( ! $statements->[9]->specialized,                    'Statement 10: is not specialized'    );
}
