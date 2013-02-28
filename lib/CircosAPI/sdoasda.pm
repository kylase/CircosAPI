package Image;
use Moose;
use Moose::Util qw/find_meta get_all_attribute_values/;
use Moose::Util::TypeConstraints;

use namespace::autoclean;

# Required fields
has 'dir' => (is => 'rw', isa => 'Str', required => 1, default => '.');
has 'file' => (is => 'rw', isa => 'Str', required => 1, default => 'circos.png');
has 'png' => (is => 'rw', isa => enum([qw[ yes no ]]), required => 1, default => "yes");
has 'svg' => (is => 'rw', isa => enum([qw[ yes no ]]), required => 1, default => "yes");
has 'radius' => (is => 'rw', isa => 'Str', required => 1, default => '1500p');
has 'angle_offset' => (is => 'rw', isa => 'Int', required => 1, default => -90);
has 'background' => (is => 'rw', isa => 'Str', required => 1, default => "white");

# Optional fields
has 'angle_orientation' => (is => 'rw', isa => enum([qw[ clockwise counterclockwise ]]), default => 'counterclockwise');
has 'auto_alpha_colors' => (is => 'rw', isa => enum([qw[ yes no ]]), default => 'yes');
has 'auto_alpha_steps' => (is => 'rw', isa => 'Int', default => 5);

sub getContentAsHashRef {
	my $self = shift;

	return get_all_attribute_values(find_meta($self), $self);
}

sub block {
  my $self = shift;

  my $hash = $self->getContentAsHashRef;
  my $meta = find_meta($self);
  my $class_name = lc($meta->{'package'});

  my $block_text = "";

  $block_text = $block_text . "<$class_name>\n";
  while ( my ($k, $v) = each %$hash ) {
    $block_text = $block_text . "$k = $v\n" if defined $v;
  }
  $block_text = $block_text . "</$class_name>\n";

  return $block_text
}

1;