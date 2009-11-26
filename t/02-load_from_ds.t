#!perl -T

use strict;
use warnings;
use Test::More tests => 2;
use File::Slurp;
use FindBin '$Bin';
use YAML::Syck;

use Data::Schema qw(Schema::CPANMeta);

my $meta = Load(scalar read_file("$Bin/data/META.yml"));

ok( ds_validate($meta, "cpan_meta_14")->{success}, "load schema from DS 1");
delete $meta->{"meta-spec"};
ok(!ds_validate($meta, "cpan_meta_14")->{success}, "load schema from DS 2");
