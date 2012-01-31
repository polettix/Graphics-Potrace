package Graphics::Potrace::Vector;

use strict;
use Carp;

use Moo;

has list => (
   is => 'rw',
   isa => sub { return ref($_[0]) eq 'ARRAY' },
   lazy => 1,
   predicate => 'has_list',
   default => sub { [] },
);

has tree => (
   is => 'rw',
   isa => sub { return ref($_[0]) eq 'ARRAY' },
   lazy => 1,
   predicate => 'has_tree',
   default => sub { [] },
);

has width => (
   is => 'rw',
   lazy => 1,
   predicate => 'has_width',
   default => sub { 1 },
);

has height => (
   is => 'rw',
   lazy => 1,
   predicate => 'has_height',
   default => sub { 1 },
);

sub export {
   my $self = shift;
   $self->create_exporter(@_)->save($self);
   return $self;
} ## end sub save

sub render {
   my $self = shift;
   return $self->create_exporter(@_)->render($self);
}

sub create_exporter {
   my ($self, $type, @parameters) = @_;
   my $package = __PACKAGE__ . '::' . ucfirst($type);
   (my $filename = $package) =~ s{::}{/}mxsg;
   $filename .= '.pm';
   require $filename;
   return $package->new(@parameters);
}

1;
__END__

