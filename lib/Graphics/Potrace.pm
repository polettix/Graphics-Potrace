package Graphics::Potrace;
use strict;
use warnings;
use English qw( -no_match_vars );
use Scalar::Util qw( blessed );
use Carp;
use Graphics::Potrace::Vector;

use Exporter qw( import );

use XSLoader;
our $VERSION;
$VERSION ||= '0.1.0';
XSLoader::load('Graphics::Potrace', $VERSION);

sub trace {
   my ($params, $bitmap) = @_;
   $bitmap = $bitmap->packed() if blessed($bitmap) && $bitmap->can('packed');
   return Graphics::Potrace::Vector->new(_trace($params, $bitmap));
}

1;
__END__
