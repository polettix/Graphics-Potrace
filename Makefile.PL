use strict;
use warnings;
use ExtUtils::MakeMaker 6.31;

my %WriteMakefileArgs = (
  'NAME' => 'Graphics::Potrace',
  'VERSION' => '0.1.0',
  'PREREQ_PM' => {},
  'ABSTRACT' => 'bindings to the potrace library',
  'AUTHOR' => 'Flavio Poletti <polettix@cpan.org>',
  'DISTNAME' => 'Graphics-Potrace',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'test' => {
    'TESTS' => 't/*.t'
  },
  LIBS => [],
  INC => '-I.',
  OBJECT => 'Potrace.o libpotrace.a',
);
WriteMakefile(%WriteMakefileArgs);

use File::Copy;
use File::Spec;
foreach my $file (qw( libpotrace.a )) {
   my $fallback = File::Spec->catfile(fallback => $file);
   copy($fallback, $file) or die "File::Copy::copy to $file: $!";
}
