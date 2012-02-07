package Graphics::Potrace::Raster::Packed;

# ABSTRACT: importer of packed rasters for Graphics::Potrace

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Moo;

extends 'Graphics::Potrace::Raster::Importer';

sub load_data {
   my ($self, $reference) = shift;
   my $bitmap = $self->target();
   $bitmap->reset();
   $bitmap->real_bitmap($reference->{'map'});
   $bitmap->dy($reference->{dy});
   $bitmap->width($reference->{width});
   $bitmap->height($reference->{height});
   return $bitmap;
}

sub load_handle {
   croak __PACKAGE__ . ' does not support load_handle';
}

1;
__END__

=head1 DESCRIPTION

This class is an importer for L<Graphics::Potrace>. It derives from
L<Graphics::Potrace::Raster::Importer>, so see it for generic methods.
In particular, this class overrides L</load_handle> in order to
provide means to load a raster image from a packed version of some
other raster image (see L<Graphics::Potrace::Raster/packed>).

=head1 INTERFACE

Only method L<Graphics::Potrace::Raster::Imported/load_data> is
supported (and C<load> whereas it calls C<load_data>). Attempts to
call L<Graphics::Potrace::Raster::Imported/load_handle> will fail.

=begin ignored

=head2 load_data

=head2 load_handle

=end ignored
