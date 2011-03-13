package Graphics::Potrace::Vector::Eps;

use strict;
use Carp;
use English qw( -no_match_vars );

sub save {
   my $vector = shift;
   my %param = ref $_[0] ? %{$_[0]} : @_;

   my $fh =
     exists $param{fh}
     ? $param{fh}
     : exists $param{file} ? do {
      open my $fh, '>', $param{file}
        or croak "open('$param{file}'): $OS_ERROR";
      $fh;
     }
     : exists $param{text} ? do {
      open my $fh, '>', $param{textref} or croak "open() on text: $OS_ERROR";
      $fh;
     }
     : croak(__PACKAGE__, "::save requires either fh, file or textref");

   my @groups = @{$vector->{list}};
   print {$fh} "%!PS-Adobe-3.0 EPSF-3.0\n";
   printf {$fh} "%%%%BoundingBox: 0 0 %d %d\n", $param{width}, $param{height};
   while (@groups) {
      my $group = shift @groups;
      my $curve = $group->{curve};
      printf {$fh} "%lf %lf moveto\n", @{$curve->[0]{begin}};
      for my $segment (@$curve) {
         if ($segment->{type} eq 'bezier') {
            printf {$fh} "%lf %lf %lf %lf %lf %lf curveto\n",
              @{$segment->{u}},
              @{$segment->{w}},
              @{$segment->{end}};
         } ## end if ($segment->{type} eq...
         else {
            printf {$fh} "%lf %lf lineto\n", @{$segment->{corner}};
            printf {$fh} "%lf %lf lineto\n", @{$segment->{end}};
         }
      } ## end for my $segment (@$curve)
      print {$fh} "0 setgray fill\n"
        if (!@groups) || ($groups[0]{sign} eq '+');
   } ## end while (@groups)
   print {$fh} "gsave\n";
   print {$fh} "grestore\n%EOF\n";

   return $vector;
} ## end sub save

1;
__END__
