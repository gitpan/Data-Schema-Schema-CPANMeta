
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'Data-Schema-Schema-CPANMeta',
  NAME      => 'Data::Schema::Schema::CPANMeta',
  AUTHOR    => "Steven\ Haryanto\ \<stevenharyanto\@gmail\.com\>",
  ABSTRACT  => "Schema\ for\ CPAN\ Meta",
  VERSION   => '0.06',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'perl') : ()),
  PREREQ_PM    => {
    "Test::More" => '0',
    "Data::Schema" => '0.13',
    "FindBin" => '0',
    "Storable" => '0',
    "YAML::Syck" => '0',
    "File::Slurp" => '0',
  },
  test => {TESTS => 't/*.t'}
);

