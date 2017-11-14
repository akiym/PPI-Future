package PPI::Future::Test::Object;

use warnings;
use strict;

use List::Util 1.33 'any';
use Params::Util qw{_INSTANCE};
use PPI::Future::Dumper;
use Test::More;
use Test::Object;

our $VERSION = '1.236';





#####################################################################
# PPI::Future::Document Testing

Test::Object->register(
	class => 'PPI::Future::Document',
	tests => 1,
	code  => \&document_ok,
);

sub document_ok {
	my $doc = shift;

	# A document should have zero or more children that are either
	# a statement or a non-significant child.
	my @children = $doc->children;
	my $good = grep {
		_INSTANCE($_, 'PPI::Future::Statement')
		or (
			_INSTANCE($_, 'PPI::Future::Token') and ! $_->significant
			)
		} @children;

	is( $good, scalar(@children),
		'Document contains only statements and non-significant tokens' );

	1;
}





#####################################################################
# Are there an unknowns

Test::Object->register(
	class => 'PPI::Future::Document',
	tests => 3,
	code  => \&unknown_objects,
);

sub unknown_objects {
	my $doc = shift;

	is(
		$doc->find_any('Token::Unknown'),
		'',
		"Contains no PPI::Future::Token::Unknown elements",
	);
	is(
		$doc->find_any('Structure::Unknown'),
		'',
		"Contains no PPI::Future::Structure::Unknown elements",
	);
	is(
		$doc->find_any('Statement::Unknown'),
		'',
		"Contains no PPI::Future::Statement::Unknown elements",
	);

	1;
}





#####################################################################
# Are there any invalid nestings?

Test::Object->register(
	class => 'PPI::Future::Document',
	tests => 1,
	code  => \&nested_statements,
);

sub nested_statements {
	my $doc = shift;

	ok(
		! $doc->find_any( sub {
			_INSTANCE($_[1], 'PPI::Future::Statement')
			and
			any { _INSTANCE($_, 'PPI::Future::Statement') } $_[1]->children
		} ),
		'Document contains no nested statements',
	);	
}

Test::Object->register(
	class => 'PPI::Future::Document',
	tests => 1,
	code  => \&nested_structures,
);

sub nested_structures {
	my $doc = shift;

	ok(
		! $doc->find_any( sub {
			_INSTANCE($_[1], 'PPI::Future::Structure')
			and
			any { _INSTANCE($_, 'PPI::Future::Structure') } $_[1]->children
		} ),
		'Document contains no nested structures',
	);
}

Test::Object->register(
	class => 'PPI::Future::Document',
	tests => 1,
	code  => \&no_attribute_in_attribute,
);

sub no_attribute_in_attribute {
	my $doc = shift;

	ok(
		! $doc->find_any( sub {
			_INSTANCE($_[1], 'PPI::Future::Token::Attribute')
			and
			! exists $_[1]->{_attribute}
		} ),
		'No ->{_attribute} in PPI::Future::Token::Attributes',
	);
}





#####################################################################
# PPI::Future::Statement Tests

Test::Object->register(
	class => 'PPI::Future::Document',
	tests => 1,
	code  => \&valid_compound_type,
);

sub valid_compound_type {
	my $document = shift;
	my $compound = $document->find('PPI::Future::Statement::Compound') || [];
	is(
		scalar( grep { not defined $_->type } @$compound ),
		0, 'All compound statements have defined ->type',
	);
}





#####################################################################
# Does ->location work properly
# As an aside, fixes #23788: PPI::Future::Statement::location() returns undef for C<({})>.

Test::Object->register(
	class => 'PPI::Future::Document',
	tests => 1,
	code   => \&defined_location,
);

sub defined_location {
	my $document = shift;
	my $bad      = $document->find( sub {
		not defined $_[1]->location
	} );
	is( $bad, '', '->location always defined' );
}

1;
