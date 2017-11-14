#!/usr/bin/perl

# Basic first pass API testing for PPI::Future

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More;
BEGIN {
        my $tests = 2931 + ($ENV{AUTHOR_TESTING} ? 1 : 0);
	if ( $ENV{RELEASE_TESTING} ) {
		plan( tests => $tests );
	} else {
		plan( tests => $tests, skip_all => 'Author tests not required for installation' );
	}
}

use Test::ClassAPI;
use PPI::Future;
use PPI::Future::Dumper;
use PPI::Future::Find;
use PPI::Future::Transform;

# Ignore various imported or special functions
$Test::ClassAPI::IGNORE{'DESTROY'}++;
$Test::ClassAPI::IGNORE{'refaddr'}++;
$Test::ClassAPI::IGNORE{'reftype'}++;
$Test::ClassAPI::IGNORE{'blessed'}++;

# Execute the tests
Test::ClassAPI->execute('complete', 'collisions');
exit(0);

# Now, define the API for the classes
__DATA__

# Explicitly list the core classes
PPI::Future=class
PPI::Future::Tokenizer=class
PPI::Future::Lexer=class
PPI::Future::Dumper=class
PPI::Future::Find=class
PPI::Future::Transform=abstract
PPI::Future::Normal=class

# The abstract PDOM classes
PPI::Future::Element=abstract
PPI::Future::Node=abstract
PPI::Future::Token=abstract
PPI::Future::Token::_QuoteEngine=abstract
PPI::Future::Token::_QuoteEngine::Simple=abstract
PPI::Future::Token::_QuoteEngine::Full=abstract
PPI::Future::Token::Quote=abstract
PPI::Future::Token::QuoteLike=abstract
PPI::Future::Token::Regexp=abstract
PPI::Future::Structure=abstract
PPI::Future::Statement=abstract









#####################################################################
# PDOM Classes

[PPI::Future::Element]
new=method
clone=method
parent=method
descendant_of=method
ancestor_of=method
top=method
document=method
statement=method
next_sibling=method
snext_sibling=method
previous_sibling=method
sprevious_sibling=method
first_token=method
last_token=method
next_token=method
previous_token=method
insert_before=method
insert_after=method
remove=method
delete=method
replace=method
content=method
tokens=method
significant=method
location=method
line_number=method
column_number=method
visual_column_number=method
logical_line_number=method
logical_filename=method
class=method

[PPI::Future::Node]
PPI::Future::Element=isa
scope=method
add_element=method
elements=method
first_element=method
last_element=method
children=method
schildren=method
child=method
schild=method
contains=method
find=method
find_any=method
find_first=method
remove_child=method
prune=method

[PPI::Future::Token]
PPI::Future::Element=isa
new=method
add_content=method
set_class=method
set_content=method
length=method

[PPI::Future::Token::Whitespace]
PPI::Future::Token=isa
null=method
tidy=method

[PPI::Future::Token::Pod]
PPI::Future::Token=isa
lines=method
merge=method

[PPI::Future::Token::Data]
PPI::Future::Token=isa
handle=method

[PPI::Future::Token::End]
PPI::Future::Token=isa

[PPI::Future::Token::Comment]
PPI::Future::Token=isa
line=method

[PPI::Future::Token::Word]
PPI::Future::Token=isa
literal=method
method_call=method

[PPI::Future::Token::Separator]
PPI::Future::Token::Word=isa

[PPI::Future::Token::Label]
PPI::Future::Token=isa

[PPI::Future::Token::Structure]
PPI::Future::Token=isa

[PPI::Future::Token::Number]
PPI::Future::Token=isa
base=method
literal=method

[PPI::Future::Token::Symbol]
PPI::Future::Token=isa
canonical=method
symbol=method
raw_type=method
symbol_type=method

[PPI::Future::Token::ArrayIndex]
PPI::Future::Token=isa

[PPI::Future::Token::Operator]
PPI::Future::Token=isa

[PPI::Future::Token::Magic]
PPI::Future::Token=isa
PPI::Future::Token::Symbol=isa

[PPI::Future::Token::Cast]
PPI::Future::Token=isa

[PPI::Future::Token::Prototype]
PPI::Future::Token=isa
prototype=method

[PPI::Future::Token::Attribute]
PPI::Future::Token=isa
identifier=method
parameters=method

[PPI::Future::Token::DashedWord]
PPI::Future::Token=isa
literal=method

[PPI::Future::Token::HereDoc]
PPI::Future::Token=isa
heredoc=method
terminator=method

[PPI::Future::Token::_QuoteEngine]

[PPI::Future::Token::_QuoteEngine::Simple]
PPI::Future::Token::_QuoteEngine=isa

[PPI::Future::Token::_QuoteEngine::Full]
PPI::Future::Token::_QuoteEngine=isa

[PPI::Future::Token::Quote]
PPI::Future::Token=isa
string=method

[PPI::Future::Token::Quote::Single]
PPI::Future::Token=isa
PPI::Future::Token::Quote=isa
literal=method

[PPI::Future::Token::Quote::Double]
PPI::Future::Token=isa
PPI::Future::Token::Quote=isa
interpolations=method
simplify=method

[PPI::Future::Token::Quote::Literal]
PPI::Future::Token=isa
literal=method

[PPI::Future::Token::Quote::Interpolate]
PPI::Future::Token=isa

[PPI::Future::Token::QuoteLike]
PPI::Future::Token=isa

[PPI::Future::Token::QuoteLike::Backtick]
PPI::Future::Token=isa
PPI::Future::Token::_QuoteEngine::Simple=isa

[PPI::Future::Token::QuoteLike::Command]
PPI::Future::Token=isa
PPI::Future::Token::_QuoteEngine::Full=isa

[PPI::Future::Token::QuoteLike::Words]
PPI::Future::Token=isa
PPI::Future::Token::_QuoteEngine::Full=isa
literal=method

[PPI::Future::Token::QuoteLike::Regexp]
PPI::Future::Token=isa
PPI::Future::Token::_QuoteEngine::Full=isa
get_match_string=method
get_substitute_string=method
get_modifiers=method
get_delimiters=method

[PPI::Future::Token::QuoteLike::Readline]
PPI::Future::Token=isa
PPI::Future::Token::_QuoteEngine::Full=isa

[PPI::Future::Token::Regexp]
PPI::Future::Token=isa
PPI::Future::Token::_QuoteEngine::Full=isa
get_match_string=method
get_substitute_string=method
get_modifiers=method
get_delimiters=method

[PPI::Future::Token::Regexp::Match]
PPI::Future::Token=isa

[PPI::Future::Token::Regexp::Substitute]
PPI::Future::Token=isa

[PPI::Future::Token::Regexp::Transliterate]
PPI::Future::Token=isa

[PPI::Future::Statement]
PPI::Future::Node=isa
label=method
specialized=method
stable=method

[PPI::Future::Statement::Expression]
PPI::Future::Statement=isa

[PPI::Future::Statement::Package]
PPI::Future::Statement=isa
namespace=method
version=method
file_scoped=method

[PPI::Future::Statement::Include]
PPI::Future::Statement=isa
type=method
arguments=method
module=method
module_version=method
pragma=method
version=method
version_literal=method

[PPI::Future::Statement::Include::Perl6]
PPI::Future::Statement::Include=isa
perl6=method

[PPI::Future::Statement::Sub]
PPI::Future::Statement=isa
name=method
prototype=method
block=method
forward=method
reserved=method

[PPI::Future::Statement::Scheduled]
PPI::Future::Statement::Sub=isa
PPI::Future::Statement=isa
type=method
block=method

[PPI::Future::Statement::Variable]
PPI::Future::Statement=isa
PPI::Future::Statement::Expression=isa
type=method
variables=method
symbols=method

[PPI::Future::Statement::Compound]
PPI::Future::Statement=isa
type=method

[PPI::Future::Statement::Given]
PPI::Future::Statement=isa

[PPI::Future::Statement::When]
PPI::Future::Statement=isa

[PPI::Future::Statement::Break]
PPI::Future::Statement=isa

[PPI::Future::Statement::Null]
PPI::Future::Statement=isa

[PPI::Future::Statement::Data]
PPI::Future::Statement=isa

[PPI::Future::Statement::End]
PPI::Future::Statement=isa

[PPI::Future::Statement::Unknown]
PPI::Future::Statement=isa

[PPI::Future::Structure]
PPI::Future::Node=isa
braces=method
complete=method
start=method
finish=method

[PPI::Future::Structure::Block]
PPI::Future::Structure=isa

[PPI::Future::Structure::Subscript]
PPI::Future::Structure=isa

[PPI::Future::Structure::Constructor]
PPI::Future::Structure=isa

[PPI::Future::Structure::Condition]
PPI::Future::Structure=isa

[PPI::Future::Structure::List]
PPI::Future::Structure=isa

[PPI::Future::Structure::For]
PPI::Future::Structure=isa

[PPI::Future::Structure::Given]
PPI::Future::Structure=isa

[PPI::Future::Structure::When]
PPI::Future::Structure=isa

[PPI::Future::Structure::Unknown]
PPI::Future::Structure=isa

[PPI::Future::Document]
PPI::Future::Node=isa
get_cache=method
set_cache=method
load=method
save=method
readonly=method
tab_width=method
serialize=method
hex_id=method
index_locations=method
flush_locations=method
normalized=method
complete=method
errstr=method
STORABLE_freeze=method
STORABLE_thaw=method

[PPI::Future::Document::Fragment]
PPI::Future::Document=isa





#####################################################################
# Non-PDOM Classes

[PPI::Future]

[PPI::Future::Tokenizer]
new=method
get_token=method
all_tokens=method
increment_cursor=method
decrement_cursor=method

[PPI::Future::Lexer]
new=method
lex_file=method
lex_source=method
lex_tokenizer=method
errstr=method

[PPI::Future::Dumper]
new=method
print=method
string=method
list=method

[PPI::Future::Find]
new=method
clone=method
in=method
start=method
match=method
finish=method
errstr=method

[PPI::Future::Transform]
new=method
document=method
apply=method
file=method

[PPI::Future::Normal]
register=method
new=method
layer=method
process=method

[PPI::Future::Normal::Standard]
import=method
remove_insignificant_elements=method
remove_useless_attributes=method
remove_useless_pragma=method
remove_statement_separator=method
remove_useless_return=method

[PPI::Future::Document::Normalized]
new=method
version=method
functions=method
equal=method
