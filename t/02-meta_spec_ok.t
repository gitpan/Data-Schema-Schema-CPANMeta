#!perl -T

use strict;
use warnings;
use FindBin '$Bin';
use Test::More;
use Data::Schema::Schema::CPANMeta qw(meta_spec_ok);

meta_spec_ok("$Bin/data/META.yml");

done_testing();
