package PPI::Future::Test::pragmas;

=head1 NAME

PPI::Future::Test::pragmas -- standard complier/runtime setup for PPI::Future tests

PPI::Future modules do not enable warnings, but this module enables warnings
in the tests, and it forces a test failure if any warnings occur.
This gives full warnings coverage during the test suite without
forcing PPI::Future users to accept an unbounded number of warnings in code
they don't control.  See L<https://github.com/adamkennedy/PPI::Future/issues/142>
for a  fuller explanation of this philosophy.

=cut

use 5.006;
use strict;
use warnings;

use Test::More 0.88;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings', ':no_end_test';

our $VERSION = '1.236';

BEGIN {
	select STDERR;  ## no critic ( InputOutput::ProhibitOneArgSelect )
	$| = 1;
	select STDOUT;  ## no critic ( InputOutput::ProhibitOneArgSelect )

	$^W++; # throw -w at runtime to try and catch warnings in un-warning-ed modules

	no warnings 'once';  ## no critic ( TestingAndDebugging::ProhibitNoWarnings )
	$PPI::Future::XS_DISABLE = 1;
	$PPI::Future::Lexer::X_TOKENIZER ||= $ENV{X_TOKENIZER};
}

sub import {
	strict->import();
	warnings->import();
	return;
}

END {
    Test::Warnings::had_no_warnings() if $ENV{AUTHOR_TESTING};
}

1;