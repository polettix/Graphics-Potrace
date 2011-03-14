package Graphics::Potrace::Vector::Svg;

use strict;
use Carp;
use English qw( -no_match_vars );

sub new {
   my $package = shift;
   my $self = { ref $_[0] ? %{$_[0]} : @_ };
   return bless $self, $package;
}

sub _reset_io {
   my $self = shift;
   delete $self->{$_} for qw( fh file textref );
   return $self;
}

sub _accessor {
   my $self = shift;
   my $name = shift;
   if (@_) {
      $self->_reset_io();
      $self->{$name} = shift;
   }
   return $self->{$name};
}

sub file {
   my $self = shift;
   return $self->_accessor(file => @_);
}

sub textref {
   my $self = shift;
   return $self->_accessor(textref => @_);
}

sub fh {
   my $self = shift;
   $self->{fh} = shift if @_;
   return $self->{fh} if exists $self->{fh};
   if (exists $self->{file}) {
      open my $fh, '>', $self->{file}
        or croak "open('$self->{file}'): $OS_ERROR";
      return $fh;
   }
   if (exists $self->{textref}) {
      open my $fh, '>', $self->{textref}
        or croak "open() on text: $OS_ERROR";
      return $fh;
   }
   croak("please provide either fh, file or textref");
} ## end sub _fh

sub save {
   my $self = shift;
   my $fh = $self->fh();

   # Header
   my $header_template = <<'END_OF_HEADER';
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg width="%d" height="%d" version="1.1" xmlns="http://www.w3.org/2000/svg">
END_OF_HEADER
   printf {$fh} $header_template, $self->{width}, $self->{height};

   # Every vector
   $self->_save_core($fh, $_) for @_;

   # Footer
   print {$fh} "</svg>\n";

   return;
} ## end sub save

sub _save_core {
   my ($self, $fh, $vector) = @_;

   printf {$fh} "<g style=\"fill:%s;stroke:none\" transform=\"matrix(1, 0, 0, -1, 0, %d)\">\n",
      $vector->{color} || 'black', $self->{height};
#   printf {$fh} "<g style=\"fill:%s;stroke:none\">\n",
#      $vector->{color} || 'black';

   my @groups      = @{$vector->{list}};
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
