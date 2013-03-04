package CObject;
{
  use Moose;
  use Moose::Util qw/find_meta get_all_attribute_values/;
  use List::Util qw(min);
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
      if ( ref $v eq 'ARRAY' ) {
        foreach (@$v) {
          $string .= $_->getAttributesAsBlock;
        }
      } else {
        if ( ref $v eq "" ) {
          if ($k eq "color" or $k eq "housekeeping") {
            # For color and housekeeping blocks
              $string .= "$v\n" ;
            } else {
              $string .= lc $k . " = $v\n" if ( defined($v) && min(map { $_ eq $k ? 0 : 1 } qw[id pair1 pair2]) );
            }
        } else {
          $string .= $v->getAttributesAsBlock;
        }     
      }
    }

    return $string; 
  }

  sub getAttributesAsBlock {
    my $self = shift;

    my $hash = $self->getContentAsHashRef;
    my $meta = find_meta( $self );
    my $class_name = lc( $meta->{'package'} );

    my $string = "";

    if ($class_name eq 'pairwise') {
      $string .= "<$class_name $self->{pair1},$self->{pair2}" if defined $self->{pair2};
      $string .= "<$class_name $self->{pair1}" if !(defined $self->{pair2});
    } elsif ( $class_name eq 'breakstyle' ) {
      $string .= "\n<$class_name $self->{id}>\n" if $class_name ne "base";
    } else {
      $string .= "\n<$class_name>\n" if $class_name ne "base";
    }

    $string .= $self->getAttributesAsString;
    $string .= "</$class_name>\n" if $class_name ne "base";

    return $string; 
  }
}

package DataTrack;
{
  use Moose;
  extends 'CObject';
  
  has 'file' => ( is => 'rw', isa => 'Str', init_arg => 'file', required => 1 );
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
  use JSON::PP;
  use String::Util qw(trim);

  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'karyotype' => ( is => 'rw', isa => 'Str', init_arg => 'karyotype', initializer => sub {
                        my ($self, $value, $set, $attr) = @_;
                        open my $fh,  'lib/CircosAPI/karyotypes.json' or die $!;
                        my $json = JSON::PP->new;
                        my $stream = "";
                        while (<$fh>) {
                          chomp;
                          $stream .= trim($_);
                        } 
                        my $karyotypes = $json->decode($stream);
                        $set->($karyotypes->{$value});
                      } );
  has 'chromosome_units' => ( is => 'rw', isa => 'Int', init_arg => 'units', default => 1000000 );
  has 'chromosomes' => ( is => 'rw', isa => 'Str', init_arg => 'chromosomes');
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
  has 'radius' => ( is => 'rw', isa => 'Str', required => 1, init_arg => 'radius', default => '1500p' );
  has 'angle_offset' => ( is => 'rw', isa => 'Int', required => 1, default => -90 );
  has 'background' => ( is => 'rw', isa => 'Str', required => 1, default => "white" );

  # Optional fields
  has 'angle_orientation' => ( is => 'rw', isa => enum([qw[ clockwise counterclockwise ]]) );
  has 'auto_alpha_colors' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => 'yes' );
  has 'auto_alpha_steps' => ( is => 'rw', isa => 'Int', default => 5 );
}

package Ideogram;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  # required fields
  has 'show' => ( is => 'rw', isa => enum([qw[ yes no ]]), init_arg => 'show', default => "yes" );
  has 'radius' => ( is => 'rw', isa => 'Str', init_arg => 'radius', required => 1 );
  has 'thickness' => ( is => 'rw', isa => 'Str', init_arg => 'thickness', required => 1 );
  has 'fill' => ( is => 'rw', isa => 'Str', init_arg => 'fill', required => 1, default => "yes" );

  has 'stroke_color' => ( is => 'rw', isa => 'Str', init_arg => 'stroke_color' );
  has 'stroke_thickness' => ( is => 'rw', isa => 'Str', init_arg => 'stroke_thickness' );
  
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

  has 'spacing' => ( is => 'rw', isa => 'Spacing', init_arg => 'spacing' );
  has 'break_style' => ( is => 'rw', isa => 'ArrayRef', init_arg => 'break_style' );
}

package Pairwise;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'pair1' => ( is => 'rw', isa => 'Str', init_arg => 'pair1' );
  has 'pair2' => ( is => 'rw', isa => 'Str', init_arg => 'pair2' );
  has 'spacing' => ( is => 'rw', isa => 'Str', init_arg => 'spacing');

}

package Spacing;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'pairwises' => ( is => 'rw', isa => 'ArrayRef' );
  has 'default' => ( is => 'rw', isa => 'Str', init_arg => 'default' );
  has 'break' => ( is => 'rw', isa => 'Str', init_arg => 'break' );
}

package BreakStyle;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'id' => ( is => 'rw', isa => 'Int', init_arg => 'id', required => 1 );
  has 'stroke_color' => ( is => 'rw', isa => 'Str', init_arg => 'stroke_color' );
  has 'stroke_thickness' => ( is => 'rw', isa => 'Str', init_arg => 'stroke_thickness' );
  has 'thickness' => ( is => 'rw', isa => 'Str', init_arg => 'thickness' ); 
  has 'fill_color'=> ( is => 'rw', isa => 'Str', init_arg => 'fill_color'); 
}

package Plot;
{
  use Moose;
  extends 'DataTrack';

  use Moose::Util::TypeConstraints;

# required fields
  has 't' => ( is => 'rw', isa => enum( [qw[ scatter line histogram tile heatmap text connector ]]), required => 1 );
  has 'r0' => ( is => 'rw', isa => 'Str', required => 1 );
  has 'r1' => ( is => 'rw', isa => 'Str', required => 1 );

# optional fields
  has 'min' => ( is => 'rw', isa => 'Num' );
  has 'max' => ( is => 'rw', isa => 'Num' );
  has 'orientation' => ( is => 'rw', isa => enum( [qw[ in out ]]) );

  has 'background' => ( is => 'rw', isa => enum( [qw[ yes no ]]), default => "no" );
  has 'background_color' => ( is => 'rw', isa => 'Str' );
  has 'background_stroke_color' => ( is => 'rw', isa => 'Str' );
  has 'background_stroke_thickness' => ( is => 'rw', isa => 'Num' );

  has 'axis' => ( is => 'rw', isa => enum( [qw[ yes no ]]), default => "no" );
  has 'axis_color' => ( is => 'rw', isa => 'Str' );
  has 'axis_thickness' => ( is => 'rw', isa => 'Num' );
  has 'axis_spacing' => ( is => 'rw', isa => 'Num' );

  has 'min_value_change' => ( is => 'rw', isa => 'Num' );
  has 'skip_run' => ( is => 'rw', isa => enum( [qw[ yes no ]]), default => "no" );
  has 'z' => ( is => 'rw', isa => 'Num' );

  has 'flow' => ( is => 'rw', isa => enum( [qw[ yes no ]]), default => "no" );
  has 'scale_log_base' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => "no" );
}

package Highlight;
{
  use Moose;
  extends 'DataTrack';

  use Moose::Util::TypeConstraints;

# required fields
  has 'r0' => ( is => 'rw', isa => 'Str', init_arg => 'r0', required => 1 );
  has 'r1' => ( is => 'rw', isa => 'Str', init_arg => 'r1', required => 1 );

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
  has 'radius' => ( is => 'rw', isa => enum( [qw[ scatter line histogram tile heatmap text connector ]])
                  , required => 1 );

# optional fields
  has 'record_limit' => ( is => 'rw', isa => 'Int', default => 1000);
  has 'color' => ( is => 'rw', isa => 'Str' );
  has 'thickness' => ( is => 'rw', isa => 'Num' );
  has 'bezier_radius' => ( is => 'rw', isa => 'Num' );
  has 'bezier_radius_purity' => ( is => 'rw', isa => 'Num' );
  has 'ribbon' => ( is => 'rw', isa => enum( [qw[ yes no ]]), default => "no" );
  has 'stroke_color' => ( is => 'rw', isa => 'Str' );
  has 'stroke_thickness' => ( is => 'rw', isa => 'Str' );
  has 'twist' => ( is => 'rw', isa => enum( [qw[ yes no ]]) );
  has 'flat' => ( is => 'rw', isa => enum( [qw[ yes no ]]) );
  has 'crest' => ( is => 'rw', isa => enum( [qw[ yes no ]]) );
}

package Rule;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  # required fields
  has 'importance' => ( is => 'rw', isa => 'Int', init_arg => 'importance', required => 1 );
  has 'condition' => ( is => 'rw', isa => 'Str', init_arg => 'condition', required => 1 );
  has 'params' => ( is => 'rw', isa => 'HashRef', required => 1 );

  sub getRule {
    my $self = shift;
    my $hash = $self->{params};
    my $string = "";

    while ( my ( $k, $v ) = each %$hash ) {
      $string .= "$k = $v\n";
    }

    return $string;
  }
}

1;