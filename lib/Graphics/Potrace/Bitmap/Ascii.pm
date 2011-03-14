package Graphics::Potrace::Bitmap::Ascii;

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );


sub new {
   my $package = shift;
   my $self = { ref $_[0] ? %{$_[0]} : @_ };
   $self->{empty_tester} ||= qr{[. 0]};
   return bless $self, $package;
}

sub _reset_io {
   my $self = shift;
   delete $self->{$_} for qw( fh file textref );
   return $self;
}

sub _accessor {
   my $self = shift;
   my $name = shift;
   if (@_) {
      $self->_reset_io();
      $self->{$name} = shift;
   }
   return $self->{$name};
}

sub file {
   my $self = shift;
   return $self->_accessor(file => @_);
}

sub text {
   my $self = shift;
   return $self->_accessor(text => @_);
}

sub empty_tester {
   my $self = shift;
   $self->{empty_tester} = shift if @_;
   return $self->{empty_tester};
}

sub fh {
   my $self = shift;
   $self->{fh} = shift if @_;
   return $self->{fh} if exists $self->{fh};
   if (exists $self->{file}) {
      open my $fh, '<', $self->{file}
        or croak "open('$self->{file}'): $OS_ERROR";
      return $fh;
   }
   if (exists $self->{text}) {
      open my $fh, '<', \$self->{text}
        or croak "open() on text: $OS_ERROR";
      return $fh;
   }
   croak("please provide either fh, file or textref");
} ## end sub _fh

sub overlay {
   my ($self, $bitmap) = @_;
   my $fh = $self->fh();
   my $empty = $self->empty_tester();

   my $j = 0;
   while (<$fh>) {
      chomp();
      my @line = split //;
      for my $i (0 .. $#line) {
         $bitmap->set($i, $j, ($line[$i] !~ m{$empty}));
      }
      ++$j;
   } ## end while (<$fh>)
   $bitmap->mirror_vertical();

   return $bitmap;
} ## end sub load

sub load {
   my $self = shift;
   $_[0]->reset();
   return $self->overlay(@_);
}

1;
__END__

