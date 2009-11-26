use strict;
use warnings;
use Data::Schema;
use Data::Schema::Schema::CPANMeta;
use Storable qw(dclone);

#use YAML;

my $cpan_meta_14 = $Data::Schema::Schema::CPANMeta::DS_SCHEMAS->{cpan_meta_14};
my $ds = Data::Schema->new(schema => $cpan_meta_14);

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
