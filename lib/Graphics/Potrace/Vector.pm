package Graphics::Potrace::Vector;

use strict;
use Carp;

sub new {
   my $package = shift;
   my $self = bless shift, $package;
   return $self;
}

sub _compute {
   my ($self) = @_;
   my @groups = @{$self->{list}};
   my ($minx, $maxx, $miny, $maxy);
   for my $group (@groups) {
      my $curve = $group->{curve};
      my ($first, @rest) = @$curve;
      ($minx, $miny) = ($maxx, $maxy) = @{$first->{begin}}
         unless defined $minx;
      for my $point ($first->{begin}, map { $_->{end} } ($first, @rest)) {
         my ($x, $y) = @$point;
         if ($x < $minx) { $minx = $x }
         elsif ($x > $maxx) { $maxx = $x }
         if ($y < $miny) { $miny = $y }
         elsif ($y > $maxy) { $maxy = $y }
      }
   }
   $self->{_x} = [$minx, $maxx];
   $self->{_y} = [$miny, $maxy];
   $self->{_width} = $maxx - $minx;
   $self->{_height} = $maxy - $miny;
   return $self;
}

sub width {
   my $self = shift;
   $self->{_width} = shift if @_;
   $self->_compute() unless exists $self->{_width};
   return $self->{_width};
}

sub height {
   my $self = shift;
   $self->{_height} = shift if @_;
   $self->_compute() unless exists $self->{_height};
   return $self->{_height};
}

sub save {
   my ($self, $type, @parameters) = @_;
   $self->create_saver(
      $type,
      width => $self->width(),
      height => $self->height(),
      @parameters,
   )->save($self);
   return $self;
} ## end sub save

sub create_saver {
   my ($self, $type, @parameters) = @_;
   my $package = __PACKAGE__ . '::' . ucfirst($type);
   (my $filename = $package) =~ s{::}{/}mxsg;
   $filename .= '.pm';
   require $filename;
   return $package->new(@parameters);
}

1;
__END__

