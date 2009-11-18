#!perl -T

use strict;
use warnings;
use FindBin '$Bin';
use Test::More;
use Data::Schema::Schema::CPANMeta qw(meta_yaml_ok);

($Bin) = $Bin =~ /(.*)/;
chdir "$Bin/data" or die;

meta_yaml_ok();
