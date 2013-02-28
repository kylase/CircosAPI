package CObject;
{
  use Moose;
  use Moose::Util qw/find_meta get_all_attribute_values/;
  
  use namespace::autoclean;

  sub getContentAsHashRef {
    my $self = shift;

    return get_all_attribute_values(find_meta($self), $self );
  }

  sub getAttributesAsString {
    my $self = shift;
    my $hash = $self->getContentAsHashRef;

    my $string = "";

    while ( my ($k, $v) = each %$hash ) {
      $string = $string . "$k = $v\n" if defined $v and ref $v ne 'ArrayRef';
    }

    return $string; 
  }

  sub getAttributesAsBlock {
    my $self = shift;

    my $hash = $self->getContentAsHashRef;
    my $meta = find_meta( $self );
    my $class_name = lc( $meta->{'package'} );

    my $string = "";

    $string = $string . "<$class_name>\n" if $class_name ne "base";
    $string = $string . $self->getAttributesAsString;
    $string = $string . "</$class_name>\n" if $class_name ne "base";

    return $string; 
  }
}

package DataTrack;
{
  use Moose;
  extends 'CObject';
  
  has 'file' => ( is => 'rw', isa => 'Str', init_arg => '-file', required => 1 );
  has 'rules' => ( is  => 'rw', isa => 'ArrayRef' );

  sub addRule {
    my $self = shift;
    my $rule = shift;

    $self->{rules}->push($rule);
  }
}

# SUBCLASSES

package Base;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'karyotype' => ( is => 'rw', isa => 'Str', 
                      initializer => sub {
                        my ($self, $value, $set, $attr) = @_;
                        if ($value eq 'hg19') {
                          $set->('data/karyotype/karyotype.human.txt');
                        }
                      }, 
                      init_arg => '-karyotype');
  has 'chromosome_units' => ( is => 'rw', isa => 'Int', init_arg => '-units', default => 1000000 );
  has 'chromosomes' => ( is => 'rw', isa => 'Str', init_arg => '-chromosomes');
  has 'chromosomes_display_default' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => 'yes' );
}

package Image;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  # required fields
  has 'dir' => ( is => 'rw', isa => 'Str', required => 1, default => '.' );
  has 'file' => ( is => 'rw', isa => 'Str', required => 1, default => 'circos.png' );
  has 'png' => ( is => 'rw', isa => enum([qw[ yes no ]]), required => 1, default => "yes" );
  has 'svg' => ( is => 'rw', isa => enum([qw[ yes no ]]), required => 1, default => "yes" );
  has 'radius' => ( is => 'rw', isa => 'Str', required => 1, init_arg => '-radius', default => '1500p' );
  has 'angle_offset' => ( is => 'rw', isa => 'Int', required => 1, default => -90 );
  has 'background' => ( is => 'rw', isa => 'Str', required => 1, default => "white" );

  # Optional fields
  has 'angle_orientation' => ( is => 'rw', isa => enum([qw[ clockwise counterclockwise ]]), default => 'counterclockwise' );
  has 'auto_alpha_colors' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => 'yes' );
  has 'auto_alpha_steps' => ( is => 'rw', isa => 'Int', default => 5 );
}

package Ideogram;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  # required fields
  has 'show' => ( is => 'rw', isa => enum([qw[ yes no ]]), init_arg => '-show', default => "yes" );
  has 'radius' => ( is => 'rw', isa => 'Str', init_arg => '-radius', required => 1 );
  has 'thickness' => ( is => 'rw', isa => 'Str', init_arg => '-thickness', required => 1 );
  has 'fill' => ( is => 'rw', isa => 'Str', init_arg => '-fill', required => 1, default => "yes" );

  has 'stroke_color' => ( is => 'rw', isa => 'Str' );
  has 'stroke_thickness' => ( is => 'rw', isa => 'Str' );
  
  # Cytogenetic Bands
  has 'show_bands' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
  has 'fill_bands' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
  has 'band_transparency' => ( is => 'rw', isa => 'Int' );
  has 'band_stroke_thickness' => ( is => 'rw', isa => 'Str');
  has 'band_stroke_color' => ( is => 'rw', isa => 'Str');

  # Ideogram Label
  has 'show_label' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
  has 'label_radius' => ( is => 'rw', isa => 'Str');
  has 'label_size' => ( is => 'rw', isa => 'Int');
  has 'label_font' => ( is => 'rw', isa => enum([qw[ default bold condensed ]]), default => "default" );
  has 'label_parallel' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
  has 'label_with_tag' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
  has 'label_case' => ( is => 'rw', isa => enum([qw[ upper lower ]]) );
  has 'label_format' => ( is => 'rw', isa => 'Str' ); 

  # Axis breaks
  has 'axis_break' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
  has 'axis_break_style' => ( is => 'rw', isa => enum([qw[ 1 2 ]]));
  has 'axis_break_at_edge' => ( is => 'rw', isa => enum([qw[ yes no ]]) );

  has 'spacing' => ( is => 'rw', isa => 'Spacing', init_arg => '-spacing' );
  has 'break_style' => ( is => 'rw', isa => 'ArrayRef', init_arg => '-break_style' );

  sub getBreakStyleBlocks {
    my $self = shift;
    my $a = $self->{break_style};
    my $count = 1;
    foreach (@$a) {
      print "<break_style $count>";
      print $_->getAttributesAsString;
      print "</break_style>";
      $count++;
    }
  }
}

package Pairwise;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'pair1' => ( is => 'rw', isa => 'Str' );
  has 'pair2' => ( is => 'rw', isa => 'Str' );
  has 'spacing' => ( is => 'rw', isa => 'Str');

}

package Spacing;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'pairwises' => ( is => 'rw', isa => 'ArrayRef' );
  has 'default' => ( is => 'rw', isa => 'Str' );
  has 'break' => ( is => 'rw', isa => 'Str' );

  sub getPairwiseBlocks {
    my $self = shift;
    my $a = $self->{pairwises};

    foreach (@$a) {
      print "<pairwise $_->{pair1} $_->{pair2}>\n";
      print $_->getAttributesAsString;
      print "</pairwise>\n";
    }
  }
}

package BreakStyle;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'stroke_color' => ( is => 'rw', isa => 'Str', init_arg => '-stroke_color' );
  has 'stroke_thickness' => ( is => 'rw', isa => 'Str', init_arg => '-stroke_thickness' );
  has 'thickness' => ( is => 'rw', isa => 'Str', init_arg => '-thickness' ); 
  has 'fill_color'=> ( is => 'rw', isa => 'Str', init_arg => '-fill_color'); 
}

package Plot;
{
  use Moose;
  extends 'DataTrack';

  use Moose::Util::TypeConstraints;

# required fields
  has 't' => ( is => 'rw', isa => enum([qw[ scatter line histogram tile heatmap text connector ]]), required => 1 );
  has 'r0' => ( is => 'rw', isa => 'Str', required => 1 );
  has 'r1' => ( is => 'rw', isa => 'Str', required => 1 );

# optional fields
  has 'min' => ( is => 'rw', isa => 'Num' );
  has 'max' => ( is => 'rw', isa => 'Num' );
  has 'orientation' => ( is => 'rw', isa => enum([qw[ in out ]]) );

  has 'background' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => "no" );
  has 'background_color' => ( is => 'rw', isa => 'Str' );
  has 'background_stroke_color' => ( is => 'rw', isa => 'Str' );
  has 'background_stroke_thickness' => ( is => 'rw', isa => 'Num' );

  has 'axis' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => "no" );
  has 'axis_color' => ( is => 'rw', isa => 'Str' );
  has 'axis_thickness' => ( is => 'rw', isa => 'Num' );
  has 'axis_spacing' => ( is => 'rw', isa => 'Num' );

  has 'min_value_change' => ( is => 'rw', isa => 'Num' );
  has 'skip_run' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => "no" );
  has 'z' => ( is => 'rw', isa => 'Num' );

  has 'flow' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => "no" );
  has 'scale_log_base' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => "no" );
}

package Highlight;
{
  use Moose;
  extends 'DataTrack';

  use Moose::Util::TypeConstraints;

# required fields
  has 'r0' => ( is => 'rw', isa => 'Str', init_arg => '-r0', required => 1 );
  has 'r1' => ( is => 'rw', isa => 'Str', init_arg => '-r1', required => 1 );

# optional fields
  has 'z' => ( is => 'rw', isa => 'Num' );
  has 'stroke_color' => ( is => 'rw', isa => 'Str' );
  has 'stroke_thickness' => ( is => 'rw', isa => 'Str' );
  has 'fill_color' => ( is => 'rw', isa => 'Str');

  has 'rules' => ( is => 'rw', isa => 'ArrayRef' );
}

package Link;
{
  use Moose;
  extends 'DataTrack';

  use Moose::Util::TypeConstraints;

# required fields
  has 'radius' => ( is => 'rw', isa => enum([qw[ scatter line histogram tile heatmap text connector ]])
                  , required => 1 );

# optional fields
  has 'record_limit' => ( is => 'rw', isa => 'Int', default => 1000);
  has 'color' => ( is => 'rw', isa => 'Str' );
  has 'thickness' => ( is => 'rw', isa => 'Num' );
  has 'bezier_radius' => ( is => 'rw', isa => 'Num' );
  has 'bezier_radius_purity' => ( is => 'rw', isa => 'Num' );
  has 'ribbon' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => "no" );
  has 'stroke_color' => ( is => 'rw', isa => 'Str' );
  has 'stroke_thickness' => ( is => 'rw', isa => 'Str' );
  has 'twist' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
  has 'flat' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
  has 'crest' => ( is => 'rw', isa => enum([qw[ yes no ]]) );
}

package Rule;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  # required fields
  has 'importance' => ( is => 'rw', isa => 'Int', required => 1 );
  has 'condition' => ( is => 'rw', isa => 'Str', required => 1 );
  has 'params' => ( is => 'rw', isa => 'HashRef', required => 1 );

  sub getRule {
    my $self = shift;
    my $hash = $self->{params};
    my $string = "";

    while ( my ( $k, $v ) = each %$hash ) {
      $string = $string . "$k = $v\n";
    }

    return $string;
  }
}

1;