package Graphics::Potrace::Vector;

use strict;
use Carp;

sub new {
   my ($package, $self) = @_;
   return bless $self, $package;
}

sub save {
   my $self = shift;
   $self->create_saver(@_)->save($self);
   return $self;
} ## end sub save

sub create_saver {
   my ($self, $type, @parameters) = @_;
   my $package = __PACKAGE__ . '::' . ucfirst($type);
   (my $filename = $package) =~ s{::}{/}mxsg;
   $filename .= '.pm';
   require $filename;
   return $package->new(@parameters);
}

1;
__END__

