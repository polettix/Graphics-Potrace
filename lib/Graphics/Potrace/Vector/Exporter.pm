package Graphics::Potrace::Vector::Exporter;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use Moo;

has _fh => (
   is => 'rw',
   lazy => 1,
   predicate => 'has_fh',
   clearer   => 'clear_fh',
   builder => 'initialise_fh',
   init_arg => 'fh',
);

sub fh {
   my $self = shift;
   if (@_) {
      $self->clear_file();
      $self->_fh(@_);
   }
   return $self->_fh();
}

has file => (
   is => 'rw',
   lazy => 1,
   predicate => 'has_file',
   clearer   => 'clear_file',
   default => sub { croak 'no file defined' },
   trigger => sub { $_[0]->clear_fh() },
);

sub initialise_fh {
   my $self = shift;
   croak 'neither fh nor file defined' unless $self->has_file();

   my $filename = $self->file();
   open my $fh, '>', $filename
      or croak "open('$filename'): $OS_ERROR";
   return $fh;
}

sub clear {
   my $self = shift;
   $self->clear_file();
   $self->clear_fh();
   return $self;
}

# Create a copy, by default by using the same parameters. This method
# allows overriding this operation.
sub clone {
   my ($self) = @_;
   return $self->new(%$self);
}

# Create loop!!! This leaves derived classes the choice to implement either
# render() or save() as they see fit
sub render {
   my ($self, $vector) = @_;
   my $worker = ($self->has_fh() || $self->has_file()) ? $self->clone() : $self;
   $worker->file(\my $textual);
   $worker->save($vector);
   $worker->clear();
   return $textual;
}

sub save {
   my ($self, $vector) = @_;
   my $fh = $self->fh();
   print {$fh} $self->render($vector);
   return $self;
}

sub boundaries {
   my $self = shift;
   my ($width, $height) = (0, 0);
   for my $item (@_) {
      my ($w, $h) = ($item->width(), $item->height());
      $width = $w if $width < $w;
      $height = $h if $height < $h;
   }
   return ($width, $height);
}

1;
__END__

