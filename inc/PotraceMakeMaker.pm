package inc::PotraceMakeMaker;
use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_WriteMakefile_args => sub {
   return {
      %{super()},
      INC => '-I/opt/local/include',
      LIBS => ['-L/opt/local/lib -lpotrace'],
   };
};

__PACKAGE__->meta->make_immutable;
