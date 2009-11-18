package Data::Schema::Schema::CPANMeta;
our $VERSION = '0.01';


# ABSTRACT: Schema for CPAN Meta


use YAML::XS;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw($schema_14);

our $schema_14 = Load(<<'END_OF_SCHEMA');
- hash
- required: true
  required_keys: [name, abstract, version, author, license, meta-spec]
  keys:

    meta-spec:
      - hash
      - required: true
        required_keys: [version, url]
        keys:
          version: [float, {required: true, is: 1.4}]
          url: [str, {required: true}] # XXX type:url

    name: [str, {required: true, match: '^\w+(-\w+)*$'}]

    abstract: [str, {required: true}]

    version: [str, {required: true}] # XXX type:ver

    author:
      - array
      - required: true
        minlen: 1
        of:
          - str
          - required: true
            #XXX error levels not yet supported by DS
            #"match:WARN": '^\S.* <.+@.+>$'
            #"match:errmsg": 'preferred format is author-name <email-address>'

    license:
      - str
      - required: true
        one_of: [apache, artistic, artistic_2, bsd, gpl, lgpl, mit, mozilla,
                 open_source, perl, restrictive, unrestricted, unknown]

    distribution_type:
      - str
      - required: true
        one_of: [module, script]

    requires: &modlist
      - hash
      - required: true
        keys_match: '^(perl|[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*)$' # XXX: regex:perl|pkg
        values_of: [str, {required: true}] # XXX type:ver

    build_requires: *modlist

    configure_requires: *modlist

    recommends: *modlist

    conflicts: *modlist

    optional_features:
      - hash
      - values_of:
          - hash
          - required: true
            keys:
              description: str
              requires: *modlist
              build_requires: *modlist
              recommends: *modlist
              conflicts: *modlist

    dynamic_config: bool

    provides:
      - hash
      - required: true
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
          file: [array, {of: [str, {required: true}]}]
          directory: [array, {of: [str, {required: true}]}]
          package: [array, {of: [str, required: true, match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$']}] # XXX regex:pkg
          namespace: [array, {of: [str, required: true, match: '^[A-Za-z0-9_]+(::[A-Za-z0-9_]+)*$']}] # XXX regex:pkg

    private: *no_index
    # XXX WARN: deprecated

    keywords: [array, {of: str}]

    resources:
      - hash

    generated_by: str
END_OF_SCHEMA
1;

__END__
=pod

=head1 NAME

Data::Schema::Schema::CPANMeta - Schema for CPAN Meta

=head1 VERSION

version 0.01

=head1 SYNOPSIS

 use Data::Schema; # ds_validate
 use Data::Schema::Schema::CPANMeta qw($schema_14);
 use YAML; # Load, Dump
 use File::Slurp; # read_file

 my $meta = Load(scalar read_file "META.yml");
 my $res = ds_validate($meta, $schema_14);
 $res->{success} or die Dump $res->{errors};

=head1 DESCRIPTION

This module contains the schema for CPAN META.yml specification
version 1.4, in L<Data::Schema> language. If you browse the source of
this module, you can find the schema written as YAML.

You can use the schema to validate META.yml files.

=head1 SEE ALSO

L<Data::Schema>

L<Module::Build>

CPAN META.yml specification document, http://module-build.sourceforge.net/META-spec-v1.4.html

=head1 AUTHOR

  Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

