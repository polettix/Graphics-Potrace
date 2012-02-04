package Graphics::Potrace::Raster::Packed;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );


sub new {
   my $package = shift;
   my $self = { ref $_[0] ? %{$_[0]} : @_ };
   return bless $self, $package;
}

sub load {
   my ($self, $bitmap) = shift;
   $bitmap->reset();
   $bitmap->real_bitmap($self->{'map'});
   $bitmap->dy($self->{dy});
   $bitmap->width($self->{width});
   $bitmap->height($self->{height});
   return $bitmap;
}

1;
__END__

