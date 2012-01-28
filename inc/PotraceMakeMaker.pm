package inc::PotraceMakeMaker;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_WriteMakefile_args => sub {
   return {
      %{super()},
      INC => '',
      LIBS => [],
   };
};

__PACKAGE__->meta->make_immutable;
