package PPI::Future;

# See POD at end for documentation

use 5.006;
use strict;

# Set the version for CPAN
our $VERSION = '1.236';

our ( $XS_COMPATIBLE, @XS_EXCLUDE ) = ( '0.845' );

# Load everything
use PPI::Future::Util                 ();
use PPI::Future::Exception            ();
use PPI::Future::Element              ();
use PPI::Future::Token                ();
use PPI::Future::Statement            ();
use PPI::Future::Structure            ();
use PPI::Future::Document             ();
use PPI::Future::Document::File       ();
use PPI::Future::Document::Fragment   ();
use PPI::Future::Document::Normalized ();
use PPI::Future::Normal               ();
use PPI::Future::Tokenizer            ();
use PPI::Future::Lexer                ();

# If it is installed, load in PPI::Future::XS
die
  if !$PPI::Future::XS_DISABLE
  and !eval { require PPI::Future::XS; 1 }
  and $@ !~ /^Can't locate .*? at /;    # ignore failure to load if not installed

1;

__END__

=pod

=head1 NAME

PPI::Future - Parse, Analyze and Manipulate Perl (without perl)

=head1 SYNOPSIS

  use PPI::Future;
  
  # Create a new empty document
  my $Document = PPI::Future::Document->new;
  
  # Create a document from source
  $Document = PPI::Future::Document->new(\'print "Hello World!\n"');
  
  # Load a Document from a file
  $Document = PPI::Future::Document->new('Module.pm');
  
  # Does it contain any POD?
  if ( $Document->find_any('PPI::Future::Token::Pod') ) {
      print "Module contains POD\n";
  }
  
  # Get the name of the main package
  $pkg = $Document->find_first('PPI::Future::Statement::Package')->namespace;
  
  # Remove all that nasty documentation
  $Document->prune('PPI::Future::Token::Pod');
  $Document->prune('PPI::Future::Token::Comment');
  
  # Save the file
  $Document->save('Module.pm.stripped');

=head1 DESCRIPTION

=head2 About this Document

This is the PPI::Future manual. It describes its reason for existing, its general
structure, its use, an overview of the API, and provides a few
implementation samples.

=head2 Background

The ability to read, and manipulate Perl (the language) programmatically
other than with perl (the application) was one that caused difficulty
for a long time.

The cause of this problem was Perl's complex and dynamic grammar.
Although there is typically not a huge diversity in the grammar of most
Perl code, certain issues cause large problems when it comes to parsing.

Indeed, quite early in Perl's history Tom Christiansen introduced the Perl
community to the quote I<"Nothing but perl can parse Perl">, or as it is
more often stated now as a truism:

B<"Only perl can parse Perl">

One example of the sorts of things the prevent Perl being easily parsed are
function signatures, as demonstrated by the following.

  @result = (dothis $foo, $bar);
  
  # Which of the following is it equivalent to?
  @result = (dothis($foo), $bar);
  @result = dothis($foo, $bar);

The first line above can be interpreted in two different ways, depending
on whether the C<&dothis> function is expecting one argument, or two,
or several.

A "code parser" (something that parses for the purpose of execution) such
as perl needs information that is not found in the immediate vicinity of
the statement being parsed.

The information might not just be elsewhere in the file, it might not even be
in the same file at all. It might also not be able to determine this
information without the prior execution of a C<BEGIN {}> block, or the
loading and execution of one or more external modules. Or worse the &dothis
function may not even have been written yet.

B<When parsing Perl as code, you must also execute it>

Even perl itself never really fully understands the structure of the source
code after and indeed B<as> it processes it, and in that sense doesn't
"parse" Perl source into anything remotely like a structured document.
This makes it of no real use for any task that needs to treat the source
code as a document, and do so reliably and robustly.

For more information on why it is impossible to parse perl, see Randal
Schwartz's seminal response to the question of "Why can't you parse Perl".

L<http://www.perlmonks.org/index.pl?node_id=44722>

The purpose of PPI::Future is B<not> to parse Perl I<Code>, but to parse Perl
I<Documents>. By treating the problem this way, we are able to parse a
single file containing Perl source code "isolated" from any other
resources, such as libraries upon which the code may depend, and
without needing to run an instance of perl alongside or inside the parser.

Historically, using an embedded perl parser was widely considered to be
the most likely avenue for finding a solution to parsing Perl. It has been
investigated from time to time, but attempts have generally failed or
suffered from sufficiently bad corner cases that they were abandoned.

=head2 What Does PPI::Future Stand For?

C<PPI::Future> is an acronym for the longer original module name
C<Parse::Perl::Isolated>. And in the spirit or the silly acronym games
played by certain unnamed Open Source projects you may have I<hurd> of,
it also a reverse backronym of "I Parse Perl".

Of course, I could just be lying and have just made that second bit up
10 minutes before the release of PPI::Future 1.000. Besides, B<all> the cool
Perl packages have TLAs (Three Letter Acronyms). It's a rule or something.

Why don't you just think of it as the B<Perl Parsing Interface> for simplicity.

The original name was shortened to prevent the author (and you the users)
from contracting RSI by having to type crazy things like
C<Parse::Perl::Isolated::Token::QuoteLike::Backtick> 100 times a day.

In acknowledgment that someone may some day come up with a valid solution
for the grammar problem it was decided at the commencement of the project
to leave the C<Parse::Perl> namespace free for any such effort.

Since that time I've been able to prove to my own satisfaction that it
B<is> truly impossible to accurately parse Perl as both code and document
at once. For the academics, parsing Perl suffers from the "Halting Problem".

=head2 Why Parse Perl?

Once you can accept that we will never be able to parse Perl well enough
to meet the standards of things that treat Perl as code, it is worth
re-examining C<why> we want to "parse" Perl at all.

What are the things that people might want a "Perl parser" for.

=over 4

=item Documentation

Analyzing the contents of a Perl document to automatically generate
documentation, in parallel to, or as a replacement for, POD documentation.

Allow an indexer to locate and process all the comments and
documentation from code for "full text search" applications.

=item Structural and Quality Analysis

Determine quality or other metrics across a body of code, and identify
situations relating to particular phrases, techniques or locations.

Index functions, variables and packages within Perl code, and doing search
and graph (in the node/edge sense) analysis of large code bases.

L<Perl::Critic>, based on PPI::Future, is a large, thriving tool for bug detection
and style analysis of Perl code.

=item Refactoring

Make structural, syntax, or other changes to code in an automated manner,
either independently or in assistance to an editor. This sort of task list
includes backporting, forward porting, partial evaluation, "improving" code,
or whatever. All the sort of things you'd want from a L<Perl::Editor>.

=item Layout

Change the layout of code without changing its meaning. This includes
techniques such as tidying (like L<perltidy>), obfuscation, compressing and
"squishing", or to implement formatting preferences or policies.

=item Presentation

This includes methods of improving the presentation of code, without changing
the content of the code. Modify, improve, syntax colour etc the presentation
of a Perl document. Generating "IntelliText"-like functions.

=back

If we treat this as a baseline for the sort of things we are going to have
to build on top of Perl, then it becomes possible to identify a standard
for how good a Perl parser needs to be.

=head2 How good is Good Enough(TM)

PPI::Future seeks to be good enough to achieve all of the above tasks, or to provide
a sufficiently good API on which to allow others to implement modules in
these and related areas.

However, there are going to be limits to this process. Because PPI::Future cannot
adapt to changing grammars, any code written using source filters should not
be assumed to be parsable.

At one extreme, this includes anything munged by L<Acme::Bleach>, as well
as (arguably) more common cases like L<Switch>. We do not pretend to be
able to always parse code using these modules, although as long as it still
follows a format that looks like Perl syntax, it may be possible to extend
the lexer to handle them.

The ability to extend PPI::Future to handle lexical additions to the language is on
the drawing board to be done some time post-1.0

The goal for success was originally to be able to successfully parse 99% of
all Perl documents contained in CPAN. This means the entire file in each
case.

PPI::Future has succeeded in this goal far beyond the expectations of even the
author. At time of writing there are only 28 non-Acme Perl modules in CPAN
that PPI::Future is incapable of parsing. Most of these are so badly broken they
do not compile as Perl code anyway.

So unless you are actively going out of your way to break PPI::Future, you should
expect that it will handle your code just fine.

=head2 Internationalisation

PPI::Future provides partial support for internationalisation and localisation.

Specifically, it allows the use characters from the Latin-1 character
set to be used in quotes, comments, and POD. Primarily, this covers
languages from Europe and South America.

PPI::Future does B<not> currently provide support for Unicode.
If you need Unicode support and would like to help,
contact the author. (contact details below)

=head2 Round Trip Safe

When PPI::Future parses a file it builds B<everything> into the model, including
whitespace. This is needed in order to make the Document fully "Round Trip"
safe.

The general concept behind a "Round Trip" parser is that it knows what it
is parsing is somewhat uncertain, and so B<expects> to get things wrong
from time to time. In the cases where it parses code wrongly the tree
will serialize back out to the same string of code that was read in,
repairing the parser's mistake as it heads back out to the file.

The end result is that if you parse in a file and serialize it back out
without changing the tree, you are guaranteed to get the same file you
started with. PPI::Future does this correctly and reliably for 100% of all known
cases.

B<What goes in, will come out. Every time.>

The one minor exception at this time is that if the newlines for your file
are wrong (meaning not matching the platform newline format), PPI::Future will
localise them for you. (It isn't to be convenient, supporting
arbitrary newlines would make some of the code more complicated)

Better control of the newline type is on the wish list though, and
anyone wanting to help out is encouraged to contact the author.

=head1 IMPLEMENTATION

=head2 General Layout

PPI::Future is built upon two primary "parsing" components, L<PPI::Future::Tokenizer>
and L<PPI::Future::Lexer>, and a large tree of about 50 classes which implement
the various the I<Perl Document Object Model> (PDOM).

The PDOM is conceptually similar in style and intent to the regular DOM or
other code Abstract Syntax Trees (ASTs), but contains some differences
to handle perl-specific cases, and to assist in treating the code as a
document. Please note that it is B<not> an implementation of the official
Document Object Model specification, only somewhat similar to it.

On top of the Tokenizer, Lexer and the classes of the PDOM, sit a number
of classes intended to make life a little easier when dealing with PDOM
trees.

Both the major parsing components were hand-coded from scratch with only
plain Perl code and a few small utility modules. There are no grammar or
patterns mini-languages, no YACC or LEX style tools and only a small number
of regular expressions.

This is primarily because of the sheer volume of accumulated cruft that
exists in Perl. Not even perl itself is capable of parsing Perl documents
(remember, it just parses and executes it as code).

As a result, PPI::Future needed to be cruftier than perl itself. Feel free to
shudder at this point, and hope you never have to understand the Tokenizer
codebase. Speaking of which...

=head2 The Tokenizer

The Tokenizer takes source code and converts it into a series of tokens. It
does this using a slow but thorough character by character manual process,
rather than using a pattern system or complex regexes.

Or at least it does so conceptually. If you were to actually trace the code
you would find it's not truly character by character due to a number of
regexps and optimisations throughout the code. This lets the Tokenizer
"skip ahead" when it can find shortcuts, so it tends to jump around a line
a bit wildly at times.

In practice, the number of times the Tokenizer will B<actually> move the
character cursor itself is only about 5% - 10% higher than the number of
tokens contained in the file. This makes it about as optimal as it can be
made without implementing it in something other than Perl.

In 2001 when PPI::Future was started, this structure made PPI::Future quite slow, and not
really suitable for interactive tasks. This situation has improved greatly
with multi-gigahertz processors, but can still be painful when working with
very large files.

The target parsing rate for PPI::Future is about 5000 lines per gigacycle. It is
currently believed to be at about 1500, and main avenue for making it to
the target speed has now become L<PPI::Future::XS>, a drop-in XS accelerator for
PPI::Future.

Since L<PPI::Future::XS> has only just gotten off the ground and is currently only
at proof-of-concept stage, this may take a little while. Anyone interested
in helping out with L<PPI::Future::XS> is B<highly> encouraged to contact the
author. In fact, the design of L<PPI::Future::XS> means it's possible to port
one function at a time safely and reliably. So every little bit will help.

=head2 The Lexer

The Lexer takes a token stream, and converts it to a lexical tree. Because
we are parsing Perl B<documents> this includes whitespace, comments, and
all number of weird things that have no relevance when code is actually
executed.

An instantiated L<PPI::Future::Lexer> consumes L<PPI::Future::Tokenizer> objects and
produces L<PPI::Future::Document> objects. However you should probably never be
working with the Lexer directly. You should just be able to create
L<PPI::Future::Document> objects and work with them directly.

=head2 The Perl Document Object Model

The PDOM is a structured collection of data classes that together provide
a correct and scalable model for documents that follow the standard Perl
syntax.

=head2 The PDOM Class Tree

The following lists all of the 67 current PDOM classes, listing with indentation
based on inheritance.

   PPI::Future::Element
      PPI::Future::Node
         PPI::Future::Document
            PPI::Future::Document::Fragment
         PPI::Future::Statement
            PPI::Future::Statement::Package
            PPI::Future::Statement::Include
            PPI::Future::Statement::Sub
               PPI::Future::Statement::Scheduled
            PPI::Future::Statement::Compound
            PPI::Future::Statement::Break
            PPI::Future::Statement::Given
            PPI::Future::Statement::When
            PPI::Future::Statement::Data
            PPI::Future::Statement::End
            PPI::Future::Statement::Expression
               PPI::Future::Statement::Variable
            PPI::Future::Statement::Null
            PPI::Future::Statement::UnmatchedBrace
            PPI::Future::Statement::Unknown
         PPI::Future::Structure
            PPI::Future::Structure::Block
            PPI::Future::Structure::Subscript
            PPI::Future::Structure::Constructor
            PPI::Future::Structure::Condition
            PPI::Future::Structure::List
            PPI::Future::Structure::For
            PPI::Future::Structure::Given
            PPI::Future::Structure::When
            PPI::Future::Structure::Unknown
      PPI::Future::Token
         PPI::Future::Token::Whitespace
         PPI::Future::Token::Comment
         PPI::Future::Token::Pod
         PPI::Future::Token::Number
            PPI::Future::Token::Number::Binary
            PPI::Future::Token::Number::Octal
            PPI::Future::Token::Number::Hex
            PPI::Future::Token::Number::Float
               PPI::Future::Token::Number::Exp
            PPI::Future::Token::Number::Version
         PPI::Future::Token::Word
         PPI::Future::Token::DashedWord
         PPI::Future::Token::Symbol
            PPI::Future::Token::Magic
         PPI::Future::Token::ArrayIndex
         PPI::Future::Token::Operator
         PPI::Future::Token::Quote
            PPI::Future::Token::Quote::Single
            PPI::Future::Token::Quote::Double
            PPI::Future::Token::Quote::Literal
            PPI::Future::Token::Quote::Interpolate
         PPI::Future::Token::QuoteLike
            PPI::Future::Token::QuoteLike::Backtick
            PPI::Future::Token::QuoteLike::Command
            PPI::Future::Token::QuoteLike::Regexp
            PPI::Future::Token::QuoteLike::Words
            PPI::Future::Token::QuoteLike::Readline
         PPI::Future::Token::Regexp
            PPI::Future::Token::Regexp::Match
            PPI::Future::Token::Regexp::Substitute
            PPI::Future::Token::Regexp::Transliterate
         PPI::Future::Token::HereDoc
         PPI::Future::Token::Cast
         PPI::Future::Token::Structure
         PPI::Future::Token::Label
         PPI::Future::Token::Separator
         PPI::Future::Token::Data
         PPI::Future::Token::End
         PPI::Future::Token::Prototype
         PPI::Future::Token::Attribute
         PPI::Future::Token::Unknown

To summarize the above layout, all PDOM objects inherit from the
L<PPI::Future::Element> class.

Under this are L<PPI::Future::Token>, strings of content with a known type,
and L<PPI::Future::Node>, syntactically significant containers that hold other
Elements.

The three most important of these are the L<PPI::Future::Document>, the
L<PPI::Future::Statement> and the L<PPI::Future::Structure> classes.

=head2 The Document, Statement and Structure

At the top of all complete PDOM trees is a L<PPI::Future::Document> object. It
represents a complete file of Perl source code as you might find it on
disk.

There are some specialised types of document, such as L<PPI::Future::Document::File>
and L<PPI::Future::Document::Normalized> but for the purposes of the PDOM they are
all just considered to be the same thing.

Each Document will contain a number of B<Statements>, B<Structures> and
B<Tokens>.

A L<PPI::Future::Statement> is any series of Tokens and Structures that are treated
as a single contiguous statement by perl itself. You should note that a
Statement is as close as PPI::Future can get to "parsing" the code in the sense that
perl-itself parses Perl code when it is building the op-tree.

Because of the isolation and Perl's syntax, it is provably impossible for
PPI::Future to accurately determine precedence of operators or which tokens are
implicit arguments to a sub call.

So rather than lead you on with a bad guess that has a strong chance of
being wrong, PPI::Future does not attempt to determine precedence or sub parameters
at all.

At a fundamental level, it only knows that this series of elements
represents a single Statement as perl sees it, but it can do so with
enough certainty that it can be trusted.

However, for specific Statement types the PDOM is able to derive additional
useful information about their meaning. For the best, most useful, and most
heavily used example, see L<PPI::Future::Statement::Include>.

A L<PPI::Future::Structure> is any series of tokens contained within matching braces.
This includes code blocks, conditions, function argument braces, anonymous
array and hash constructors, lists, scoping braces and all other syntactic
structures represented by a matching pair of braces, including (although it
may not seem obvious at first) C<E<lt>READLINEE<gt>> braces.

Each Structure contains none, one, or many Tokens and Structures (the rules
for which vary for the different Structure subclasses)

Under the PDOM structure rules, a Statement can B<never> directly contain
another child Statement, a Structure can B<never> directly contain another
child Structure, and a Document can B<never> contain another Document
anywhere in the tree.

Aside from these three rules, the PDOM tree is extremely flexible.

=head2 The PDOM at Work

To demonstrate the PDOM in use lets start with an example showing how the
tree might look for the following chunk of simple Perl code.

  #!/usr/bin/perl

  print( "Hello World!" );

  exit();

Translated into a PDOM tree it would have the following structure (as shown
via the included L<PPI::Future::Dumper>).

  PPI::Future::Document
    PPI::Future::Token::Comment                '#!/usr/bin/perl\n'
    PPI::Future::Token::Whitespace             '\n'
    PPI::Future::Statement
      PPI::Future::Token::Word                 'print'
      PPI::Future::Structure::List             ( ... )
        PPI::Future::Token::Whitespace         ' '
        PPI::Future::Statement::Expression
          PPI::Future::Token::Quote::Double    '"Hello World!"'
        PPI::Future::Token::Whitespace         ' '
      PPI::Future::Token::Structure            ';'
    PPI::Future::Token::Whitespace             '\n'
    PPI::Future::Token::Whitespace             '\n'
    PPI::Future::Statement
      PPI::Future::Token::Word                 'exit'
      PPI::Future::Structure::List             ( ... )
      PPI::Future::Token::Structure            ';'
    PPI::Future::Token::Whitespace             '\n'

Please note that in this example, strings are only listed for the
B<actual> L<PPI::Future::Token> that contains that string. Structures are listed
with the type of brace characters it represents noted.

The L<PPI::Future::Dumper> module can be used to generate similar trees yourself.

We can make that PDOM dump a little easier to read if we strip out all the
whitespace. Here it is again, sans the distracting whitespace tokens.

  PPI::Future::Document
    PPI::Future::Token::Comment                '#!/usr/bin/perl\n'
    PPI::Future::Statement
      PPI::Future::Token::Word                 'print'
      PPI::Future::Structure::List             ( ... )
        PPI::Future::Statement::Expression
          PPI::Future::Token::Quote::Double    '"Hello World!"'
      PPI::Future::Token::Structure            ';'
    PPI::Future::Statement
      PPI::Future::Token::Word                 'exit'
      PPI::Future::Structure::List             ( ... )
      PPI::Future::Token::Structure            ';'

As you can see, the tree can get fairly deep at time, especially when every
isolated token in a bracket becomes its own statement. This is needed to
allow anything inside the tree the ability to grow. It also makes the
search and analysis algorithms much more flexible.

Because of the depth and complexity of PDOM trees, a vast number of very easy
to use methods have been added wherever possible to help people working with
PDOM trees do normal tasks relatively quickly and efficiently.

=head2 Overview of the Primary Classes

The main PPI::Future classes, and links to their own documentation, are listed
here in alphabetical order.

=over 4

=item L<PPI::Future::Document>

The Document object, the root of the PDOM.

=item L<PPI::Future::Document::Fragment>

A cohesive fragment of a larger Document. Although not of any real current
use, it is needed for use in certain internal tree manipulation
algorithms.

For example, doing things like cut/copy/paste etc. Very similar to a
L<PPI::Future::Document>, but has some additional methods and does not represent
a lexical scope boundary.

A document fragment is also non-serializable, and so cannot be written out
to a file.

=item L<PPI::Future::Dumper>

A simple class for dumping readable debugging versions of PDOM structures,
such as in the demonstration above.

=item L<PPI::Future::Element>

The Element class is the abstract base class for all objects within the PDOM

=item L<PPI::Future::Find>

Implements an instantiable object form of a PDOM tree search.

=item L<PPI::Future::Lexer>

The PPI::Future Lexer. Converts Token streams into PDOM trees.

=item L<PPI::Future::Node>

The Node object, the abstract base class for all PDOM objects that can
contain other Elements, such as the Document, Statement and Structure
objects.

=item L<PPI::Future::Statement>

The base class for all Perl statements. Generic "evaluate for side-effects"
statements are of this actual type. Other more interesting statement types
belong to one of its children.

See its own documentation for a longer description and list of all of the
different statement types and sub-classes.

=item L<PPI::Future::Structure>

The abstract base class for all structures. A Structure is a language
construct consisting of matching braces containing a set of other elements.

See the L<PPI::Future::Structure> documentation for a description and
list of all of the different structure types and sub-classes.

=item L<PPI::Future::Token>

A token is the basic unit of content. At its most basic, a Token is just
a string tagged with metadata (its class, and some additional flags in
some cases).

=item L<PPI::Future::Token::_QuoteEngine>

The L<PPI::Future::Token::Quote> and L<PPI::Future::Token::QuoteLike> classes provide
abstract base classes for the many and varied types of quote and
quote-like things in Perl. However, much of the actual quote login is
implemented in a separate quote engine, based at
L<PPI::Future::Token::_QuoteEngine>.

Classes that inherit from L<PPI::Future::Token::Quote>, L<PPI::Future::Token::QuoteLike>
and L<PPI::Future::Token::Regexp> are generally parsed only by the Quote Engine.

=item L<PPI::Future::Tokenizer>

The PPI::Future Tokenizer. One Tokenizer consumes a chunk of text and provides
access to a stream of L<PPI::Future::Token> objects.

The Tokenizer is very very complicated, to the point where even the author
treads carefully when working with it.

Most of the complication is the result of optimizations which have tripled
the tokenization speed, at the expense of maintainability. We cope with the
spaghetti by heavily commenting everything.

=item L<PPI::Future::Transform>

The Perl Document Transformation API. Provides a standard interface and
abstract base class for objects and classes that manipulate Documents.

=back

=head1 INSTALLING

The core PPI::Future distribution is pure Perl and has been kept as tight as
possible and with as few dependencies as possible.

It should download and install normally on any platform from within
the CPAN and CPANPLUS applications, or directly using the distribution
tarball. If installing by hand, you may need to install a few small
utility modules first. The exact ones will depend on your version of
perl.

There are no special install instructions for PPI::Future, and the normal
C<Perl Makefile.PL>, C<make>, C<make test>, C<make install> instructions
apply.

=head1 EXTENDING

The PPI::Future namespace itself is reserved for use by PPI::Future itself.
You are recommended to use the PPI::Futurex:: namespace for PPI::Future-specific
modifications or prototypes thereof, or Perl:: for modules which provide
a general Perl language-related functions.

If what you wish to implement looks like it fits into the PPI::Futurex:: namespace,
you should consider contacting the PPI::Future maintainers on GitHub first, as what
you want may already be in progress, or you may wish to consider contributing
to PPI::Future itself.

=head1 TO DO

- Many more analysis and utility methods for PDOM classes

- Creation of a PPI::Future::Tutorial document

- Add many more key functions to PPI::Future::XS

- We can B<always> write more and better unit tests

- Complete the full implementation of -E<gt>literal (1.200)

- Full understanding of scoping (due 1.300)

=head1 SUPPORT

The most recent version of PPI::Future is available at the following address.

L<http://search.cpan.org/~mithaldu/PPI::Future/>

PPI::Future source is maintained in a GitHub repository at the following address.

L<https://github.com/adamkennedy/PPI::Future>

Contributions via GitHub pull request are welcome.

Bug fixes in the form of pull requests or bug reports with
new (failing) unit tests have the best chance of being addressed
by busy maintainers, and are B<strongly> encouraged.

If you cannot provide a test or fix, or don't have time to do so,
then regular bug reports are still accepted and appreciated via the
GitHub bug tracker.

L<https://github.com/adamkennedy/PPI::Future/issues>

The C<ppidump> utility that is part of the L<Perl::Critic> distribution
is a useful tool for demonstrating how PPI::Future is parsing (or misparsing)
small code snippets, and for providing information for bug reports.

For other issues, questions, or commercial or media-related enquiries,
contact the author.

=head1 AUTHOR

Adam Kennedy E<lt>adamk@cpan.orgE<gt>

=head1 ACKNOWLEDGMENTS

A huge thank you to Phase N Australia (L<http://phase-n.com/>) for
permitting the original open sourcing and release of this distribution
from what was originally several thousand hours of commercial work.

Another big thank you to The Perl Foundation
(L<http://www.perlfoundation.org/>) for funding for the final big
refactoring and completion run.

Also, to the various co-maintainers that have contributed both large and
small with tests and patches and especially to those rare few who have
deep-dived into the guts to (gasp) add a feature.

  - Dan Brook       : PPI::Futurex::XPath, Acme::PerlML
  - Audrey Tang     : "Line Noise" Testing
  - Arjen Laarhoven : Three-element ->location support
  - Elliot Shank    : Perl 5.10 support, five-element ->location

And finally, thanks to those brave ( and foolish :) ) souls willing to dive
in and use, test drive and provide feedback on PPI::Future before version 1.000,
in some cases before it made it to beta quality, and still did extremely
distasteful things (like eating 50 meg of RAM a second).

I owe you all a beer. Corner me somewhere and collect at your convenience.
If I missed someone who wasn't in my email history, thank you too :)

  # In approximate order of appearance
  - Claes Jacobsson
  - Michael Schwern
  - Jeff T. Parsons
  - CPAN Author "CHOCOLATEBOY"
  - Robert Rotherberg
  - CPAN Author "PODMASTER"
  - Richard Soderberg
  - Nadim ibn Hamouda el Khemir
  - Graciliano M. P.
  - Leon Brocard
  - Jody Belka
  - Curtis Ovid
  - Yuval Kogman
  - Michael Schilli
  - Slaven Rezic
  - Lars Thegler
  - Tony Stubblebine
  - Tatsuhiko Miyagawa
  - CPAN Author "CHROMATIC"
  - Matisse Enzer
  - Roy Fulbright
  - Dan Brook
  - Johnny Lee
  - Johan Lindstrom

And to single one person out, thanks go to Randal Schwartz who
spent a great number of hours in IRC over a critical 6 month period
explaining why Perl is impossibly unparsable and constantly shoving evil
and ugly corner cases in my face. He remained a tireless devil's advocate,
and without his support this project genuinely could never have been
completed.

So for my schooling in the Deep Magiks, you have my deepest gratitude Randal.

=head1 COPYRIGHT

Copyright 2001 - 2011 Adam Kennedy.

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
