#!perl -T

use strict;
use warnings;
use Test::More tests => 4;
use File::Slurp;
use FindBin '$Bin';
use YAML::Syck; $YAML::Syck::ImplicitTyping = 1;

use Data::Schema qw(Schema::CPANMeta);

my $meta_14 = Load(scalar read_file("$Bin/data/META-1.4.yml"));
my $meta_2  = Load(scalar read_file("$Bin/data/META.yml"));

ok( ds_validate($meta_14, "cpan_meta_14")->{success}, "load schema from DS 1 (1.4)");
delete $meta_14->{"meta-spec"};
ok(!ds_validate($meta_14, "cpan_meta_14")->{success}, "load schema from DS 2 (1.4)");

ok( ds_validate($meta_2, "cpan_meta_2")->{success}, "load schema from DS 1 (2)");
delete $meta_2->{"meta-spec"};
ok(!ds_validate($meta_2, "cpan_meta_2")->{success}, "load schema from DS 2 (2)");
