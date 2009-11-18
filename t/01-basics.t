#!perl -T

use strict;
use warnings;
use Test::More;
use File::Slurp;
use FindBin '$Bin';
use YAML::XS;
use lib './t';

require 'testlib.pm';

my $meta = Load(scalar read_file("$Bin/data/META.yml"));

valid($meta, sub {}, "valid");

invalid($meta, sub { shift->{foo} = 1 }, "unknown key");

invalid($meta, sub { delete shift->{"meta-spec"} }, "missing meta-spec");
invalid($meta, sub { delete shift->{"meta-spec"}{version} }, "missing meta-spec/version");
invalid($meta, sub { delete shift->{"meta-spec"}{url} }, "missing meta-spec/url");
invalid($meta, sub { shift->{"meta-spec"}{version} = 1.5 }, "meta-spec version not 1.4");

invalid($meta, sub { delete shift->{name} }, "missing name");
invalid($meta, sub { shift->{name} = 'Foo Bar' }, "invalid name");

invalid($meta, sub { delete shift->{version} }, "missing version");
invalid($meta, sub { shift->{version} = [] }, "invalid version");

invalid($meta, sub { delete shift->{abstract} }, "missing abstract");

invalid($meta, sub { delete shift->{author} }, "missing author");
invalid($meta, sub { shift->{author} = [] }, "no author");
#has_warning($meta, sub { shift->{author}[0] = 'foo bar' }, "author not in 'name <email>' form");

invalid($meta, sub { delete shift->{license} }, "missing license");
invalid($meta, sub { shift->{license} = 'foo' }, "invalid license");

# distribution_type is optional
invalid($meta, sub { shift->{distribution_type} = 'foo' }, "invalid distribution_type");

# requires is optional
invalid($meta, sub { shift->{requires}{'foo bar'} = 0 }, "invalid requires");

# build_requires is optional
invalid($meta, sub { shift->{build_requires}{'foo bar'} = 0 }, "invalid build_requires");

# configure_requires is optional
invalid($meta, sub { shift->{configure_requires}{'foo bar'} = 0 }, "invalid configure_requires");

# recommends is optional
invalid($meta, sub { shift->{recommends}{'foo bar'} = 0 }, "invalid recommends");

# conflicts is optional
invalid($meta, sub { shift->{conflicts}{'foo bar'} = 0 }, "invalid conflicts");

# optional_features is optional
invalid($meta, sub { shift->{optional_features} = 1 }, "invalid optional_features 1");
invalid($meta, sub { shift->{optional_features}{foo} = 1 }, "invalid optional_features 2");
invalid($meta, sub { shift->{optional_features}{foo}{'configure_requires'}{'foo::bar'} = 0 }, "invalid optional_features 3");
valid  ($meta, sub { shift->{optional_features}{foo}{'requires'}{'foo::bar'} = 0 }, "valid optional_features 1");

# dynamic_config is optional

# XXX private deprecation warning

# provides is optional
invalid($meta, sub { shift->{provides} = 1 }, "invalid provides 1");
invalid($meta, sub { shift->{provides} = {foo => 1} }, "invalid provides 2");
invalid($meta, sub { shift->{provides} = {foo => {bar => 1}} }, "invalid provides 3");
invalid($meta, sub { shift->{provides} = {foo => {version=>1.0}} }, "invalid provides 3: missing file");
invalid($meta, sub { shift->{provides} = {foo => {file=>'/foo/bar'}} }, "invalid provides 4: missing version");
valid  ($meta, sub { shift->{provides} = {foo => {file=>'/foo/bar', version=>1.0}} }, "valid provides 1");

# no_index is optional
invalid($meta, sub { shift->{no_index} = 1 }, "invalid no_index 1");
invalid($meta, sub { shift->{no_index} = {foo => 1} }, "invalid no_index 2");
invalid($meta, sub { shift->{no_index} = {file => 1} }, "invalid no_index 3");
valid  ($meta, sub { shift->{no_index} = {file => [1, 2]} }, "valid no_index 1");
invalid($meta, sub { shift->{no_index} = {package => ['foo bar']} }, "invalid no_index 4: invalid package");
valid  ($meta, sub { shift->{no_index} = {package => ['foo::bar']} }, "valid no_index 2");

# keywords is optional
invalid($meta, sub { shift->{keywords} = 'foo' }, "invalid keywords: must be array");
valid  ($meta, sub { shift->{keywords} = ['foo'] }, "valid keywords");

# resources is optional
invalid($meta, sub { shift->{resources} = 'foo' }, "invalid resources: must be hash");
valid  ($meta, sub { shift->{resources} = {} }, "valid resources");

# resources is optional
invalid($meta, sub { shift->{generated_by} = [] }, "invalid generated_by: must be str");
valid  ($meta, sub { shift->{generated_by} = 'foo' }, "valid generated_by");

done_testing();
