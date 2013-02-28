package CircosAPI;
use Moose;
use Moose::Util::TypeConstraints;
use lib::CircosAPI::CObject

has karyotype => (is => 'rw', isa => enum([ qw(hg18 hg19 mm9 mm8)] ), required => 1);

has ideogram => (is => 'rw', isa => 'Ideogram');
has image => (is => 'rw', isa => 'Image', builder => '_build_image');
has color => (is => 'rw', isa => 'Color');
has housekeeping => (is => 'rw', isa => 'Housekeeping');
has plots => (is => 'rw', isa => 'Array');
has highlights => (is => 'rw', isa => 'Array');

sub _build_image {
  my $self = shift;

  return Image->new();
}

sub init {
  my $self = shift;

  while (my $param = shift) {
    print $param
  }
}

sub define {
  my $self = shift;

  my $hash = shift;
  while ( my ( $k, $v ) = each %$hash ) {
    $self->{image}->$k($v) if $k ne "name";
  }
}


1;