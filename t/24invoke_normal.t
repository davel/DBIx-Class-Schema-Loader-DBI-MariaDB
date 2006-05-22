use strict;
use Test::More tests => 4;
use lib qw(t/lib);
use make_dbictest_db;

eval { require DBD::SQLite };
my $class = $@ ? 'SQLite2' : 'SQLite';

package DBICTest::Schema;
use base qw/ DBIx::Class::Schema::Loader /;

__PACKAGE__->loader_options( relationships => 1 );

package main;

my $schema_class = 'DBICTest::Schema';
my $schema = $schema_class->connect("dbi:$class:dbname=./t/dbictest.db");
isa_ok($schema, 'DBIx::Class::Schema');

my $foo_rs = $schema->resultset('Bar')->search({ barid => 3})->search_related('fooref');
isa_ok($foo_rs, 'DBIx::Class::ResultSet');

my $foo_first = $foo_rs->next;
isa_ok($foo_first, 'DBICTest::Schema::Foo');

my $foo_first_text = $foo_first->footext;
is($foo_first_text, 'This is the text of the only Foo record associated with the Bar with barid 3');
