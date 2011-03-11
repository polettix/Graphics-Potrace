package Graphics::Potrace::Bitmap;
use strict;
use warnings;
use English qw( -no_match_vars );
use Carp;
use Config;

my ($INTSIZE, $N);

BEGIN {
   $INTSIZE = $Config{intsize};
   $N       = $INTSIZE * 8;
}

sub new {
   my $package = shift;
   my $self = bless {}, $package;
   $self->reset();
   return $self;
} ## end sub new

sub reset {
   my $self = shift;
   %$self = (
      _max_width => 0,
      _bitmap    => [],
   );
} ## end sub reset

sub _index_and_mask {
   my ($self, $x) = @_;
   $self->{_max_width} = $x + 1 if $self->{_max_width} < $x + 1;
   my @retval = (int($x / $N), (1 << ($N - 1 - ($x % $N))));
   return @retval;
} ## end sub _index_and_mask

sub get {
   my ($self, $x, $y) = @_;
   my ($i, $m) = $self->_index_and_mask($x);
   return ($self->{_bitmap}[$y][$i] ||= 0) & $m ? 1 : 0;
}

sub set {
   my ($self, $x, $y, $value) = @_;
   my ($i, $mask) = $self->_index_and_mask($x);
   my $rword = \($self->{_bitmap}[$y][$i] ||= 0);
   if (defined $value && !$value) {
      $$rword &= ~$mask;
   }
   else {
      $$rword |= $mask;
   }
   return $self;
} ## end sub set

sub unset {
   my ($self, $x, $y) = @_;
   return $self->set($x, $y, 0);
}

sub width {
   my $self = shift;
   if (@_) {
      $self->{_width} = shift;
   }
   return $self->{_width} if exists $self->{_width};
   return $self->{_max_width};
} ## end sub width

sub height {
   my $self = shift;
   if (@_) {
      $self->{_height} = shift;
   }
   return $self->{_height} if exists $self->{_height};
   return scalar(@{$self->{_bitmap}});
} ## end sub height

sub dy {
   my $self = shift;
   if (@_) {
      $self->{_dy} = shift;
   }
   return $self->{_dy} if exists $self->{_dy};
   my $width = $self->width();
   return int($width / $N) + (($width % $N) ? 1 : 0);
} ## end sub dy

sub bitmap {
   my $self   = shift;
   my @retval = @{$self->{_bitmap}};
   return @retval if wantarray();
   return \@retval;
} ## end sub bitmap

sub import_ascii {
   my ($self, $figure) = @_;
   $self->reset();
   $figure =~ s/\A\n+|\n+\z//gmsx;
   my @lines = split /\n/, $figure;
   for my $j (0 .. $#lines) {
      my @line = split //, $lines[$j];
      for my $i (0 .. $#line) {
         $self->set($i, $#lines - $j) unless $line[$i] eq ' ';
      }
   } ## end for my $j (0 .. $#lines)
   $self->trim();
   return $self;
} ## end sub import_ascii

sub trim {
   my ($self, $width, $height) = @_;
   $width  = $self->width(defined $width   ? $width  : $self->width());
   $height = $self->height(defined $height ? $height : $self->height());

   croak "width is not valid"  unless $width > 0;
   croak "height is not valid" unless $height > 0;
   croak "dy is not valid"     unless $self->dy();
   
   # adjust the bitmap, starting from the height
   my $bitmap = $self->{_bitmap};
   splice @$bitmap, $height if @$bitmap > $height;
   push @$bitmap, [] while @$bitmap < $height;

   # trim the width
   my ($n, $mask) = $self->_index_and_mask($width - 1);
   ++$n; # number of aggregates in each row
   my $supermask = 0;
   $mask >>= 1;
   while ($mask) {
      $supermask |= $mask;
      $mask >>= 1;
   }
   $supermask = ~$supermask;
   for my $row (@$bitmap) {
      $row ||= [];
      splice @$row, $n if @$row > $n;
      push @$row, (0) x ($n - @$row);
      $row->[-1] &= $supermask;
   }

   return;
} ## end sub trim

sub trace {
   my $self = shift;
   my $config = ref $_[0] ? $_[0] : {@_};
   $self->trim();
   my %bitmap = (
      width => $self->width(),
      height => $self->height(),
      dy => $self->dy(),
      map => scalar(pack 'I*', map { @$_ } $self->bitmap()),
   );
   my $retval = $self->_trace($config, \%bitmap);
   return $retval;
} ## end sub trace

1;
__END__
