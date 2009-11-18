use strict;
use warnings;
use Data::Schema;
use Data::Schema::Schema::CPANMeta qw($schema_14);
use Storable qw(dclone);

#use YAML;

my $ds = Data::Schema->new(schema => $schema_14);

sub valid($$$) {
    my ($data, $sub, $test_name) = @_;
    my $backup = dclone($data);
    $sub->($backup);
    #print Dump($backup);
    my $res = $ds->validate($backup);
    ok($res->{success}, $test_name);
    is_deeply($res->{errors}, [], "$test_name (error details)");
}

sub invalid($$$) {
    my ($data, $sub, $test_name) = @_;
    my $backup = dclone($data);
    $sub->($backup);
    my $res = $ds->validate($backup);
    ok(!$res->{success}, $test_name);
}

1;
