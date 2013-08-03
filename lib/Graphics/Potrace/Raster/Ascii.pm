package Graphics::Potrace::Raster::Ascii;

# ABSTRACT: importer of ASCII images for Graphics::Potrace

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Moo;

extends 'Graphics::Potrace::Raster::Importer';

has empty_tester => (
   is => 'rw',
   default => sub { qr{[. 0]} },
);

sub load_handle {
   my ($self, $fh) = @_;
   my $empty = $self->empty_tester();

   my $bitmap = $self->target();

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
}

1;
__END__

=encoding utf-8

=head1 SYNOPSIS

   use Graphics::Potrace::Raster;
   my $bitmap = Graphics::Potrace::Raster->new();
   $bitmap->load(Ascii => filename => '/path/to/ascii.txt');

=head1 DESCRIPTION

This class is an importer for L<Graphics::Potrace>. It derives from
L<Graphics::Potrace::Raster::Importer>, so see it for generic methods.
In particular, this class overrides L</load_handle> in order to
provide means to load a raster image from an ASCII file.

The ASCII file is considered to contain a matrix of
characters that will be treated as blanks (by default dots, spaces
and zeroes) or filled ones (any other character). You can set your
"idea" of what an empty pixel is by means of L</empty_tester> (which
you can set in the constructor as well).

=head1 INTERFACE

All the methods in L<Graphics::Potrace::Raster::Imported> are
supported. In addition, the following method is provided:

=head2 B<< empty_tester >>

Accessor to an internal variable for setting a regular expression to
be used to check whether a I<pixel> is empty or not. By default it
is the regular expression C<(?-imxs:[. 0])>.

=begin ignored

=head2 load_handle

=end ignored
