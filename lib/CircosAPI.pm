package CircosAPI;
use Moose;
use Moose::Util::TypeConstraints;
use JSON::PP;
use String::Util qw(trim);

use lib::CircosAPI::CObject;

extends 'CObject';

has base => ( is => 'rw', isa => 'Base', init_arg => 'base');
has ideogram => ( is => 'rw', isa => 'Ideogram', init_arg => 'ideogram', builder => '_build_default_ideogram');
has image => ( is => 'rw', isa => 'Image', init_arg => 'image', builder => '_build_default_image');
has ticks => ( is => 'rw', isa => 'Ticks', init_arg => 'ticks');
has plots => ( is => 'rw', isa => 'ArrayRef', init_arg => 'plots');
has highlights => ( is => 'rw', isa => 'ArrayRef', init_arg => 'highlights');
has links => ( is => 'rw', isa => 'ArrayRef', init_arg => 'links');
has colors => ( is => 'rw', isa => 'HashRef', init_arg => 'colors');

sub read_defaults {
  open my $fh,  'defaults/default_pretty.json' or die $!;
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
  my $i = Ideogram->new($defaults->{ideogram});
  $i->{spacing} = Spacing->new($defaults->{spacing});
  return $i;
}

sub addHighlight {
  my $self = shift;
  $self->addTrack('highlights', @_);
}

sub addLink {
  my $self = shift;
  $self->addTrack('links', @_);
}

sub addPlot {
  my $self = shift;
  $self->addTrack('plots', @_);
}

sub addTrack {
  my $self = shift;
  my $trackType = shift;
  push @{ $self->{$trackType} }, @_;
}

sub compile {
  my $self = shift;
  return $self->getAttributesAsString;
}

sub compileAsConf {
  my $self = shift;
  my $filename = shift;
  
}
1;