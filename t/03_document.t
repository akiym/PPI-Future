#!/usr/bin/perl

# PPI::Future::Document tests

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 13 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use File::Spec::Functions ':ALL';
use PPI::Future;


#####################################################################
# Test a basic document

# Parse a simple document in all possible ways
NEW: {
	my $file  = catfile(qw{ t data 03_document test.dat  });
	ok( -f $file,  'Found test.dat' );

	my $doc1 = PPI::Future::Document->new( $file );
	isa_ok( $doc1, 'PPI::Future::Document' );

	# Test script
	my $script = <<'END_PERL';
#!/usr/bin/perl

# A simple test script

print "Hello World!\n";
END_PERL
	my $doc2 = PPI::Future::Document->new( \$script );
	isa_ok( $doc2, 'PPI::Future::Document' );

	my $doc3 = PPI::Future::Document->new( [
		"#!/usr/bin/perl",
		"",
		"# A simple test script",
		"",
		"print \"Hello World!\\n\";",
	] );
	isa_ok( $doc3, 'PPI::Future::Document' );

	# Compare the three forms
	is_deeply( $doc1, $doc2, 'Stringref form matches file form' );
	is_deeply( $doc1, $doc3, 'Arrayref form matches file form'  );
}

# Repeat the above with a null document
NEW_EMPTY: {
	my $empty = catfile(qw{ t data 03_document empty.dat });
	ok( -f $empty, 'Found empty.dat' );

	my $doc1 = PPI::Future::Document->new( $empty );
	isa_ok( $doc1, 'PPI::Future::Document' );

	my $doc2 = PPI::Future::Document->new( \'' );
	isa_ok( $doc2, 'PPI::Future::Document' );

	my $doc3 = PPI::Future::Document->new( [ ] );
	isa_ok( $doc3, 'PPI::Future::Document' );

	# Compare the three forms
	is_deeply( $doc1, $doc2, 'Stringref form matches file form' );
	is_deeply( $doc1, $doc3, 'Arrayref form matches file form'  );

	# Make sure the null document round-trips
	my $string = $doc1->serialize;
	is( $string, '', '->serialize ok' );

	# Check for warnings on null document index_locations
	{
		local $^W = 1;
		$doc1->index_locations();
	}
}
