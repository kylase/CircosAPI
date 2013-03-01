package CircosAPI;
use Moose;
use Moose::Util::TypeConstraints;

use lib::CircosAPI::CObject;

extends 'CObject';

has base => (is => 'rw', isa => 'Base', init_arg => '-base');
has ideogram => (is => 'rw', isa => 'Ideogram', init_arg => '-ideogram');
has image => (is => 'rw', isa => 'Image', init_arg => '-image');
has color => (is => 'rw', isa => 'Str', default => '<<include etc/colors_fonts_pattern.conf>>');
has housekeeping => (is => 'rw', isa => 'Str', default => '<<include etc/housekeeping.conf>>');
has plots => (is => 'rw', isa => 'ArrayRef');
has highlights => (is => 'rw', isa => 'ArrayRef');

sub define {
  my $self = shift;

  my $hash = shift;
  while ( my ( $k, $v ) = each %$hash ) {
    $self->{image}->$k($v) if $k ne "name";
  }
}

sub getConfig {
  my $self = shift;

  my @attributes = $self->meta->get_attribute_list;

  foreach ( @attributes ) {
    print $self->{$_}->getAttributesAsBlock ;
  }
}
1;