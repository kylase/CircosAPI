package CObject;
{
  use Moose;
  use Moose::Util qw/find_meta get_all_attribute_values/;
  
  use namespace::autoclean;

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
}

package Image;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

# required fields
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
}

package Ideogram;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'show' => (is => 'rw', isa => enum([qw[ yes no ]]), default => "yes");
  has 'radius' => (is => 'rw', isa => 'Num', required => 1);
  has 'thickness' => (is => 'rw', isa => 'Num', required => 1);
  has 'fill' => (is => 'rw', isa => 'Str', required => 1);

  has 'stroke_color' => (is => 'rw', isa => 'Str');
  has 'stroke_thickness' => (is => 'rw', isa => 'Str');
  has 'spacing' => (is => 'rw', isa => 'Spacing');
  has 'break_style' => (is => 'rw', isa => 'BreakStyle');

}

package Plot;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'file' => (is => 'rw', isa => 'Str', required => 1);
  has 't' => (is => 'rw', isa => enum([qw[ scatter line histogram tile heatmap text connector ]]), required => 1);
  has 'r0' => (is => 'rw', isa => 'Str', required => 1);
  has 'r1' => (is => 'rw', isa => 'Str', required => 1);

  has 'min' => (is => 'rw', isa => 'Num');
  has 'max' => (is => 'rw', isa => 'Num');
  has 'orientation' => (is => 'rw', isa => enum([qw[ in out ]]));

  has 'background' => (is => 'rw', isa => enum([qw[ yes no ]]), default => "no");
  has 'background_color' => (is => 'rw', isa => 'Str');
  has 'background_stroke_color' => (is => 'rw', isa => 'Str');
  has 'background_stroke_thickness' => (is => 'rw', isa => 'Num');

  has 'axis' => (is => 'rw', isa => enum([qw[ yes no ]]), default => "no");
  has 'axis_color' => (is => 'rw', isa => 'Str');
  has 'axis_thickness' => (is => 'rw', isa => 'Num');
  has 'axis_spacing' => (is => 'rw', isa => 'Num');

  has 'min_value_change' => (is => 'rw', isa => 'Num');
  has 'skip_run' => (is => 'rw', isa => enum([qw[ yes no ]]), default => "no");
  has 'z' => (is => 'rw', isa => 'Num');

  has 'flow' => (is => 'rw', isa => enum([qw[ yes no ]]), default => "no");
  has 'rules' => (is => 'rw', isa => 'Array');
  has 'scale_log_base' => (is => 'rw', isa => enum([qw[ yes no ]]), default => "no");
}

1;