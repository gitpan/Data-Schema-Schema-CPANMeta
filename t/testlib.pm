use strict;
use warnings;
use Data::Schema;
use Data::Schema::Schema::CPANMeta;
use Storable qw(dclone);

#use YAML;

our $cpan_meta_14 = Data::Schema::Schema::CPANMeta::schemas->{cpan_meta_14} or die;
our $cpan_meta_2  = Data::Schema::Schema::CPANMeta::schemas->{cpan_meta_2}  or die;
our $ds_14 = Data::Schema->new(schema => $cpan_meta_14);
our $ds_2  = Data::Schema->new(schema => $cpan_meta_2);

sub valid_14($$$) {
    my ($data, $sub, $test_name) = @_;
    my $backup = dclone($data);
    $sub->($backup);
    #print Dump($backup);
    my $res = $ds_14->validate($backup);
    ok($res->{success}, "$test_name (spec 1.4)");
    is_deeply($res->{errors}, [], "$test_name (spec 1.4) (error details)");
}

sub valid_2($$$) {
    my ($data, $sub, $test_name) = @_;
    my $backup = dclone($data);
    $sub->($backup);
    #print Dump($backup);
    my $res = $ds_2->validate($backup);
    ok($res->{success}, "$test_name (spec 2)");
    is_deeply($res->{errors}, [], "$test_name (spec 2) (error details)");
}

sub invalid_14($$$) {
    my ($data, $sub, $test_name) = @_;
    my $backup = dclone($data);
    $sub->($backup);
    my $res = $ds_14->validate($backup);
    ok(!$res->{success}, "$test_name (spec 1.4)");
}

sub invalid_2($$$) {
    my ($data, $sub, $test_name) = @_;
    my $backup = dclone($data);
    $sub->($backup);
    my $res = $ds_2->validate($backup);
    ok(!$res->{success}, "$test_name (spec 2)");
}

1;
