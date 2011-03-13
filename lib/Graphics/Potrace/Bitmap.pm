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

sub _index_and_mask {
   my ($self, $x) = @_;
   $self->{_max_width} = $x + 1 if $self->{_max_width} < $x + 1;
   my @retval = (int($x / $N), (1 << ($N - 1 - ($x % $N))));
   return @retval;
} ## end sub _index_and_mask

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

sub width {
   my $self = shift;
   $self->{_width} = shift if @_;
   return $self->{_width} if exists $self->{_width};
   return $self->{_max_width};
} ## end sub width

sub height {
   my $self = shift;
   $self->{_height} = shift if @_;
   return $self->{_height} if exists $self->{_height};
   return scalar(@{$self->{_bitmap}});
} ## end sub height

sub dy {
   my $self = shift;
   $self->{_dy} = shift if @_;
   return $self->{_dy} if exists $self->{_dy};
   my $width = $self->width();
   return int($width / $N) + (($width % $N) ? 1 : 0);
} ## end sub dy

sub real_bitmap {
   my $self = shift;
   $self->{_bitmap} = shift if @_;
   return $self->{_bitmap};
}

sub mirror_vertical {
   my $self = shift;
   $self->{_bitmap} = [ reverse @{ $self->{_bitmap} } ];
   return $self;
}

sub bitmap {
   my ($self, $width, $height) = @_;
   $width ||= $self->width();
   $height ||= $self->height();

   my @bitmap = map { [ @{ $_ ? $_ : [] } ]} @{$self->{_bitmap}};;

   # adjust the bitmap, starting from the height
   splice @bitmap, $height if @bitmap > $height;
   push @bitmap, [] while @bitmap < $height;

   # trim the width
   my ($n, $mask) = $self->_index_and_mask($width - 1);
   ++$n;    # number of aggregates in each row
   my $supermask = 0;
   $mask >>= 1;
   while ($mask) {
      $supermask |= $mask;
      $mask >>= 1;
   }
   $supermask = ~$supermask;
   for my $row (@bitmap) {
      $row ||= [];
      splice @$row, $n if @$row > $n;
      push @$row, (0) x ($n - @$row);
      $row->[-1] &= $supermask;
   } ## end for my $row (@$bitmap)

   return @bitmap if wantarray();
   return \@bitmap;
}

sub packed_bitmap {
   my $self = shift;
   return scalar pack 'I*', map { @$_ } $self->bitmap(@_);
}

sub packed {
   my $self   = shift;
   my %bitmap = (
      width  => $self->width(),
      height => $self->height(),
      dy     => $self->dy(),
      map    => $self->packed_bitmap(),
   );
   return \%bitmap;
} ## end sub pack

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

sub clear {
   my $self = shift;

   my $width  = $self->width();
   my ($n, $mask) = $self->_index_and_mask($width - 1);
   my @line_template = (0) x ($n + 1);

   my $height = $self->height();
   $self->{_bitmap} = [ map { [ @line_template ] } 1 .. $height ];

   return $self;
}

sub reverse {
   my $self = shift;

   my $width  = $self->width();
   my ($n, $mask) = $self->_index_and_mask($width - 1);
   my $supermask = 0;
   $mask >>= 1;
   while ($mask) {
      $supermask |= $mask;
      $mask >>= 1;
   }
   $supermask = ~$supermask;

   my $height = $self->height();
   my @bitmap = $self->bitmap();
   for my $row (@bitmap) {
      $_ = ~$_ for @$row;
      $row->[-1] &= $supermask;
   }
   $self->{_bitmap} = \@bitmap;

   return $self;
}

sub load {
   my ($self, $type, @parameters) = @_;
   my $package = __PACKAGE__ . '::' . ucfirst($type);
   (my $filename = $package) =~ s{::}{/}mxsg;
   require $filename . '.pm';
   $package->can('load')->($self, @parameters);
   return $self;
}

sub import_ascii {
   my ($self, $figure) = @_;
   $self->reset();
   $figure =~ s/\A\n+|\n+\z//gmsx;
   my @lines = split /\n/, $figure;
   for my $j (0 .. $#lines) {
      my @line = split //, $lines[$j];
      for my $i (0 .. $#line) {
         $self->set($i, $#lines - $j, ($line[$i] ne ' '));
      }
   } ## end for my $j (0 .. $#lines)
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
   ++$n;    # number of aggregates in each row
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
   } ## end for my $row (@$bitmap)

   return;
} ## end sub trim

sub trace {
   my $self = shift;
   my $config = ref $_[0] ? $_[0] : {@_};
   require Graphics::Potrace;
   return Graphics::Potrace::trace($config, $self);
} ## end sub trace

1;
__END__
