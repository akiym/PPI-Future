#!/usr/bin/perl

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 20 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future::Test::Run;





#####################################################################
# Code/Dump Testing

PPI::Future::Test::Run->run_testdir(qw{ t data 26_bom });
