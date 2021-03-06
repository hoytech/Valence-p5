use strict;

use ExtUtils::MakeMaker qw(6.48);
use File::ShareDir::Install;


die "the valence/app directory doesn't exist. if you are building from a git checkout, remember to run 'git submodule update --init'"
    if !-d 'valence/app';

install_share dist => 'valence/app';


my %args = (
    NAME => 'Valence',
    AUTHOR => ['Doug Hoyte <doug@hcsw.org>'],
    VERSION_FROM => 'lib/Valence.pm',
    ABSTRACT_FROM => 'lib/Valence.pm',
    PREREQ_PM => {
      'Alien::Electron' => '0.102',
      'common::sense' => 0,
      'AnyEvent' => 0,
      'Callback::Frame' => 0,
      'JSON::XS' => 0,
      'File::Spec' => 0,
      'File::ShareDir' => 0,
    },
    CONFIGURE_REQUIRES => {
      'File::ShareDir::Install' => 0,
    },
    LICENSE => 'perl',
    dist => {
      PREOP => 'pod2text $(VERSION_FROM) > $(DISTVNAME)/README',
    },
    META_MERGE => {
      resources => {
        repository => 'git://github.com/hoytech/Valence-p5.git',
        bugtracker => 'https://github.com/hoytech/Valence-p5/issues',
      },
    },
    MIN_PERL_VERSION => 5.6.0,
);

WriteMakefile(%args);

package MY;
use File::ShareDir::Install qw(postamble);
