package Graphics::Potrace::Bitmap::Ascii;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

# Module implementation here

sub load {
   my $bitmap = shift;
   my %param = ref $_[0] ? %{$_[0]} : @_;

   my $fh =
     exists $param{fh}
     ? $param{fh}
     : exists $param{file} ? do {
      open my $fh, '<', $param{file}
        or croak "open('$param{file}'): $OS_ERROR";
      $fh;
     }
     : exists $param{text} ? do {
      open my $fh, '<', \$param{text} or croak "open() on text: $OS_ERROR";
      $fh;
     }
     : croak(__PACKAGE__, "::load requires either fh, file or text");

   my $empty = $param{empty} || qr{(?mxs: [ .0])};

   $bitmap->reset();
   my $j = 0;
   while (<$fh>) {
      chomp();
      my @line = split //;
      for my $i (0 .. $#line) {
         $bitmap->set($i, $j, ($line[$i] !~ m{$empty}));
      }
      ++$j;
   } ## end while (<$fh>)
   $bitmap->mirror_vertical();

   return $bitmap;
} ## end sub load

1;
__END__

