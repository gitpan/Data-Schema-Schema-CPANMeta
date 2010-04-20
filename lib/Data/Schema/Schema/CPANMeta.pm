package Data::Schema::Schema::CPANMeta;
our $VERSION = '0.07';
# ABSTRACT: Schema for CPAN Meta


use feature 'state';
use Test::More;
use Data::Schema;
use File::Slurp;
use JSON;
use YAML::Syck; $YAML::Syck::ImplicitTyping = 1;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw($schema_14 $yaml_schema_14
                    $schema_2 $yaml_schema_2
                    meta_yaml_ok meta_json_ok meta_spec_ok);


sub meta_yaml_ok {
    plan tests => 2;
    return meta_spec_ok("META.yml", undef, @_);
}


sub meta_json_ok {
    plan tests => 2;
    return meta_spec_ok("META.json", undef, @_);
}


sub meta_spec_ok {
    my ($file, $vers, $msg) = @_;
    $file ||= (-f "META.json") ? "META.json" : "META.yml";

    if (!$vers) {
        $vers = 2;
    } elsif ($vers != 1.4 && $vers != 2) {
        die "Currently only CPAN META specification versions ".
            "1.4 or 2 is supported";
    }

    unless($msg) {
        $msg = "$file meets the designated specification";
        $msg .= " ($vers)" if($vers);
    }

    my $file_content = read_file $file;
    my $meta;
    if ($file =~ /\.ya?ml$/i) {
        eval '$meta = Load($file_content)';
    } else {
        eval '$meta = from_json($file_content)';
    }
    if($@) {
        ok(0, "$file contains valid YAML/JSON");
        ok(0, $msg);
        diag("  ERR: $@");
        return;
    } else {
        ok(1, "$file contains valid YAML/JSON");
    }

    my $schema;
    if ($vers == 2) {
        $schema = $schema_2;
    } else {
        $schema = $schema_14;
    }

    my $ds = Data::Schema->new(schema => $schema);
    my $res = $ds->validate($meta);
    if ($res->{success}) {
        ok(1, $msg);
    } else {
        ok(0, $msg);
        diag("  ERR: ".join(", ", @{ $res->{errors} }));
    }
    return $yaml;
}


our $yaml_schema_14 = <<'END_OF_SCHEMA';
- hash
- required: 1
  required_keys: [name, abstract, version, author, license, meta-spec]
  keys:

    meta-spec:
      - hash
      - required: 1
        required_keys: [version, url]
        keys:
          version: [float, {required: 1, is: 1.4}]
          url: [str, {required: 1}] # XXX type:url

    name: [str, {required: 1, match: '^\w+(-\w+)*$'}]

    abstract: [str, {required: 1}]

    version: [str, {required: 1}]

    author:
      - array
      - required: 1
        minlen: 1
        of:
          - str
          - required: 1
            "match:warn": '^\S.* <.+@.+>$'
            "match:warnmsg": 'preferred format is author-name <email-address>'

    license:
      - str
      - required: 1
        one_of: [apache, artistic, artistic_2, bsd, gpl, lgpl, mit, mozilla,
                 open_source, perl, restrictive, unrestricted, unknown]

    distribution_type:
      - str
      - required: 1
        one_of: [module, script]

    requires: &modlist
      - hash
      - required: 1
        keys_match: '^(perl|[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*)$' # XXX: regex:perl|pkg
        values_of: [str, {required: 1}] # XXX type:ver

    build_requires: *modlist

    configure_requires: *modlist

    recommends: *modlist

    conflicts: *modlist

    optional_features:
      - hash
      - values_of:
          - hash
          - required: 1
            keys:
              description: str
              requires: *modlist
              build_requires: *modlist
              recommends: *modlist
              conflicts: *modlist

    dynamic_config: bool

    provides:
      - hash
      - required: 1
        keys_match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$' # XXX regex:pkg
        values_of:
          - hash
          - required_keys: [file, version]
            keys:
              file: str
              version: str # XXX type:ver

    no_index: &no_index
      - hash
      - keys:
          file: [array, {required: 1, of: [str, {required: 1}]}]
          directory: [array, {required: 1, of: [str, {required: 1}]}]
          package: [array, {of: [str, required: 1, match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$']}] # XXX regex:pkg
          namespace: [array, {of: [str, required: 1, match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$']}] # XXX regex:pkg

    private: *no_index
    # XXX WARN: deprecated

    keywords:  [array, {required: 1, of: [str, {required: 1}]}]

    resources:
      - hash

    generated_by: str
END_OF_SCHEMA

our $schema_14 = Load($yaml_schema_14);

my $v_re = '(\d+(\.\d+(_\d+)?)?|v\d+(\.\d+)+[._]\d+)';

our $yaml_schema_2 = q~
def:
  namespace: [str, {match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$'}]
  package: [str, {match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$'}]
  version: [str, {match: '^~.$v_re.q~$'}]
  version_range: [str, {match: '^(~.$v_re.q~$|(>=?|<=?|==|!=)\s*~.$v_re.q~(,\s*(>=?|<=?|==|!=)\s*~.$v_re.q~)*)$'}]
  relations:
    - hash
    - keys_of: package
      values_of: [version_range, {required: 1}]
  prereq:
    - hash
    - allowed_keys: [requires, recommends, suggests, conflicts]
      values_of: relations
  prereqs:
    - hash
    - allowed_keys: [configure, build, test, runtime, develop]
      values_of: [prereq, {required: 1}]
  optional_features_prereqs:
    - prereqs
    - -allowed_keys: [configure]
  no_index:
    - hash
    - required: 1
      keys:
        file: [array, {required: 1, of: [str, {required: 1}]}]
        directory: [array, {required: 1, of: [str, {required: 1}]}]
        package: [array, {required: 1, of: [package, {required: 1}]}]
        namespace: [array, {required: 1, of: [namespace, {required: 1}]}]

type: hash

attrs:
  required: 1
  required_keys: [abstract, author, dynamic_config, generated_by,
                  license, meta-spec, name, release_status]
  keys:

    abstract: [str, {required: 1}]

    author:
      - array
      - required: 1
        minlen: 1
        of:
          - str
          - required: 1
            "match:warn": '^\S.* <.+@.+>$'
            "match:warnmsg": 'preferred format is author-name <email-address>'

    build_requires:
      - relations
      - required: 1
        "forbidden:warn": 1
        "forbidden:warnmsg": build_requires is deprecated in spec 2 and has been replaced by prereqs

    configure_requires:
      - relations
      - required: 1
        "forbidden:warn": 1
        "forbidden:warnmsg": configure_requires is deprecated in spec 2 and has been replaced by prereqs

    conflicts:
      - relations
      - required: 1
        "forbidden:warn": 1
        "forbidden:warnmsg": conflicts is deprecated in spec 2 and has been replaced by prereqs

    description: [str, {required: 1}]

    distribution_type:
      - str
      - required: 1
        one_of: [module, script]
        "forbidden:warn": 1
        "forbidden:warnmsg": distribution_type is deprecated in spec 2 since it is meaningless for many distributions which are hybrid or modules and scripts

    dynamic_config: [bool, {required: 1}]

    generated_by: [str, {required: 1}]

    keywords:
      - array
      - required: 1
        of:
          - str
          - required: 1
            match: '^\S+$'

    license:
      - array
      - required: 1
        minlen: 1
        of:
          - str
          - required: 1
            one_of: [agpl_3, apache_1_1, apache_2_0, artistic_1,
                     artistic_2, bsd, freebsd, gfdl_1_2, gfdl_1_3,
                     gpl_1, gpl_2, gpl_3, lgpl_2_1, lgpl_3_0, mit,
                     mozilla_1_0, mozilla_1_1, openssl, perl_5,
                     qpl_1_0, ssleay, sun, zlib, open_source,
                     restricted, unrestricted, unknown]

    license_uri:
      - str
      - required: 1
        "forbidden:warn": 1
        "forbidden:warnmsg": license_uri is deprecated in 1.2 and has been replaced by license in resources

    meta-spec:
      - hash
      - required: 1
        required_keys: [version]
        keys:
          version: [float, {required: 1, is: 2}]
          url: [str, {required: 1}]

    name: [str, {required: 1, match: '^\w+(-\w+)*$'}]

    no_index:
      - no_index
      - required: 1

    optional_features:
      - hash
      - values_of:
          - hash
          - required: 1
            keys:
              description: str
              prereqs:
                - optional_features_prereqs
                - required: 1
              requires:
                - relations
                - required: 1
                  "forbidden:warn": 1
                  "forbidden:warnmsg": requires is deprecated in spec 2 and has been replaced by prereqs
              build_requires:
                - relations
                - required: 1
                  "forbidden:warn": 1
                  "forbidden:warnmsg": build_requires is deprecated in spec 2 and has been replaced by prereqs
              recommends:
                - relations
                - required: 1
                  "forbidden:warn": 1
                  "forbidden:warnmsg": recommends is deprecated in spec 2 and has been replaced by prereqs
              conflicts:
                - relations
                - required: 1
                  "forbidden:warn": 1
                  "forbidden:warnmsg": conflicts is deprecated in spec 2 and has been replaced by prereqs

    prereqs:
      - prereqs
      - required: 1

    private:
      - no_index
      - required: 1
        "forbidden:warn": 1
        "forbidden:warnmsg": private is deprecated in spec 1.2 and has been renamed to no_index

    provides:
      - hash
      - required: 1
        keys_of: package
        values_of:
          - hash
          - required: 1
            required_keys: [file, version]
            keys:
              file: [str, {required: 1}]
              version: [version, {required: 1}]

    recommends:
      - relations
      - required: 1
        "forbidden:warn": 1
        "forbidden:warnmsg": recommends is deprecated in spec 2 and has been replaced by prereqs

    release_status:
      - str
      - required: 1
        one_of: [stable, testing, unstable]

    requires:
      - relations
      - required: 1
        "forbidden:warn": 1
        "forbidden:warnmsg": requires is deprecated in spec 2 and has been replaced by prereqs

    resources:
      - hash
      - required: 1
        allowed_keys: [homepage, license, bugtracker, repository]

    version: [version, {required: 1}]

  key_deps:
    # if version contains underscore, release_status must not be stable
    - [version, [str, {match: '_'}], release_status, [str, {not: stable}]]
~;

our $schema_2 = Load($yaml_schema_2);

# XXX remove in DS 0.14
sub name {
    'cpan_meta_2';
}

our $DS_SCHEMAS = {
    cpan_meta_14 => $schema_14,
    cpan_meta_2 => $schema_2,
};

sub schemas {
    $DS_SCHEMAS;
}

1;

__END__
=pod

=head1 NAME

Data::Schema::Schema::CPANMeta - Schema for CPAN Meta

=head1 VERSION

version 0.07

=head1 SYNOPSIS


 # you can use it in test script a la Test::CPAN::Meta

 use Test::More;
 use Data::Schema::Schema::CPANMeta qw(meta_yaml_ok);
 meta_yaml_ok();

 # test META.json instead of META.yml

 use Test::More;
 use Data::Schema::Schema::CPANMeta qw(meta_json_ok);
 meta_json_ok();

 # slightly longer example

 use Test::More tests => ...;
 use Data::Schema::Schema::CPANMeta qw(meta_spec_ok);
 meta_spec_ok("META.yml", 1.4, "Bad META.yml!");

 # JSON version

 use Test::More tests => ...;
 use Data::Schema::Schema::CPANMeta qw(meta_spec_ok);
 meta_spec_ok("META.json", 2, "Bad META.json!");

 # using outside test script

 use Data::Schema qw(Schema::CPANMeta);
 use YAML;
 use File::Slurp;
 my $meta = Load(scalar read_file "META.yml");
 my $res = ds_validate($meta, 'cpan_meta_2');

 # to get the schema as YAML string

 use Data::Schema::Schema::CPANMeta qw($yaml_schema_2 $yaml_schema_14);

=head1 DESCRIPTION


This module contains the schema for CPAN META.yml specification
version 1.4 and 2, in L<Data::Schema> language. If you import
C<$yaml_schema_14> and C<$yaml_schema_2> (or browse the source of this
module), you can find the schema written as YAML.


You can use the schema to validate META.yml or META.json files.

=head1 FUNCTIONS


=head2 meta_yaml_ok([$msg])


Basic META.yml wrapper around meta_spec_ok.


Returns a hash reference to the contents of the parsed META.yml


=head2 meta_json_ok([$msg])


Basic META.json wrapper around meta_spec_ok.


Returns a hash reference to the contents of the parsed META.json


=head2 meta_spec_ok($file, $version [,$msg])


Validates the named file against the given specification version. Both
$file and $version can be undefined.


Returns a hash reference to the contents of the given file, after it
has been parsed.


Note that unlike with C<meta_yaml_ok()> or C<meta_json_ok()>, this
form requires you to specify the number of tests you will be running
in your test script (or use C<done_testing()>). Also note that each
C<meta_spec_ok()> is actually 2 tests under the hood.

=head1 SEE ALSO


L<Data::Schema>


L<Module::Build>


L<Test::CPAN::Meta>


CPAN META.yml specification document, http://module-build.sourceforge.net/META-spec-v1.4.html

=head1 AUTHOR

  Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

