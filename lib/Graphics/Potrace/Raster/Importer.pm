package Graphics::Potrace::Raster::Importer;

# ABSTRACT: vectorial exporter base class for Graphics::Potrace

use strict;
use warnings;
use Carp qw< croak >;
use English qw< -no_match_vars >;

use Moo;

sub import {
   my $self = shift;
   open my $fh, '<', \{$_[0]};
   return $self->load_handle($fh);
}

sub load_handle {
   my ($self, $fh) = @_;
   local $/;
   binmode $fh, ':raw';
   my $contents = <$fh>;
   return $self->import($contents);
}

sub load {
   my ($self, $f) = @_;
   return $self->import($$f) if ref($f) eq 'SCALAR';
   return $self->load_handle($f) if ref($f);
   open my $fh, '<:raw', $f or die "open('$f'): $OS_ERROR";
   return $self->load_handle($fh);
}

1;
__END__

=head1 DESCRIPTION

This is a base class for building up raster importers. One example
of using this base class is shipped directly in the distribution
as L<Graphics::Potrace::Raster::Ascii>.

You only need to override one of three methods: L</load_handle> or L</import>.

In this class these two methods are both defined in terms of the other,
so that you can really override only one of them and get the other one
for free.

=head1 INTERFACE

=head2 B<< import >>

   my $bitmap = $importer->import($scalar);

Import data from a scalar variable. The format the data inside the
C<$scalar> depends on the particular derived class.

=head2 B<< load >>

   my $bitmap = $importer->load($scalar_ref);
   my $bitmap = $importer->load($filename);
   my $bitmap = $importer->load($filehandle);

Import data from a scalar, a file or a filehandle. The format of the data
in the file/filehandle depends on the derived class. This method
leverages upon B</import> and L</load_handle>. In this way you can use
one single method and decide what you want to pass in exactly.

=head2 B<< load_handle >>

   my $bitmap = $importer->load_handle($filehandle);

Import data from a filehandle. This functionality is already covered
by L</load> above, but this method is more useful for overriding in
derived classes.

=head2 B<< new >>

   my $i = Graphics::Potrace::Raster::Importer->new(%args);

Constructor. There is no common parameter to be shared with derived
classes, so this method might accept parameters only depending on
the particular class.
