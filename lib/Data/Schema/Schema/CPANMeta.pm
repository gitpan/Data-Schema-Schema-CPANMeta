package Data::Schema::Schema::CPANMeta;
our $VERSION = '0.06';


# ABSTRACT: Schema for CPAN Meta


use Test::More;
use Data::Schema;
use File::Slurp;
use YAML::Syck;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw($schema_14 $yaml_schema_14 meta_yaml_ok meta_spec_ok);


sub meta_yaml_ok {
    plan tests => 2;
    return meta_spec_ok(undef, undef, @_);
}


sub meta_spec_ok {
    my ($file, $vers, $msg) = @_;
    $file ||= 'META.yml';

    if (!$vers) {
        $vers = 1.4;
    } elsif ($vers != 1.4) {
        die "Currently only CPAN META specification version 1.4 is supported";
    }

    unless($msg) {
        $msg = "$file meets the designated specification";
        $msg .= " ($vers)" if($vers);
    }

    my $file_content = read_file $file;
    my $meta;
    eval '$meta = Load($file_content)';
    if($@) {
        ok(0, "$file contains valid YAML");
        ok(0, $msg);
        diag("  ERR: $@");
        return;
    } else {
        ok(1, "$file contains valid YAML");
    }

    my $ds = Data::Schema->new(schema => $schema_14);
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

    version: [str, {required: 1}] # XXX type:ver

    author:
      - array
      - required: 1
        minlen: 1
        of:
          - str
          - required: 1
            #XXX error levels not yet supported by DS
            #"match:WARN": '^\S.* <.+@.+>$'
            #"match:errmsg": 'preferred format is author-name <email-address>'

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
          file: [array, {of: [str, {required: 1}]}]
          directory: [array, {of: [str, {required: 1}]}]
          package: [array, {of: [str, required: 1, match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$']}] # XXX regex:pkg
          namespace: [array, {of: [str, required: 1, match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$']}] # XXX regex:pkg

    private: *no_index
    # XXX WARN: deprecated

    keywords: [array, {of: str}]

    resources:
      - hash

    generated_by: str
END_OF_SCHEMA

our $schema_14 = Load($yaml_schema_14);

our $DS_SCHEMAS = {
    cpan_meta_14 => $schema_14,
};

1;

__END__
=pod

=head1 NAME

Data::Schema::Schema::CPANMeta - Schema for CPAN Meta

=head1 VERSION

version 0.06

=head1 SYNOPSIS

 # you can use it in test script a la Test::CPAN::Meta

 use Test::More;
 use Data::Schema::Schema::CPANMeta qw(meta_yaml_ok);
 meta_yaml_ok();

 # slightly longer example

 use Test::More tests => ...;
 use Data::Schema::Schema::CPANMeta qw(meta_spec_ok);
 meta_spec_ok("META.yml", 1.4, "Bad META.yml!");

 # using outside test script

 use Data::Schema qw(Schema::CPANMeta);
 use YAML;
 use File::Slurp;
 my $meta = Load(scalar read_file "META.yml");
 my $res = ds_validate($meta, 'cpan_meta_14');

 # to get the schema as YAML string

 use Data::Schema::Schema::CPANMeta qw($yaml_schema_14);

=head1 DESCRIPTION

This module contains the schema for CPAN META.yml specification
version 1.4, in L<Data::Schema> language. If you import
C<$yaml_schema_14> (or browse the source of this module), you can find
the schema written as YAML.

You can use the schema to validate META.yml files.

=head1 FUNCTIONS

=head2 meta_yaml_ok([$msg])

Basic META.yml wrapper around meta_spec_ok.

Returns a hash reference to the contents of the parsed META.yml

=head2 meta_spec_ok($file, $version [,$msg])

Validates the named file against the given specification version. Both
$file and $version can be undefined.

Returns a hash reference to the contents of the given file, after it
has been parsed.

Note that unlike with C<meta_yaml_ok()>, this form requires you to
specify the number of tests you will be running in your test script
(or use C<done_testing()>). Also note that each C<meta_spec_ok()> is
actually 2 tests under the hood.

=head1 SEE ALSO

L<Data::Schema>

L<Module::Build>

L<Test::CPAN::Meta>

CPAN META.yml specification document, http://module-build.sourceforge.net/META-spec-v1.4.html

=head1 AUTHOR

  Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

