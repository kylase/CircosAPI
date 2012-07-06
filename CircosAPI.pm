package Circos;

use Carp qw(confess);
use strict;
use warnings;

=head1 NAME

Circos - Programmable Interface for Circos

=cut

=head1 VERSION 

This document describes the API provided by Circos version 0.1

=cut

=SYNOPSIS

	use Circos;

=cut

=head1 DESCRIPTION

This module provides the necessary APIs to define a Circos configuration file. 

=cut

our $VERSION = '0.1';

sub new {
	# resolution, karyotype, angle_offset, filname, png, svg
	my $class = shift;

	if (scalar @_ < 2) {
		confess "Number of inputs is less than what is required. Please enter resolution and karyotype as the inputs"
	} 

	my ($radius, $karyotype) = (shift, shift);
	
	# Optional parameters
	my $angle_offset = scalar @_ > 0 ? $_[0] : -90;
	my $filename = scalar @_ > 0 ? $_[1] : 'circos.png';
	my $png = scalar @_ > 0 ? $_[2] : 'yes';
	my $svg = scalar @_ > 0 ? $_[3] : 'no';

	my $self = {
		colors => {
			default => 1,
			src => undef,
			default_src => "etc/brewer.conf",
		},

		fonts => {
			default => 1,
			src => undef,
			default_src => "etc/fonts.conf",
		},

		ideogram => {
			default => 1,
			spacing => {
				default => '0.005r',
				break => '0.5u',
			},
			radius => '0.9r',
			thickness => '25p',
			fill => 'yes',
			fill_color => 'white',
			stroke_thickness => 1,
			stroke_color => 'black',
			show_label => 'yes',
			label_font => 'bold',
			label_radius => 'dims(ideogram,radius) + 85p',
			label_with_tag => 'yes',
			label_size => 36,
			label_parallel => 'yes',
			show_bands => 'yes',
			fill_bands => 'yes',
			band_stroke_thickness => 2,
			band_stroke_color => 'white',
			band_transparency => 1,

			default_src => "../Common/ideogram.conf",
			src => undef,
		},

		ticks => {
			default => 1,
			default_src => "../Common/ticks.conf",
			src => undef,

			show_ticks => 'yes',
			show_tick_labels => 'yes',

			skip_first_label => 'no',
			skip_label_label => 'no',
			radius => 'dims(ideogram,radius_outer)',
			tick_separation => '3p',
			label_separation => '1p',
			multiplier => '1e-6',
			color => 'black',
			thickness => '4p',
			size => '20p',

			tick => {
				level => 1,
				spacing => '50u',
				show_label => 'yes',
				label_size => '20p',
				label_offset => '10p',
				format => '%d',
				grid => 'yes',
				grid_color => 'dgrey',
				grid_thickness => '1p',
				grid_start => '0.5r',
				grid_end => '0.999r',
			},

			tick1 => {
				level => 2,
				spacing => '10u',
				show_label => 'no',
				thickness => '3p',
				color => 'vdgrey'
			}
		},

		image => {
			dir => '.',
			file => $filename,
			png => $png,
			svg => $svg,
			radius => $radius."p",
			angle_offset => $angle_offset,
			auto_alpha_colors => 'yes',
			auto_alpha_steps => 5,
		},

		karyotype => $karyotype,
		chromosomes => 'all',
		chromosomes_units => 1000000,

		plots => [],
		plotsProp => {},

		links => [],
		linksProp => {
			z => 0,
			crest => undef,
			bezier_radius => undef,
			bezier_radius_purity => undef,
		},

		highlights => [],
		highlightsProp => {
			z => undef,
			fill_color => undef,
		},
	};

	bless $self, $class;

	return $self;
}

sub setTicksSource {
	my $self = shift;

	$self->{ticks}->{src} = shift;
	$self->{ticks}->{default} = 0;
}

sub setIdeogramSource {
	my $self = shift;

	$self->{ideogram}->{src} = shift;
	$self->{ideogram}->{default} = 0;
}

sub setColorsSource {
	my $self = shift;

	$self->{colors}->{src} = shift;
	$self->{colors}->{default} = 0;
}

sub setFontsSource {
	my $self = shift;

	$self->{fonts}->{src} = shift;
	$self->{fonts}->{default} = 0;
}

sub setAngleOffset {
	my $self = shift;

	$self->{image}->{angle_offset} = shift;
}

sub setTransparency {
	# 'yes'/'no', number of transparency steps
	my $self = shift;

	$self->{image}->{auto_alpha_colors} = shift;
	$self->{image}->{auto_alpha_steps} = shift;
}

sub setChromsomeUnits {
	my $self = shift;

	$self->{chromosomes_units} = shift;
	printf "u is set to %d", $self->{chromosomes_units};
}

sub setOutputFormat {
	my $self = shift;

	my $output = @_;

	if ( $output eq 'both' ) {
		$self->{image}->{png} = $self->{image}->{svg} = 'yes';
	} else {
		$self->{image}->{png} = $output eq 'png' ? 'yes' : 'no';
		$self->{image}->{svg} = $output eq 'svg' ? 'yes' : 'no';
	}
}

sub addPlot {
	my $self = shift;

	my $track = {
		# Common Parameters across all kinds of plots
		file => shift,
		type => shift,
		r0 => shift.'r',
		r1 => shift.'r',

		min => undef,
		max => undef,
		
		orientation => undef,

		background => 'no',
		background_color => undef,
		background_stroke_color => undef,
		background_stroke_thickness => undef,

		axis => 'no',
		axis_color => undef,
		axis_thickness => undef,
		axis_spacing => undef,

		skip_run => undef,
		min_value_change => undef,
		z => undef,

		flow => undef,
		scale_log_base => undef,
		rules => [],
	};

	if ($track->{type} eq 'scatter') {			
		$track->{glyph} = 'circle';
		$track->{glyph_size} = '16p';
		$track->{fill_color} = 'black';
		$track->{stroke_color} = 'black';
		$track->{storke_thickness} = 1;
	} elsif ($track->{type} eq 'line') {
		$track->{thickness} = 1;
		$track->{color} = 'black';
		$track->{max_gap} = undef;
	} elsif ($track->{type} eq 'histogram') {
		$track->{thickness} = 1;
		$track->{color} = 'black';
		$track->{extend_bin} = 'no';
		$track->{fill_under} = 'no';
		$track->{fill_color} = undef;
	} elsif ($track->{type} eq 'tile') {
		$track->{layers} = 1;
		$track->{margin} = '0.02u';
		$track->{thickness} = 15;
		$track->{padding} = 8;
		$track->{layers_overflow} = 'hide';
		$track->{layers_overflow_color} = undef;
	} elsif ($track->{type} eq 'heatmap') {
		$track->{stroke_thickness} = 1;
		$track->{stroke_color} = 'black';
	} elsif ($track->{type} eq 'text') {
		$track->{show_links} = 'no';
		$track->{link_dims} = undef;
		$track->{link_thickness} = undef;
		$track->{link_color} = undef;
		$track->{label_size} = '24p';
		$track->{label_font} = 'glyph';
		$track->{padding} = undef;
		$track->{rpadding} = undef;
		$track->{label_rotate} = undef;
		$track->{label_snuggle} = 'no';
		$track->{max_snuggle_distance} = '1r';
		$track->{snuggle_sampling} = undef;
		$track->{snuggle_tolerance} = undef;
		$track->{snuggle_link_overlap_test} = undef;
		$track->{snuggle_link_overlap_tolerance} = undef;
		$track->{snuggle_refine} = undef;
	} elsif ($track->{type} eq 'connector') {
		$track->{thickness} = 1;
		$track->{color} = 'black';
		$track->{connector_dims} = undef;
	} else {
		confess "Unknown plot type specified.\n";
	}

	push @{$self->{plots}}, $track;
	my $n = scalar @{$self->{plots}} - 1;

	if ($self->{plots}[$n]->{r1} =~ /\+/) {
		$self->{plots}[$n]->{r1} = $self->{plots}[$n]->{r0}.$self->{plots}[$n]->{r1};
	} 

	print "\n@{$self->{plots}}[$n]->{file} allocated to Track $n from r = ".$self->{plots}[$n]->{r0}." to ".$self->{plots}[$n]->{r1}."\n";
}

sub addLink {
	my $self = shift;
	my $link = {
		file => shift,
		radius => shift,
		record_limit => 1000,
		color => undef,
		thickness => undef,
		bezier_radius => undef,
		bezier_radius_purity => undef,
		crest => undef,
		ribbon => undef,
		twist => undef,
		flat => undef,

		rules => [],
	};

	push @{$self->{links}}, $link;
	my $n = scalar @{$self->{links}} - 1;
	print "\n@{$self->{links}}[$n]->{file} allocated to Link $n\n";
}

sub addHighlight {
	my $self = shift;
	my $highlight = {
		file => shift,
		r0 => shift,
		r1 => shift,
		z => undef,
		fill_color => shift,
		stroke_color => shift,
		stroke_thickness => shift,
	}
}

sub addRule {
	# plots/links/highlights, track number, importance, condition, param1, value1, ... , paramN, valueN
	my $self = shift;
	my $type = shift;
	my $track = shift;
	my $rule = {
		importance => shift,
		condition => shift,
	};
	
	while (@_) {
		my $key = shift;
		if (validateKey($key)) {
			$rule->{$key} = shift;
		}
	}
	
	push @{$self->{$type}[$track]->{rules}}, $rule;
	# Output 
	my $n = scalar @{$self->{$type}} - 1;
	print "Rule added to Track $n (@{$self->{$type}}[$n]->{file})\n";
}

sub setPlotProperties {
	# parameter, value (in pairs)
	my $self = shift;
	my $t = shift;
	while (@_) {
		my $key = shift;
		if (validateKey($key)) {
			@{$self->{plots}}[$t]->{$key} = shift;
		}
	}
}

sub setLinkProperties {
	# parameter, value (in pairs)
	my $self = shift;
	my $t = shift;
	while (@_) {
		my $key = shift;
		if (validateKey($key)) {
			@{$self->{links}}[$t]->{$key} = shift;
		}
	}
}

sub setGlobalPlotProperties {
	# parameter, value (in pairs)
	my $self = shift;
	while (@_) {
		my $key = shift;
		if (validateKey($key)) {
			$self->{plotsProp}->{$key} = shift;
		}
	}
}

sub setGlobalHighlightProperties {
	# parameter, value (in pairs)
	my $self = shift;
	while (@_) {
		my $key = shift;
		if (validateKey($key)) {
			$self->{highlightsProp}->{$key} = shift;
		}
	}
}

sub setGlobalLinkProperties {
	# parameter, value (in pairs)
	my $self = shift;
	while (@_) {
		my $key = shift;
		if (validateKey($key)) {
			$self->{linksProp}->{$key} = shift;
		}
	}
}

sub setRange {
	# min, max
	my $self = shift;
	my $t = shift;
	@{$self->{plots}}[$t]->{min} = shift;
	@{$self->{plots}}[$t]->{max} = shift;
}

sub setBG {
	# yes/no, color, stroke_color, stroke_thickness
	my $self = shift;
	my $t = shift;
	my $show = shift;

	if ($show eq 'no') {
		@{$self->{plots}}[$t]->{background_color} = undef;
		@{$self->{plots}}[$t]->{background_stroke_color} = undef;
		@{$self->{plots}}[$t]->{background_stroke_thickness} = undef;
	} else {
		@{$self->{plots}}[$t]->{background} = 'yes';
		my ($color, $st_color, $st_thickness) = @_;
		@{$self->{plots}}[$t]->{background_color} = $color;
		@{$self->{plots}}[$t]->{background_stroke_color} = $st_color;
		@{$self->{plots}}[$t]->{background_stroke_thickness} = $st_thickness;
	}
}

sub setAxis {
	my $self = shift;
	my $t = shift;
	my $show = shift;

	if ($show eq 'no') {
		@{$self->{plots}}[$t]->{axis_color} = undef;
		@{$self->{plots}}[$t]->{axis_thickness} = undef;
		@{$self->{plots}}[$t]->{axis_spacing} = undef;
	} else {
		@{$self->{plots}}[$t]->{axis} = 'yes';
		my ($color, $thickness, $spacing) = @_;
		@{$self->{plots}}[$t]->{axis_color} = $color;
		@{$self->{plots}}[$t]->{axis_thickness} = $thickness;
		@{$self->{plots}}[$t]->{axis_spacing} = $spacing;
	}
}

sub printHash {
	my ($hash, $fh) = @_;

	while ( my ($k, $v) = each %{$hash} ) { 
		next if $k =~ /level/ || $k =~ /src/;
		print $fh "\t$k = $v\n" if ref($v) ne "HASH" && defined $v;
	};
}

sub writeSubFile {
	my ($self, $type) = @_;

	open my $subFileFH, '> '.$type.'.conf' or die $!;
	if ($type eq 'ticks') {
		my @keys = ('show_tick_labels', 'show_ticks');
		foreach (@keys) {
			print $subFileFH "$_ = $self->{$type}->{$_}\n";
		}
	}
		
	print $subFileFH "<$type>\n";
	while ( my ($k, $v) = each %{$self->{$type}} ) {
		next if $k eq 'src' || $k eq 'default' || $k eq 'default_src' || $k eq 'show_tick_labels' || $k eq 'show_ticks';
		if (ref $v eq "HASH") {
			if ($k =~ /tick/) {
				print $subFileFH "<tick>\n";
			} else {
				print $subFileFH "<$k>\n";
			}
			printHash $self->{$type}->{$k}, $subFileFH;
			if ($k =~ /tick/) {
				print $subFileFH "</tick>\n";
			} else {
				print $subFileFH "</$k>\n";
			}
		} else {
			print $subFileFH "$k = $v\n";  
		}
	}
	print $subFileFH "</$type>\n";
}
=cut
sub checkPlotRequirement {
	my $self = shift;
	if (scalar @{$self->{plots}}) {
		for my $i (0 .. scalar @{$self->{plots}} - 1) {
			my @type = ('scatter','line','histogram');

			while (my $j = each @type) {
				if (@{$self->{plots}}[$i]->{type} eq $j) {
					my @keys = ('min','max','axis','axis_color','axis_thickness','axis_spacing');

					while (my $k = each @keys) {
						if ($self->{plots}[$i]->{$k}) {
							print "% WARNING % $k is undefined for plot type \"$j\". \n\n";
						}
					}
				}
			}
		}
	}
}
=cut

sub validateKey {
	my @validKeys = ('default', 'radius', 'spacing', 'break', 'thickness', 'fill', 'fill_color', 'stroke_color', 'stroke_thickness', 'glyph', 'glyph_size', 'color', 'extend_bin', 'fill_under', 'layers', 'margin', 'padding', 'layers_overflow', 'value', 'orientation', 'layers_overflow_color', 'show_links', 'link_dims', 'link_thickness', 'link_color', 'label_size', 'label_font', 'padding', 'rpadding', 'label_rotate', 'label_snuggle', 'max_snuggle_distance', 'snuggle_sampling', 'snuggle_tolerance', 'snuggle_link_overlap_test', 'snuggle_link_overlap_tolerance', 'snuggle_refine', 'connector_dims', 'record_limit', 'bezier_radius', 'bezier_radius_purity', 'crest', 'ribbon', 'twist', 'flat', 'z', 'scale_log_base', 'show', 'max_gap', 'min', 'max');

	my $test = shift;

	foreach (@validKeys) {
		if ($test eq $_) {
			return 1;
		}
	}

	confess "$test is an invalid key. Please check the parameter that you entered."
}

sub writeConf {
	my $self = shift;
	my $filename = scalar @_ ? shift : "circos.conf";
	open(FH, '> '.$filename) or die $!;
	
	# $self->checkPlotRequirement();

	printf FH "<colors>\n";
	printf FH "<<include etc/colors.conf>>\n";
	if ($self->{colors}->{default} && !defined $self->{colors}->{src}) {
		printf FH "<<include %s>>\n", $self->{colors}->{default_src};
	} else {
		printf FH "<<include %s>>\n", $self->{colors}->{src};
	}
	print FH "</colors>\n";

	print FH "\n<fonts>\n";
	if ($self->{fonts}->{default} && !defined $self->{fonts}->{src}) {
		printf FH "\t<<include %s>>\n", $self->{fonts}->{default_src};
	} else {
		printf FH "\t<<include %s>>\n", $self->{fonts}->{src};
	}
	print FH "</fonts>\n";

	if ($self->{ideogram}->{default} && !defined $self->{ideogram}->{src}) {
		if (!open (F, '< '.$self->{ideogram}->{default_src})) {
			$self->writeSubFile ('ideogram');
			$self->{ideogram}->{default_src} = 'ideogram.conf';
		} 
		printf FH "\n<<include %s>>\n", $self->{ideogram}->{default_src};
	} else {
		printf FH "\n<<include %s>>\n", $self->{ideogram}->{src};
	}

	if ($self->{ticks}->{default} && !defined $self->{ticks}->{src}) {
		if (!open (F, '< '.$self->{ticks}->{default_src})) {
			$self->writeSubFile ('ticks');
			$self->{ticks}->{default_src} = 'ticks.conf';
		}
		printf FH "\n<<include %s>>\n", $self->{ticks}->{default_src};
	} else {
		printf FH "\n<<include %s>>\n", $self->{ticks}->{src};
	}

	print FH "\n<image>\n";
	while ( my ($k, $v) = each %{$self->{image}} ) { 
		print FH "\t$k = $v\n" if defined $v;
	};
	print FH "</image>\n";

	if ($self->{karyotype} eq "hg18") {
		print FH "\nkaryotype = ../Common/karyotype.human.hg18.txt\n";
	} elsif ($self->{karyotype} eq "hg19") {
		print FH "\nkaryotype = ../Common/karyotype.human.hg19.txt\n";
	} elsif ($self->{karyotype} eq "mm9") {
		print FH "\nkaryotype = ../Common/karyotype.mouse.mm9.txt\n";
	} else {
		confess "Error: Only hg18, hg19 and mm9 karyotypes are available for use. Please check your configuration.";
	}
	
	print FH "\nchromosomes_units = $self->{chromosomes_units}\n";
	
	if ($self->{chromosomes} eq 'all') {
		print FH "chromosomes = -hsY\n";
		print FH "chromosomes_display_default = yes\n";
	} else {
		print FH "chromosomes = ";
		print FH "chromosomes_display_default = no\n";
	}

	my $plotN = scalar @{$self->{plots}};
	if ($plotN > 0) {
		print FH "\n<plots>\n";
		while ( my ($k, $v) = each %{$self->{plotsProp}} ) {
				print FH "$k = $v\n" if defined $v;
			};
		for my $i (0 .. $plotN - 1) {
			print FH "\n<plot>\n";
			while ( my ($k, $v) = each %{$self->{plots}[$i]} ) {
				next if $k eq "rules"; 
				print FH "\t$k = $v\n" if defined $v;
			};
			
			my $ruleN = scalar @{$self->{plots}[$i]->{rules}} - 1;
			
			my $flow = 0;

			if ($ruleN > -1) {
				print FH "\n\t<rules>\n\n";
				
				for my $j (0 .. $ruleN) {
					print FH "\t\t<rule>\n";
					while ( my ($k, $v) = each %{$self->{plots}[$i]->{rules}[$j]}) {
						print FH "\t\t$k = $v\n" if defined $v;
					}
					print FH "\t\t</rule>\n\n";
				}
				print FH "\t</rules>\n";
			}
			print FH "\n</plot>\n";
		}
		print FH "</plots>\n";
	}

	my $linkN = scalar @{$self->{links}};

	if ($linkN > 0) {
		print FH "\n<links>\n";
		while ( my ($k, $v) = each %{$self->{linksProp}} ) {
				print FH "$k = $v\n" if defined $v;
			};
		for my $i (0 .. $linkN - 1) {
			print FH "\n<link L$linkN>\n";

			while ( my ($k, $v) = each %{$self->{links}[$i]} ) {
				next if $k eq "rules"; 
				print FH "\t$k = $v\n" if defined $v;
			};
			
			my $ruleN = scalar @{$self->{links}[$i]->{rules}} - 1;
			
			my $flow = 1;

			if ($ruleN > -1) {
				print FH "\n\t<rules>\n\n";
				print FH "\tflow = continue\n" if $flow;

				for my $j (0 .. $ruleN) {
					print FH "\t\t<rule>\n";
					while ( my ($k, $v) = each %{$self->{links}[$i]->{rules}[$j]}) {
						print FH "\t\t$k = $v\n" if defined $v;
					}
					print FH "\t\t</rule>\n\n";
				}
				print FH "\t</rules>\n";
			}
			print FH "</link>\n";
		}
		print FH "</links>\n";
	}

	my $hlightN = scalar @{$self->{highlights}};

	if ($hlightN > 0) {
		print FH "\n<highlights>\n";

		for my $i (0 .. $linkN - 1) {
			print FH "\n<highlight>\n";
			
			while ( my ($k, $v) = each %{$self->{highlights}[$i]} ) {
				next if $k eq "rules"; 
				print FH "\t$k = $v\n" if defined $v;
			};

			print FH "</highlight>\n";
		}
		print FH "</highlights>\n";
	}

	print FH "<<include etc/housekeeping.conf>>\n";

	close FH;

	print "Configuration file written as $filename\n"
}
1;