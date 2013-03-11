#!/usr/bin/perl 
use strict;
use warnings;
use lib::CircosAPI;

# Tutorial
# 1. Hello World

my $b = Base->new(karyotype => 'hg19');
my $c = CircosAPI->new(base => $b);

# print $c->compile;

# 2. Ideogram Labels
my $spacing_params = { default => "0.005r" };
my $labels_params = { show_label => "yes", label_font => "default", label_radius => "1r + 75p", label_size => "30", label_parallel => "yes", spacing => Spacing->new($spacing_params) };

$c->{ideogram}->update($labels_params);
my $ticks = Ticks->new(radius => "1r", color => "black", thickness => "2p", multiplier => "1e-6", format => '%d');
my $tick1 = Tick->new(spacing => "5u", size => "10p");
my $tick2 = Tick->new(spacing => "25u", size => "15p", show_label => "yes", label_size => "20p", label_offset => "10p", format => '%d');
$ticks->addTick($tick1, $tick2);
$c->ticks($ticks);

# print $c->compile;

# 3. Selection and scale

$b->chromosomes_display_default('no');
$b->chromosomes('/hs[1-4]$/');
$b->chromosomes_scale('hs1=0.5r,/hs[234]/=0.5rn');
$b->chromosomes_reverse('/hs[234]/');
$b->chromosomes_color('hs1=red,hs2=orange,hs3=green,hs4=blue');
$b->chromosomes_radius('hs4:0.9r');

#print $c->compile;

# 4. Links and rules

my $l = Link->new(file => 'data/5/segdup.txt', radius => '0.8r', bezier_radius => '0r', color => 'black_a4', thickness => 2);
$l->addRule(Rule->new(condition => 'var(intrachr)', params => { show => 'no' } ));
$l->addRule(Rule->new(condition => '1', params => { color => 'eval(var(chr2))', flow => 'continue' }));
$l->addRule(Rule->new(condition => 'from(hs1)', params => { radius1 => '0.99r' }));
$l->addRule(Rule->new(condition => 'to(hs1)', params => { radius2 => '0.99r' }));
$c->addLink($l);

# 5. Histogram

my $hist_data = { t => 'histogram', 
                file => 'data/5/segdup.hs1234.hist.txt', 
                r1 => '0.88r', r0 => '0.81r', 
                fill_color => 'vdgrey', 
                extend_bin => 'no'};

my $p = Plot->new($hist_data);
my $r = Rule->new(condition => 'on(hs1)', params => { show => 'no' } );
my $p2 = Plot->new(t => 'histogram', file => 'data/5/segdup.hs1234.stacked.txt', r1 => '0.99r', r0 => '0.92r', fill_color => 'hs1,hs2,hs3,hs4', orientation => 'in');
$p->addRule($r);
$p2->addRule($r);
$c->addPlot($p, $p2);

# 6. Axes and Background

print $c->compile;