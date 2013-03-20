#!/usr/bin/perl 
use strict;
use warnings;
use lib::CircosAPI;

# Tutorial
# 1. Hello World

my $base_hg19 = Base->new(karyotype => 'hg19');
my $c = CircosAPI->new(base => $base_hg19);

# print $c->compile;

# 2. Ideogram Labels
my $spacing_params = { default => '0.005r' };
my $labels_params = { show_label => 'yes', label_font => 'default', label_radius => '1r + 75p', label_size => '30', label_parallel => 'yes', spacing => Spacing->new($spacing_params) };

$c->{ideogram}->update($labels_params);
my $ticks = Ticks->new(radius => '1r', color => 'black', thickness => '2p', multiplier => '1e-6', format => '%d');
my $minor_tick = Tick->new(spacing => '5u', size => '10p');
my $major_tick = Tick->new(spacing => '25u', size => '15p', show_label => 'yes', label_size => '20p', label_offset => '10p', format => '%d');
$ticks->addTick($minor_tick, $major_tick);
$c->ticks($ticks);

# print $c->compile;

# 3. Selection and scale

$base_hg19->chromosomes_display_default('no');
$base_hg19->chromosomes('/hs[1-4]$/');
$base_hg19->chromosomes_scale('hs1=0.5r,/hs[234]/=0.5rn');
$base_hg19->chromosomes_reverse('/hs[234]/');
$base_hg19->chromosomes_color('hs1=red,hs2=orange,hs3=green,hs4=blue');
$base_hg19->chromosomes_radius('hs4:0.9r');

#print $c->compile;

# 4. Links and rules

my $segdup_link_black = Link->new(file => 'data/5/segdup.txt', radius => '0.8r', bezier_radius => '0r', color => 'black_a4', thickness => 2);

$segdup_link_black->addRule(Rule->new(condition => 'var(intrachr)', params => { show => 'no' } ));
$segdup_link_black->addRule(Rule->new(condition => '1', params => { color => 'eval(var(chr2))', flow => 'continue' }));

my $rule_fromhs1 = Rule->new(condition => 'from(hs1)', params => { radius1 => '0.99r' });
my $rule_tohs1 = Rule->new(condition => 'to(hs1)', params => { radius2 => '0.99r' });
$segdup_link_black->addRule($rule_fromhs1, $rule_tohs1);

$c->addLink($segdup_link_black);

my %colors = ( 'chr1*', 'red', 'chr2*', 'orange', 'chr3*', 'green', 'chr4*', 'blue' );

$c->colors(\%colors);
#print $c->compile;

# 5. Histogram

my $segdup_hist_params = { t => 'histogram', 
                file => 'data/5/segdup.hs1234.hist.txt', 
                r1 => '0.88r', r0 => '0.81r', 
                fill_color => 'vdgrey', 
                extend_bin => 'no' };

my $inner_plot_segdup_hist = Plot->new($segdup_hist_params);
my $outer_plot_segdup_stacked = Plot->new(t => 'histogram', file => 'data/5/segdup.hs1234.stacked.txt', r1 => '0.99r', r0 => '0.92r', fill_color => 'hs1,hs2,hs3,hs4', orientation => 'in');

my $rule_onhs1_noshow = Rule->new(condition => 'on(hs1)', params => { show => 'no' } );
$inner_plot_segdup_hist->addRule($rule_onhs1_noshow);
$outer_plot_segdup_stacked->addRule($rule_onhs1_noshow);
$c->addPlot($inner_plot_segdup_hist, $outer_plot_segdup_stacked);

# 6. Axes and Background
my $bg_whole = Background->new( color => 'vvlgrey' );
my $bg_track1 = Background->new( color => 'vlgrey', y0 => '0.2r', y1 => '0.5r' );
my $bg_track2 = Background->new( color => 'lgrey', y0 => '0.5r', y1 => '0.8r' );
my $bg_track3 = Background->new( color => 'grey', y0 => '0.8r' );
my $bg = Backgrounds->new( show => 'data' );
$bg->addBackground($bg_whole, $bg_track1, $bg_track2, $bg_track3 );
$inner_plot_segdup_hist->backgrounds($bg);

my $axes = Axes->new( show => 'data', thickness => 1, color => 'lgrey' );
my $axis1 = Axis->new( spacing => '0.1r' );
my $axis2 = Axis->new( spacing => '0.2r', color => 'grey' );
my $axis3 = Axis->new( spacing => '0.5r', color => 'red' );
my $axis4 = Axis->new( spacing => '0.8r', color => 'green', thickness => 2 );
$axes->addAxis( $axis1, $axis2, $axis3, $axis4 );
$outer_plot_segdup_stacked->axes($axes);

print $c->compile;