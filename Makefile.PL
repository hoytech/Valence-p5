use strict;

use ExtUtils::MakeMaker;
use File::ShareDir::Install;


install_share dist => 'valence';


my %args = (
    NAME => 'Valence',
    VERSION_FROM => 'lib/Valence.pm',
    PREREQ_PM => {
      'common::sense' => 0,
      'AnyEvent' => 0,
      'Callback::Frame' => 0,
      'JSON::XS' => 0,
      'File::Spec' => 0,
      'Alien::Electron' => 0,
      'File::ShareDir' => 0,
    },
    CONFIGURE_REQUIRES => {
      'File::ShareDir::Install' => 0,
    },
    LIBS => [],
    DEFINE => '',
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
);

WriteMakefile(%args);

package MY;
use File::ShareDir::Install qw(postamble);
