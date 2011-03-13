#!/opt/perl/bin/perl 
use strict;
use warnings;
use English qw( -no_match_vars );
use Data::Dumper; $Data::Dumper::Indent = 1;

use lib qw( lib blib/lib blib/arch );
use Graphics::Potrace ();
use Graphics::Potrace::Bitmap ();

my $bitmap = Graphics::Potrace::Bitmap->new();
$bitmap->load(Ascii => text => <<'END_OF_FIGURE' );
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
.........XXXXXXXXXX     
  
......  
END_OF_FIGURE

#$bitmap->trim(100, 100);
#$bitmap->reverse();
$bitmap->trim();
#print {*STDERR} Dumper($bitmap);

for my $line (reverse @{$bitmap->{_bitmap}}) {
   my @line = map { sprintf '%032b', $_ } @$line;
   (my $out = join '', @line) =~ s/0/./mxsg;
   $out =~ s/1/X/mxsg;
   print {*STDERR} "$out\n";
}

my $vector = $bitmap->trace( turdsize => 0 );

my @groups = @{$vector->{list}};
print {*STDERR} "${\ scalar @groups} groups of segments\n";

$vector->save(Eps => file => 'prova.eps', height => $bitmap->height(), width => $bitmap->width());
