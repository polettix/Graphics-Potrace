NAME
====

Graphics::Potrace - bindings to the potrace library

SYNOPSIS
========

    # Step by step
    use Graphics::Potrace qw< raster >;
    my $raster = raster('
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
    my $vector = $raster->trace();
    $vector->export(Svg => file => 'example.svg');
    $vector->export(Svg => file => \my $svg_dump);
    $vector->export(Svg => fh   => \*STDOUT);
    my $eps = $vector->render('Eps');
 
    # All in one facility
    use Graphics::Potrace qw< trace >;
    trace(
       raster => '
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
       vectorial => [ Svg => file => 'example.svg' ],
    );
 
    # There is a whole lot of DWIMmery in both raster() and trace().
    # Stick to Graphics::Potrace::Raster for finer control
    use Graphics::Potrace::Raster;
    my $raster = Graphics::Potrace::Raster->load(
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
    # you know what to do with $raster - see above!

DESCRIPTION
===========

[Potrace](http://potrace.sourceforge.net/) is a program (and a library)
by Peter Salinger for *Transforming bitmaps into vector graphics*, distributed
under the GNU GPL. This distribution aims at binding the library from Perl for
your fun and convenience.

ALL THE REST
============

Want to know more? [See the module's documentation](http://metacpan.org/release/Graphics-Potrace) to figure out
all the bells and whistles of this module!

Want to contribute? [Fork it on GitHub](https://github.com/polettix/Graphics-Potrace) or at least
[read the relevant page](http://polettix.github.com/Graphics-Potrace).

That's all folks!

