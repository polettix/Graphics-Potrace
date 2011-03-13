package Graphics::Potrace::Vector;

use strict;
use Carp;

sub new {
   my ($package, $self) = @_;
   return bless $self, $package;
}

sub save {
   my ($self, $type, @parameters) = @_;
   my $package = __PACKAGE__ . '::' . ucfirst($type);
   (my $filename = $package) =~ s{::}{/}mxsg;
   require $filename . '.pm';
   $package->can('save')->($self, @parameters);
   return $self;
} ## end sub save

1;
__END__

