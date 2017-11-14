#!/usr/bin/perl

# Test the PPI::Future::Util package

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 10 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use File::Spec::Functions ':ALL';
use PPI::Future;
use PPI::Future::Util qw{_Document _slurp};

# Execute the tests
my $testfile   = catfile( 't', 'data', '11_util', 'test.pm' );
my $testsource = 'print "Hello World!\n"';
my $slurpfile  = catfile( 't', 'data', 'basic.pl' );
my $slurpcode  = <<'END_FILE';
#!/usr/bin/perl

if ( 1 ) {
	print "Hello World!\n";
}

1;

END_FILE




#####################################################################
# Test PPI::Future::Util::_Document

my $Document = PPI::Future::Document->new( \$testsource );
isa_ok( $Document, 'PPI::Future::Document' );

# Good things
foreach my $thing ( $testfile, \$testsource, $Document, [] ) {
	isa_ok( _Document( $thing ), 'PPI::Future::Document' );
}

# Bad things
### erm...

# Evil things
foreach my $thing ( {}, sub () { 1 } ) {
	is( _Document( $thing ), undef, '_Document(evil) returns undef' );
}




#####################################################################
# Test PPI::Future::Util::_slurp

my $source = _slurp( $slurpfile );
is_deeply( $source, \$slurpcode, '_slurp loads file as expected' );





#####################################################################
# Check the capability flags

my $have_unicode = PPI::Future::Util::HAVE_UNICODE();
ok( defined $have_unicode, 'HAVE_UNICODE defined' );
is( $have_unicode, !! $have_unicode, 'HAVE_UNICODE is a boolean' );
