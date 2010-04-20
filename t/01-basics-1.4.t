#!perl -T

use lib './t'; require 'testlib.pm';
use strict;
use warnings;
use Test::More tests => 51;
use File::Slurp;
use FindBin '$Bin';
use YAML::Syck; $YAML::Syck::ImplicitTyping = 1;

my $meta = Load(scalar read_file("$Bin/data/META-1.4.yml"));

valid_14($meta, sub {}, "valid");

invalid_14($meta, sub { shift->{foo} = 1 }, "unknown key");

invalid_14($meta, sub { delete shift->{"meta-spec"} }, "missing meta-spec");
invalid_14($meta, sub { delete shift->{"meta-spec"}{version} }, "missing meta-spec/version");
invalid_14($meta, sub { delete shift->{"meta-spec"}{url} }, "missing meta-spec/url");
invalid_14($meta, sub { shift->{"meta-spec"}{version} = 2 }, "meta-spec version not 1.4");

invalid_14($meta, sub { delete shift->{name} }, "missing name");
invalid_14($meta, sub { shift->{name} = 'Foo Bar' }, "invalid name");

invalid_14($meta, sub { delete shift->{version} }, "missing version");
invalid_14($meta, sub { shift->{version} = [] }, "invalid version");

invalid_14($meta, sub { delete shift->{abstract} }, "missing abstract");

invalid_14($meta, sub { delete shift->{author} }, "missing author");
invalid_14($meta, sub { shift->{author} = [] }, "no author");
#has_warning($meta, sub { shift->{author}[0] = 'foo bar' }, "author not in 'name <email>' form");

invalid_14($meta, sub { delete shift->{license} }, "missing license");
invalid_14($meta, sub { shift->{license} = 'foo' }, "invalid license");

# distribution_type is optional
invalid_14($meta, sub { shift->{distribution_type} = 'foo' }, "invalid distribution_type");

# requires is optional
invalid_14($meta, sub { shift->{requires}{'foo bar'} = 0 }, "invalid requires");

# build_requires is optional
invalid_14($meta, sub { shift->{build_requires}{'foo bar'} = 0 }, "invalid build_requires");

# configure_requires is optional
invalid_14($meta, sub { shift->{configure_requires}{'foo bar'} = 0 }, "invalid configure_requires");

# recommends is optional
invalid_14($meta, sub { shift->{recommends}{'foo bar'} = 0 }, "invalid recommends");

# conflicts is optional
invalid_14($meta, sub { shift->{conflicts}{'foo bar'} = 0 }, "invalid conflicts");

# optional_features is optional
invalid_14($meta, sub { shift->{optional_features} = 1 }, "invalid optional_features 1");
invalid_14($meta, sub { shift->{optional_features}{foo} = 1 }, "invalid optional_features 2");
invalid_14($meta, sub { shift->{optional_features}{foo}{'configure_requires'}{'foo::bar'} = 0 }, "invalid optional_features 3");
valid_14  ($meta, sub { shift->{optional_features}{foo}{'requires'}{'foo::bar'} = 0 }, "valid optional_features 1");

# dynamic_config is optional

# XXX private deprecation warning

# provides is optional
invalid_14($meta, sub { shift->{provides} = 1 }, "invalid provides 1");
invalid_14($meta, sub { shift->{provides} = {foo => 1} }, "invalid provides 2");
invalid_14($meta, sub { shift->{provides} = {foo => {bar => 1}} }, "invalid provides 3");
invalid_14($meta, sub { shift->{provides} = {foo => {version=>1.0}} }, "invalid provides 3: missing file");
invalid_14($meta, sub { shift->{provides} = {foo => {file=>'/foo/bar'}} }, "invalid provides 4: missing version");
valid_14  ($meta, sub { shift->{provides} = {foo => {file=>'/foo/bar', version=>1.0}} }, "valid provides 1");

# no_index is optional
invalid_14($meta, sub { shift->{no_index} = 1 }, "invalid no_index 1");
invalid_14($meta, sub { shift->{no_index} = {foo => 1} }, "invalid no_index 2");
invalid_14($meta, sub { shift->{no_index} = {file => 1} }, "invalid no_index 3");
valid_14  ($meta, sub { shift->{no_index} = {file => [1, 2]} }, "valid no_index 1");
invalid_14($meta, sub { shift->{no_index} = {package => ['foo bar']} }, "invalid no_index 4: invalid package");
valid_14  ($meta, sub { shift->{no_index} = {package => ['foo::bar']} }, "valid no_index 2");

# keywords is optional
invalid_14($meta, sub { shift->{keywords} = 'foo' }, "invalid keywords: must be array");
valid_14  ($meta, sub { shift->{keywords} = ['foo'] }, "valid keywords");

# resources is optional
invalid_14($meta, sub { shift->{resources} = 'foo' }, "invalid resources: must be hash");
valid_14  ($meta, sub { shift->{resources} = {} }, "valid resources");

# resources is optional
invalid_14($meta, sub { shift->{generated_by} = [] }, "invalid generated_by: must be str");
valid_14  ($meta, sub { shift->{generated_by} = 'foo' }, "valid generated_by");
