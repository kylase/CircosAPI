package CircosAPI;
use Moose;
use Moose::Util::TypeConstraints;
use JSON::PP;
use String::Util qw(trim);

use lib::CircosAPI::CObject;

extends 'CObject';

has base => (is => 'rw', isa => 'Base', init_arg => 'base');
has ideogram => (is => 'rw', isa => 'Ideogram', init_arg => 'ideogram', builder => '_build_default_ideogram');
has image => (is => 'rw', isa => 'Image', init_arg => 'image', builder => '_build_default_image');
has color => (is => 'rw', isa => 'Str', default => '<<include etc/colors_fonts_patterns.conf>>');
has housekeeping => (is => 'rw', isa => 'Str', default => '<<include etc/housekeeping.conf>>');
has plots => (is => 'rw', isa => 'ArrayRef');
has highlights => (is => 'rw', isa => 'ArrayRef');

sub read_defaults {
  open my $fh,  'lib/CircosAPI/default_pretty.json' or die $!;
  my $json = JSON::PP->new;
  my $stream = "";
  while (<$fh>) {
    chomp;
    $stream .= trim($_);
  } 
  return $json->decode($stream);
}

sub _build_default_image {
  my $defaults = read_defaults;
  return Image->new($defaults->{image});
}

sub _build_default_ideogram {
  my $defaults = read_defaults;
  return Ideogram->new($defaults->{ideogram});
}

sub addPlot {
  my $self = shift;
  push @{ $self->{plots} }, shift;
}

sub compile {
  my $self = shift;
  print $self->getAttributesAsString;
}
1;