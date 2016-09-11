package Graphics::Potrace::Vectorial::Eps;

# ABSTRACT: Encapsulated Postscript exporter for Graphics::Potrace

use strict;
use Carp;
use English qw( -no_match_vars );

use Moo;
extends 'Graphics::Potrace::Vectorial::Exporter';

sub save {
   my $self = shift;
   my $fh = $self->fh();

   # Header
   print {$fh} "%!PS-Adobe-3.0 EPSF-3.0\n";
   printf {$fh} "%%%%BoundingBox: 0 0 %d %d\n",
      $self->boundaries();

   # Every vector
   $self->_save_core($fh, $_) for @_;

   # Footer
   print {$fh} "%EOF\n";

   return;
} ## end sub save

sub _save_core {
   my ($self, $fh, $vector) = @_;

   my $colorline = exists $vector->{color}
      ? sprintf("%.4f %.4f %.4f setrgbcolor fill\n", @{$vector->{color}})
      : "0 setgray fill\n";

   my @groups      = @{$vector->list()};
   my $closed_path = 1;
   while (@groups) {
      my $group = shift @groups;
      my $curve = $group->{curve};
      print {$fh} "newpath\n" if $closed_path;
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
      $closed_path = (!@groups) || ($groups[0]{sign} eq '+');
      if ($closed_path) {
         print {$fh} "closepath\n";
         print {$fh} "gsave\n";
         print {$fh} $colorline;
         print {$fh} "grestore\n";
      } ## end if ($closed_path)
   } ## end while (@groups)

   return $vector;
} ## end sub save_core

1;
__END__

=encoding utf-8

=head1 DESCRIPTION

L<Graphics::Potrace::Vectorial::Exporte> derived class to provide export
facilities to Encapsulated Postscript.

=head1 INTERFACE

=head2 B<< save >>

Overrides L<Graphics::Potrace::Vectorial::Exporter/save> method to provide
something useful.
