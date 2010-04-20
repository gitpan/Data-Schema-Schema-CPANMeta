#!perl -T

use strict;
use warnings;
use FindBin '$Bin';
use Test::More;
use Data::Schema::Schema::CPANMeta qw(meta_json_ok);

($Bin) = $Bin =~ /(.*)/;
chdir "$Bin/data" or die;

meta_json_ok();
