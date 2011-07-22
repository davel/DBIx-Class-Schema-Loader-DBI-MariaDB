use strict;
use Test::More;
use Test::Exception;
use Test::Warn;
use lib qw(t/lib);
use File::Slurp qw(slurp);
use File::Path;
use make_dbictest_db_comments;
use dbixcsl_test_dir qw/$tdir/;

my $dump_path = "$tdir/dump";

{
    package DBICTest::Schema::1;
    use base qw/ DBIx::Class::Schema::Loader /;
    __PACKAGE__->loader_options(
        dump_directory => $dump_path,
    );
}

DBICTest::Schema::1->connect($make_dbictest_db_comments::dsn);

plan tests => 4;

my $foo = slurp("$dump_path/DBICTest/Schema/1/Result/Foo.pm");
my $bar = slurp("$dump_path/DBICTest/Schema/1/Result/Bar.pm");

like($foo, qr/Result::Foo - a short comment/, 'Short table comment inline');
like($bar, qr/Result::Bar\n\n=head1 DESCRIPTION\n\na (very ){80}long comment/,
    'Long table comment in DESCRIPTION');

like($foo, qr/=head2 fooid\n\n( .*\n)+\na short comment/,
    'Short column comment recorded');
like($foo, qr/=head2 footext\n\n( .*\n)+\na (very ){80}long comment/,
    'Long column comment recorded');

END { rmtree($dump_path, 1, 1); }
