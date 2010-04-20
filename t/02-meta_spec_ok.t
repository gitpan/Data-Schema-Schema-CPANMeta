#!perl -T

use strict;
use warnings;
use FindBin '$Bin';
use Test::More;
use Data::Schema::Schema::CPANMeta qw(meta_spec_ok);

meta_spec_ok("$Bin/data/META.yml", 2);
meta_spec_ok("$Bin/data/META.json", 2);
meta_spec_ok("$Bin/data/META-1.4.yml", 1.4);

done_testing();
