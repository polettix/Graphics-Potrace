package Graphics::Potrace;
use strict;
use warnings;
use English qw( -no_match_vars );
use Carp;

use Exporter qw( import );

use XSLoader;
our $VERSION;
$VERSION ||= '0.1.0';
XSLoader::load('Graphics::Potrace', $VERSION);

1;
__END__
