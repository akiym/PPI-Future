#!/usr/bin/perl

# Compare a large number of specific code samples (.code)
# with the expected Lexer dumps (.dump).

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 218 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use File::Spec::Functions ':ALL';
use PPI::Future::Lexer;
use PPI::Future::Test::Run;

#####################################################################
# Code/Dump Testing

PPI::Future::Test::Run->run_testdir( catdir( 't', 'data', '05_lexer' ) );
