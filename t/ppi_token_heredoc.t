#!/usr/bin/perl

# Unit testing for PPI::Future::Token::HereDoc

use lib 't/lib';
use PPI::Future::Test::pragmas;
use Test::More tests => 29 + ($ENV{AUTHOR_TESTING} ? 1 : 0);

use PPI::Future;
use Test::Deep;

sub h;

# List of tests to perform. Each test requires the following information:
#     - 'name': the name of the test in the output.
#     - 'content': the Perl string to parse using PPI::Future.
#     - 'expected': a hashref with the keys being property names on the
#       PPI::Future::Token::HereDoc object, and the values being the expected value of
#       that property after the heredoc block has been parsed.

	# Tests with a carriage return after the termination marker.
h	{
		name     => 'Bareword terminator.',
		content  => "my \$heredoc = <<HERE;\nLine 1\nLine 2\nHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => undef,
		},
	};
h	{
		name     => 'Single-quoted bareword terminator.',
		content  => "my \$heredoc = <<'HERE';\nLine 1\nLine 2\nHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => undef,
		},
	};
h	{
		name     => 'Single-quoted bareword terminator with space.',
		content  => "my \$heredoc = << 'HERE';\nLine 1\nLine 2\nHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => undef,
		},
	};
h	{
		name     => 'Double-quoted bareword terminator.',
		content  => "my \$heredoc = <<\"HERE\";\nLine 1\nLine 2\nHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => undef,
		},
	};
h	{
		name     => 'Double-quoted bareword terminator with space.',
		content  => "my \$heredoc = << \"HERE\";\nLine 1\nLine 2\nHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => undef,
		},
	};
h	{
		name     => 'Command-quoted terminator.',
		content  => "my \$heredoc = <<`HERE`;\nLine 1\nLine 2\nHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'command',
			_indented        => undef,
		},
	};
h	{
		name     => 'Command-quoted terminator with space.',
		content  => "my \$heredoc = << `HERE`;\nLine 1\nLine 2\nHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'command',
			_indented        => undef,
		},
	};
h	{
		name     => 'Legacy escaped bareword terminator.',
		content  => "my \$heredoc = <<\\HERE;\nLine 1\nLine 2\nHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => undef,
		},
	};

	# Tests without a carriage return after the termination marker.
h	{
		name     => 'Bareword terminator (no return).',
		content  => "my \$heredoc = <<HERE;\nLine 1\nLine 2\nHERE",
		expected => {
			_terminator_line => 'HERE',
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => undef,
		},
	};
h	{
		name     => 'Single-quoted bareword terminator (no return).',
		content  => "my \$heredoc = <<'HERE';\nLine 1\nLine 2\nHERE",
		expected => {
			_terminator_line => "HERE",
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => undef,
		},
	};
h	{
		name     => 'Double-quoted bareword terminator (no return).',
		content  => "my \$heredoc = <<\"HERE\";\nLine 1\nLine 2\nHERE",
		expected => {
			_terminator_line => 'HERE',
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => undef,
		},
	};
h	{
		name     => 'Command-quoted terminator (no return).',
		content  => "my \$heredoc = <<`HERE`;\nLine 1\nLine 2\nHERE",
		expected => {
			_terminator_line => 'HERE',
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'command',
			_indented        => undef,
		},
	};
h	{
		name     => 'Legacy escaped bareword terminator (no return).',
		content  => "my \$heredoc = <<\\HERE;\nLine 1\nLine 2\nHERE",
		expected => {
			_terminator_line => 'HERE',
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => undef,
		},
	};

	# Tests without a terminator.
h	{
		name     => 'Unterminated heredoc block.',
		content  => "my \$heredoc = <<HERE;\nLine 1\nLine 2\n",
		expected => {
			_terminator_line => undef,
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => undef,
		},
	};

	# Tests indented here-document with a carriage return after the termination marker.
h	{
		name     => 'Bareword terminator (indented).',
		content  => "my \$heredoc = <<~HERE;\n\t \tLine 1\n\t \tLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => 1,
		},
	};
h	{
		name     => 'Single-quoted bareword terminator (indented).',
		content  => "my \$heredoc = <<~'HERE';\n\t \tLine 1\n\t \tLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => 1,
		},
	};
h	{
		name     => 'Single-quoted bareword terminator with space (indented).',
		content  => "my \$heredoc = <<~ 'HERE';\n\t \tLine 1\n\t \tLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => 1,
		},
	};
h	{
		name     => 'Double-quoted bareword terminator (indented).',
		content  => "my \$heredoc = <<~\"HERE\";\n\t \tLine 1\n\t \tLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => 1,
		},
	};
h	{
		name     => 'Double-quoted bareword terminator with space (indented).',
		content  => "my \$heredoc = <<~ \"HERE\";\n\t \tLine 1\n\t \tLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => 1,
		},
	};
h	{
		name     => 'Command-quoted terminator (indented).',
		content  => "my \$heredoc = <<~`HERE`;\n\t \tLine 1\n\t \tLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'command',
			_indented        => 1,
		},
	};
h	{
		name     => 'Command-quoted terminator with space (indented).',
		content  => "my \$heredoc = <<~ `HERE`;\n\t \tLine 1\n\t \tLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'command',
			_indented        => 1,
		},
	};
h	{
		name     => 'Legacy escaped bareword terminator (indented).',
		content  => "my \$heredoc = <<~\\HERE;\n\t \tLine 1\n\t \tLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => undef,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => 1,
		},
	};

	# Tests indented here-document without a carriage return after the termination marker.
h	{
		name     => 'Bareword terminator (indented and no return).',
		content  => "my \$heredoc = <<~HERE;\n\t \tLine 1\n\t \tLine 2\n\t \tHERE",
		expected => {
			_terminator_line => 'HERE',
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => 1,
		},
	};
h	{
		name     => 'Single-quoted bareword terminator (indented and no return).',
		content  => "my \$heredoc = <<~'HERE';\n\t \tLine 1\n\t \tLine 2\n\t \tHERE",
		expected => {
			_terminator_line => "HERE",
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => 1,
		},
	};
h	{
		name     => 'Double-quoted bareword terminator (indented and no return).',
		content  => "my \$heredoc = <<~\"HERE\";\n\t \tLine 1\n\t \tLine 2\n\t \tHERE",
		expected => {
			_terminator_line => 'HERE',
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => 1,
		},
	};
h	{
		name     => 'Command-quoted terminator (indented and no return).',
		content  => "my \$heredoc = <<~`HERE`;\n\t \tLine 1\n\t \tLine 2\n\t \tHERE",
		expected => {
			_terminator_line => 'HERE',
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'command',
			_indented        => 1,
		},
	};
h	{
		name     => 'Legacy escaped bareword terminator (indented and no return).',
		content  => "my \$heredoc = <<~\\HERE;\n\t \tLine 1\n\t \tLine 2\n\t \tHERE",
		expected => {
			_terminator_line => 'HERE',
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'literal',
			_indented        => 1,
		},
	};

	# Tests indented here-document without a terminator.
h	{
		name     => 'Unterminated heredoc block (indented).',
		content  => "my \$heredoc = <<~HERE;\nLine 1\nLine 2\n",
		expected => {
			_terminator_line => undef,
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => 1,
		},
	};

	# Tests indented here-document where indentation doesn't match
h	{
		name     => 'Unterminated heredoc block (indented).',
		content  => "my \$heredoc = <<~HERE;\nLine 1\nLine 2\n\t \tHERE\n",
		expected => {
			_terminator_line => "HERE\n",
			_damaged         => 1,
			_terminator      => 'HERE',
			_mode            => 'interpolate',
			_indented        => 1,
		},
	};

sub h {
    my ( $test ) = @_;
	subtest(
		$test->{name},
		sub {
			plan tests => 6 + keys %{ $test->{expected} };

			my $document = PPI::Future::Document->new( \$test->{content} );
			isa_ok( $document, 'PPI::Future::Document' );

			my $heredocs = $document->find( 'Token::HereDoc' );
			is( ref $heredocs,     'ARRAY', 'Found heredocs.' );
			is( scalar @$heredocs, 1,       'Found 1 heredoc block.' );

			my $heredoc = $heredocs->[0];
			isa_ok( $heredoc, 'PPI::Future::Token::HereDoc' );
			can_ok( $heredoc, 'heredoc' );

			my @content = $heredoc->heredoc;
			is_deeply(
				\@content,
				[ "Line 1\n", "Line 2\n", ],
				'The returned content does not include the heredoc terminator.',
			) or diag "heredoc() returned ", explain \@content;

			is( $heredoc->{$_}, $test->{expected}{$_}, "property '$_'" ) for keys %{ $test->{expected} };
		}
	);
}
