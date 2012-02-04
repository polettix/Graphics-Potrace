package Graphics::Potrace::Vector::Svg;

# ABSTRACT: Encapsulated Postscript exporter for Graphics::Potrace

use strict;
use Carp;
use English qw( -no_match_vars );

use Moo;
extends 'Graphics::Potrace::Vector::Exporter';

sub save {
   my $self = shift;
   my $fh = $self->fh();

   # Header
   my $header_template = <<'END_OF_HEADER';
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg width="%d" height="%d" version="1.1" xmlns="http://www.w3.org/2000/svg">
END_OF_HEADER
   printf {$fh} $header_template, $self->boundaries(@_);

   # Save vector
   $self->_save_core($fh, $_) for @_;

   # Footer
   print {$fh} "</svg>\n";

   return;
} ## end sub save

sub _save_core {
   my ($self, $fh, $vector) = @_;

   printf {$fh} "<g style=\"fill:%s;stroke:none\" transform=\"matrix(1, 0, 0, -1, 0, %d)\">\n",
      $vector->{color} || 'black', $vector->height();
#   printf {$fh} "<g style=\"fill:%s;stroke:none\">\n",
#      $vector->{color} || 'black';

   my @groups      = @{$vector->list()};
   my $closed_path = 1;
   while (@groups) {
      my $group = shift @groups;
      my $curve = $group->{curve};
      print {$fh} "<path d=\"\n" if $closed_path;
      printf {$fh} "   M %lf %lf\n", @{$curve->[0]{begin}};
      for my $segment (@$curve) {
         if ($segment->{type} eq 'bezier') {
            printf {$fh} "   C %lf %lf %lf %lf %lf %lf\n",
              @{$segment->{u}},
              @{$segment->{w}},
              @{$segment->{end}};
         } ## end if ($segment->{type} eq...
         else {
            printf {$fh} "   L %lf %lf\n", @{$segment->{corner}};
            printf {$fh} "   L %lf %lf\n", @{$segment->{end}};
         }
      } ## end for my $segment (@$curve)
      print {$fh} "   z\n";
      $closed_path = (!@groups) || ($groups[0]{sign} eq '+');
      print {$fh} "\" />" if $closed_path;
   } ## end while (@groups)

   print {$fh} "</g>\n";

   return $vector;
} ## end sub save_core

1;
__END__

=head1 DESCRIPTION

L<Graphics::Potrace::Vector::Exporte> derived class to provide export
facilities to Standard Vector Graphics.

=head1 INTERFACE

=head2 B<< save >>

Overrides L<Graphics::Potrace::Vector::Exporter/save> method to provide
something useful.
