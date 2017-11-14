package PPI::Future::XSAccessor;

# This is an experimental prototype, use at your own risk.
# Provides optional enhancement of PPI::Future with Class::XSAccessor (if installed)

use 5.006;
use strict;
use PPI::Future ();

our $VERSION = '1.236';





######################################################################
# Replacement Methods

# Packages are implemented here in alphabetical order

package #hide from indexer
	PPI::Future::Document;

use Class::XSAccessor
	replace => 1,
	getters => {
		readonly => 'readonly',
	},
	true    => [
		'scope'
	];

package #hide from indexer
	PPI::Future::Document::File;

use Class::XSAccessor
	replace => 1,
	getters => {
		filename => 'filename',
	};

package #hide from indexer
	PPI::Future::Document::Fragment;

use Class::XSAccessor
	replace => 1,
	false   => [
		'scope',
	];

package #hide from indexer
	PPI::Future::Document::Normalized;

use Class::XSAccessor
	replace => 1,
	getters => {
		'_Document' => 'Document',
		'version'   => 'version',
		'functions' => 'functions',
	};

package #hide from indexer
	PPI::Future::Element;

use Class::XSAccessor
	replace => 1,
	true    => [
		'significant',
	];

package #hide from indexer
	PPI::Future::Exception;

use Class::XSAccessor
	replace => 1,
	getters => {
		message => 'message',
	};

package #hide from indexer
	PPI::Future::Node;

use Class::XSAccessor
	replace => 1,
	false   => [
		'scope',
	];

package #hide from indexer
	PPI::Future::Normal;

use Class::XSAccessor
	replace => 1,
	getters => {
		'layer' => 'layer',
	};

package #hide from indexer
	PPI::Future::Statement;

use Class::XSAccessor
	replace => 1,
	true    => [
		'__LEXER__normal',
	];

package #hide from indexer
	PPI::Future::Statement::Compound;

use Class::XSAccessor
	replace => 1,
	true    => [
		'scope',
	],
	false   => [
		'__LEXER__normal',
	];

package #hide from indexer
	PPI::Future::Statement::Data;

use Class::XSAccessor
	replace => 1,
	false   => [
		'_complete',
	];

package #hide from indexer
	PPI::Future::Statement::End;

use Class::XSAccessor
	replace => 1,
	true    => [
		'_complete',
	];

package #hide from indexer
	PPI::Future::Statement::Given;

use Class::XSAccessor
	replace => 1,
	true    => [
		'scope',
	],
	false   => [
		'__LEXER__normal',
	];

package #hide from indexer
	PPI::Future::Token;

use Class::XSAccessor
	replace => 1,
	getters => {
		content => 'content',
	},
	setters => {
		set_content => 'content',
	},
	true => [
		'__TOKENIZER__on_line_start',
		'__TOKENIZER__on_line_end',
	];

1;
