#!/opt/perl/bin/perl 
use strict;
use warnings;
use English qw( -no_match_vars );
use Data::Dumper; $Data::Dumper::Indent = 1;

use lib qw( lib blib/lib blib/arch );
use Graphics::Potrace ();
use Graphics::Potrace::Bitmap ();

my $bitmap = Graphics::Potrace::Bitmap->new();
$bitmap->import_ascii( <<'END_OF_FIGURE' );
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXX                         XXXXXXXXXXX
XXXX                              XXXXXXXXX
XX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XX                   XXXXXXXXXXXXXXXXXXXXXX
XXXX                   XXXXXXXXXXXXXXXXXXXX
XXXXXXXX                        XXXXXXXXXXX
XXXXXXXXXXXXXX                    XXXXXXXXX
XXXXXXXXXXXXXXXXXX                  XXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     XXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXX      XXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXX          XXXXXXXXX
XXXXX                           XXXXXXXXXXX
XXXXXX                        XXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
             XXXXXXXX                      

                XXXXXXXXXXXXXXXXXXXXXXXXXX   
            XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
           XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx 
          XXXXXXXXX
         XXXXXXXXX
         XXXXXXXXXX
         XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  
         XXXXXXXXXXxxxxxxxxxxxxxxxxxxxxxxx 
         XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
         XXXXXXXXXX     
         XXXXXXXXXX     
         XXXXXXXXXX     
         XXXXXXXXXX     
         XXXXXXXXXX     
         XXXXXXXXXX     
END_OF_FIGURE

$bitmap->trim(100, 100);
print {*STDERR} Dumper($bitmap);

for my $line (reverse @{$bitmap->{_bitmap}}) {
   my @line = map { sprintf '%032b', $_ } @$line;
   (my $out = join '', @line) =~ s/0/./mxsg;
   $out =~ s/1/X/mxsg;
   print {*STDERR} "$out\n";
}

print {*STDERR} Dumper($bitmap);

my $vector = $bitmap->trace( turdsize => 0 );
print {*STDERR} Dumper($vector);

my @groups = @{$vector->{list}};
print {*STDERR} "${\ scalar @groups} groups of segments\n";

print "%!PS-Adobe-3.0 EPSF-3.0\n";
printf "%%%%BoundingBox: 0 0 %d %d\n", $bitmap->width(), $bitmap->height();
while (@groups) {
   my $group = shift @groups;
   my $curve = $group->{curve};
   printf "%lf %lf moveto\n", @{$curve->[0]{begin}};
   for my $segment (@$curve) {
      if ($segment->{type} eq 'bezier') {
         printf "%lf %lf %lf %lf %lf %lf curveto\n",
            @{$segment->{u}},
            @{$segment->{w}},
            @{$segment->{end}};
      }
      else {
         printf "%lf %lf lineto\n", @{$segment->{corner}};
         printf "%lf %lf lineto\n", @{$segment->{end}};
      }
   }
   print "0 setgray fill\n"
      if (!@groups) || ($groups[0]{sign} eq '+');
}
print "gsave\n";
print "grestore\n%EOF\n";
