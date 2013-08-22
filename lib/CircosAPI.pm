package CircosAPI;
{
  use Moose;
  use Moose::Util::TypeConstraints;
  use JSON::PP;
  use String::Util qw(trim);

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
}

package CObject;
{
  use Moose;
  use Moose::Util qw/find_meta get_all_attribute_values/;
  use List::Util qw(min max);
  use Carp;
  use namespace::autoclean;

  sub getContentAsHashRef {
    my $self = shift;

    return get_all_attribute_values(find_meta($self), $self );
  }

  sub getAttributesAsString {
    my $self = shift;
    my $hash = $self->getContentAsHashRef;

    my $string = "";
    my @IGNORED_BLOCKS = qw(tick background axis);
    while ( my ($k, $v) = each %$hash ) {
      if ( ref $v eq 'ARRAY' ) {
        $string .= "<$k>\n" if !in($k, \@IGNORED_BLOCKS);
        foreach (@$v) {
          $string .= $_->getAttributesAsBlock;
        }
        $string .= "</$k>\n\n" if !in($k, \@IGNORED_BLOCKS);
      } elsif ( ref $v eq 'HASH' ) {
        $string .= "<$k>\n";
        while ( my ($K, $V) = each %$v ) {
          $string .= "$K = $V\n"; 
        }
        $string .= "</$k>\n\n"; 
      } else {
        if ( ref $v eq "" ) {
          if ($k eq "includes") {
              $string .= "$v\n" ;
            } else {
              $string .= ( lc($k) eq 't' ? 'type' : $k ) . " = $v\n" if ( defined($v) && min(map { $_ eq $k ? 0 : 1 } qw[id pair1 pair2]) );
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
      $string .= "<$class_name $self->{id}>\n" if $class_name ne "base";
    } else {
      $string .= "<$class_name>\n" if $class_name ne "base";
    }

    $string .= $self->getAttributesAsString;
    $string .= "</$class_name>\n\n" if $class_name ne "base";

    return $string; 
  }

  sub update {
    my $self = shift;
    my $meta = $self->meta;

    my $hash = shift;
    while (my ($k, $v) = each %$hash) {
      if ( max(map { $k eq $_->name } $meta->get_all_attributes) ) {
        $self->$k($v);
      } else {
        confess "$k is not a valid parameters\n";
      }
    }
  }

  sub in {
    my $val = shift;
    my $array = shift;
    foreach(@$array) {
      return 1 if $_ eq $val;
    }
    return 0;
  }
}

package DataTrack;
{
  use Moose;
  extends 'CObject';
  
  has 'file' => ( is => 'rw', isa => 'Str', init_arg => 'file', required => 1 );
  has 'rules' => ( is  => 'rw', isa => 'ArrayRef' );
  has 'backgrounds' => ( is => 'rw', isa => 'Backgrounds', init_arg => 'backgrounds' );
  has 'axes' => ( is => 'rw', isa => 'Axes', init_arg => 'axes' );

  sub addRule {
    my $self = shift;
    push @{ $self->{rules} }, shift;
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
                        open my $fh,  'defaults/karyotypes.json' or die $!;
                        my $json = JSON::PP->new;
                        my $stream = "";
                        while (<$fh>) {
                          chomp;
                          $stream .= trim($_);
                        } 
                        my $karyotypes = $json->decode($stream);
                        $set->($karyotypes->{$value});
                      } );
  has 'chromosomes_units' => ( is => 'rw', isa => 'Int', init_arg => 'units', default => 1000000 );
  has 'chromosomes' => ( is => 'rw', isa => 'Str', init_arg => 'chromosomes');
  has 'chromosomes_display_default' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => 'yes' );
  has 'chromosomes_scale' => ( is => 'rw', isa => 'Str');
  has 'chromosomes_reverse' => ( is => 'rw', isa => 'Str');
  has 'chromosomes_color' => ( is => 'rw', isa => 'Str');
  has 'chromosomes_radius' => ( is => 'rw', isa => 'Str');
  has 'show_ticks' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => 'yes' );
  has 'show_tick_labels' => ( is => 'rw', isa => enum([qw[ yes no ]]), default => 'yes' );
  has 'includes' => ( is => 'ro', isa => 'Str', default => "<<include etc/colors_fonts_patterns.conf>>\n<<include etc/housekeeping.conf>>")
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
  has 'fill_color' => ( is => 'rw', isa => 'Str' );
  has 'color' => ( is => 'rw', isa => 'Str' );
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

  # Text Labels
  has 'show_links' => ( is => 'rw', isa => enum( [qw[ yes no ]]), default => "no" );
  has 'label_size' => ( is => 'rw', isa => 'Str' );
  has 'label_rotate' => ( is => 'rw', isa => enum( [qw[ yes no ]]), default => "no" );
  has 'label_font' => ( is => 'rw', isa => 'Str' );
  
  # Padding
  has 'padding' => ( is => 'rw', isa => 'Str' );
  has 'rpadding' => ( is => 'rw', isa => 'Str' );
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
  has 'radius' => ( is => 'rw', isa => 'Str', required => 1 );

  # optional fields
  has 'record_limit' => ( is => 'rw', isa => 'Int' );
  has 'color' => ( is => 'rw', isa => 'Str' );
  has 'thickness' => ( is => 'rw', isa => 'Num' );
  has 'bezier_radius' => ( is => 'rw', isa => 'Str' );
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
  has 'importance' => ( is => 'rw', isa => 'Int', init_arg => 'importance' );
  has 'condition' => ( is => 'rw', isa => 'Str', init_arg => 'condition', required => 1 );
  has 'params' => ( is => 'rw', isa => 'HashRef' );

  sub getAttributesAsString {
    my $self = shift;
    my $hash = $self->getContentAsHashRef;
    my $string = "";

    while ( my ($k, $v) = each %$hash ) {
      if ( ref $v eq 'HASH' ) {
        while ( my ($K, $V) = each %$v ) {
          $string .= "$K = $V\n";
        } 
      } else {
        $string .= "$k = $v\n";
      }
    }
    return $string;
  }
}

package Tick;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'spacing' => ( is => 'rw', isa => 'Str', init_arg => 'spacing', required => 1);
  has 'chromosomes' => ( is => 'rw', isa => 'Str', init_arg => 'chromosomes');
  has 'size' => ( is => 'rw', isa => 'Str', init_arg => 'size');
  has 'thickness' => ( is => 'rw', isa => 'Str', init_arg => 'thickness');
  has 'color' => ( is => 'rw', isa => 'Str', init_arg => 'color');
  has 'show_label' => ( is => 'rw', isa => 'Str', init_arg => 'show_label');
  has 'label_size' => ( is => 'rw', isa => 'Str', init_arg => 'label_size');
  has 'label_offset' => ( is => 'rw', isa => 'Str', init_arg => 'label_offset');
  has 'format' => ( is => 'rw', isa => 'Str', init_arg => 'format');

}

package Ticks;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'radius' => ( is => 'rw', isa => 'Str', init_arg => 'radius', required => 1);
  has 'multiplier' => ( is => 'rw', isa => 'Str', init_arg => 'multiplier');
  has 'format' => ( is => 'rw', isa => 'Str', init_arg => 'format');
  has 'thickness' => ( is => 'rw', isa => 'Str', init_arg => 'thickness');
  has 'color' => ( is => 'rw', isa => 'Str', init_arg => 'color');
  has 'tick' => ( is => 'rw', isa => 'ArrayRef' );

  sub addTick {
    my $self = shift;
    while (my $t = shift) {
      push @{ $self->{tick} }, $t;
    } 
  }
}

package Axes;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;
  has 'show' => ( is => 'rw', isa => 'Str', init_arg => 'show' );
  has 'color' => ( is => 'rw', isa => 'Str', init_arg => 'color' );
  has 'spacing' => ( is => 'rw', isa => 'Str', init_arg => 'spacing' );
  has 'thickness' => ( is => 'rw', isa => 'Int', init_arg => 'thickness' );
  has 'position' => ( is => 'rw', isa => 'Str', init_arg => 'position' );
  has 'position_skip' => ( is => 'rw', isa => 'Str', init_arg => 'position_skip' );
  has 'axis' => ( is => 'rw', isa => 'ArrayRef', init_arg => 'axis' );

  sub addAxis {
    my $self = shift;
    while (my $t = shift) {
      push @{ $self->{axis} }, $t;
    } 
  }
}

package Axis;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'color' => ( is => 'rw', isa => 'Str', init_arg => 'color' );
  has 'spacing' => ( is => 'rw', isa => 'Str', init_arg => 'spacing' );
  has 'thickness' => ( is => 'rw', isa => 'Int', init_arg => 'thickness' );
  has 'position' => ( is => 'rw', isa => 'Str', init_arg => 'position' );
  has 'position_skip' => ( is => 'rw', isa => 'Str', init_arg => 'position_skip' );
}

package Backgrounds;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'show' => ( is => 'rw', isa => 'Str', init_arg => 'show' );
  has 'background' => ( is => 'rw', isa => 'ArrayRef', init_arg => 'background' );

  sub addBackground {
    my $self = shift;
    while (my $t = shift) {
      push @{ $self->{background} }, $t;
    } 
  }
}

package Background;
{
  use Moose;
  extends 'CObject';

  use Moose::Util::TypeConstraints;

  has 'y0' => ( is => 'rw', isa => 'Str', init_arg => 'y0' );
  has 'color' => ( is => 'rw', isa => 'Str', init_arg => 'color' );
  has 'y1' => ( is => 'rw', isa => 'Str', init_arg => 'y1' );

}

1;
