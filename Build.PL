
use strict;
use warnings;

use Module::Build;

my $build = Module::Build->new(
  module_name   => 'Data::Schema::Schema::CPANMeta',
  license       => 'perl',
  dist_abstract => "Schema\ for\ CPAN\ Meta",
  dist_name     => "Data\-Schema\-Schema\-CPANMeta",
  dist_author   => [
"Steven\ Haryanto\ \<stevenharyanto\@gmail\.com\>",
  ],
  requires      => {
    "Data::Schema" => '0.13',
    "Test::More" => '0',
    "perl" => '5.010000',
    "FindBin" => '0',
    "Storable" => '0',
    "JSON" => '0',
    "YAML::Syck" => '0',
    "File::Slurp" => '0',
  },
  script_files => [ qw() ],
);

$build->create_build_script;
