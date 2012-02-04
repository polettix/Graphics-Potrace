package Graphics::Potrace;

# ABSTRACT: bindings to the potrace library

use strict;
use warnings;
use English qw< -no_match_vars >;
use Scalar::Util qw< blessed >;
use Carp qw< croak >;
use Graphics::Potrace::Bitmap qw<>;
use Graphics::Potrace::Vectorial qw<>;

use Exporter qw( import );
{
   our @EXPORT_OK   = qw< bitmap bitmap2vector trace >;
   our @EXPORT      = ();
   our %EXPORT_TAGS = (all => \@EXPORT_OK);
}

use XSLoader;
our $VERSION;
$VERSION ||= '0.1.0';
XSLoader::load('Graphics::Potrace', $VERSION);

sub bitmap {
   return $_[0]    # return if already a bitmap... it might happen :)
     if @_
        && ref($_[0])
        && blessed($_[0])
        && $_[0]->isa('Graphics::Potrace::Bitmap');
   return Graphics::Potrace::Bitmap->new()->dwim_load(@_);
} ## end sub bitmap

sub bitmap2vector {
   my $bitmap = shift;
   my %args = (@_ && ref($_[0])) ? %{$_[0]} : @_;
   my %params;
   for
     my $field (qw< turdsize turnpolicy opticurve alphamax opttolerance >)
   {
      $params{$field} = $args{$field} if exists $args{$field};
   }
   return Graphics::Potrace::Vectorial->new(
      _trace(\%params, $bitmap->packed()));
} ## end sub bitmap2vector

sub trace {
   my %args = ref $_[0] ? %{$_[0]} : @_;

   croak "no bitmap provided" unless exists $args{bitmap};
   my $bitmap = bitmap($args{bitmap});

   my $vector = bitmap2vector($bitmap, %args);

   # Set bounds for saving to those provided by the bitmap
   $vector->width($bitmap->width());
   $vector->height($bitmap->height());

   # Save if so requested
   $vector->export(@{$args{vector}}) if exists $args{vector};

   # Return vector anyway
   return $vector;
} ## end sub trace

1;
__END__

=head1 SYNOPSIS

   # Step by step
   use Graphics::Potrace qw< bitmap >;
   my $bitmap = bitmap('
   ..........................
   .......XXXXXXXXXXXXXXX....
   ..XXXXXXXX.......XXXXXXX..
   ....XXXXX.........XXXXXX..
   ......XXXXXXXXXXXXXXX.....
   ...XXXXXX........XXXXXXX..
   ...XXXXXX........XXXXXXX..
   ....XXXXXXXXXXXXXXXXXX....
   ..........................
   ');
   my $vector = $bitmap->trace();
   $vector->export(Svg => file => 'example.svg');
   $vector->export(Svg => file => \my $svg_dump);
   $vector->export(Svg => fh   => \*STDOUT);
   my $eps = $vector->render('Eps');

   # All in one facility
   use Graphics::Potrace qw< trace >;
   trace(
      bitmap => '
      ..........................
      .......XXXXXXXXXXXXXXX....
      ..XXXXXXXX.......XXXXXXX..
      ....XXXXX.........XXXXXX..
      ......XXXXXXXXXXXXXXX.....
      ...XXXXXX........XXXXXXX..
      ...XXXXXX........XXXXXXX..
      ....XXXXXXXXXXXXXXXXXX....
      ..........................
      ',
      vector => [ Svg => file => 'example.svg' ],
   );

   # There is a whole lot of DWIMmery in both bitmap() and trace().
   # Stick to Graphics::Potrace::Bitmap for finer control
   use Graphics::Potrace::Bitmap;
   my $bitmap = Graphics::Potrace::Bitmap->load(
      Ascii => text => '
      ..........................
      .......XXXXXXXXXXXXXXX....
      ..XXXXXXXX.......XXXXXXX..
      ....XXXXX.........XXXXXX..
      ......XXXXXXXXXXXXXXX.....
      ...XXXXXX........XXXXXXX..
      ...XXXXXX........XXXXXXX..
      ....XXXXXXXXXXXXXXXXXX....
      ..........................
      ',
   );
   # you know what to do with $bitmap - see above!

=head1 DESCRIPTION

Potrace (L<http://potrace.sourceforge.net/>) is a program (and a library)
by Peter Salinger for I<Transforming bitmaps into vector graphics>. This
distribution aims at binding the library from Perl for your fun and
convenience.

=head1 INTERFACE

=head2 B<< bitmap >>

   my $bitmap = bitmap(@parameters);

Generate a L<Graphics::Potrace::Bitmap> object for further usage.

If the first parameter you provide is already such an object, it is
returned back. This lets you forget about what you actually have, and
it might be handy.

Otherwise, a new L<Graphics::Potrace::Bitmap> object is created, and
L<Graphics::Potrace::Bitmap/dwim_load> is called upon it passing the
provided parameters. This applies an heuristic to give you something
reasonable, see there for details.

=head2 B<< bitmap2vector >>

   my $vector = bitmap2vector($bitmap, %parameters);
   my $vector = bitmap2vector($bitmap, \%parameters);

Arguments:

=over

=item C<$bitmap>

a C<Graphics::Potrace::Bitmap> object, or anything that has a
C<packed()> method programmed to return the right hash ref.

=item C<%parameters>

=item C<$parameters>

parameters for tracing. This version of the bindings is aligned with
C<libpotrace> 1.10 and supports the following parameters:

=over

=item *

turdsize

=item *

turnpolicy

=item *

opticurve

=item *

alphamax

=item *

opttolerance

=back

See e.g. L<http://potrace.sourceforge.net/potracelib.pdf> for details.

=back

You should never actually need this function, because you can just as
well call:

   my $vector = $bitmap->trace(%parameters); # or with \%parameters

unless C<$bitmap> isn't actually a C<Graphics::Potrace::Bitmap> object
and you managed to duck a C<packed()> method in it.

=head2 B<< trace >>

   my $vector = trace(%parameters);
   my $vector = trace($parameters);

This is the most I<Do What I Mean> (a.k.a. DWIM) function of the whole
distribution. It tries to be as bloated as it can, but to provide you
a single interface for your one-off needs.

The following arguments can be provided either via C<%parameters> or
through an input hash ref:

=over

=item C<bitmap>

the bitmap to load. This parameter is used to call L</bitmap> above, see
there and L<Graphics::Potrace::Bitmap/dwim_load> for in-depth
documentation. And yes, if you I<already> have a
L<Graphics::Potrace::Bitmap> object you can pass it in.

This parameter is mandatory.

=item C<vector>

a description of what you want to do with the vector, e.g. export it
or get a representation. If present, this parameter is expected to be
an array reference containing parameters for
L<Graphics::Potrace::Vectorial/export>, see there for details.

This parameter is optional.

=item I<< all Potrace parameters supported by L</bitmap2trace> >>

these parameters will be passed over to C<bitmap2trace>, they are all
optional.

=back

Any other parameter will be ignored.

=head2 B<< version >>

This function returns the version of the Potrace library.

=head1 SEE ALSO

See L<http://potrace.sourceforge.net/> for Potrace - it's awesome!
