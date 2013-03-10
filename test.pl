#!/usr/bin/perl 
use strict;
use warnings;
use lib::CircosAPI;
use Data::Dumper;

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

# 3.

$b->chromosomes_display_default('no');
$b->chromosomes('/hs[1-4]$/');
$b->chromosomes_scale('hs1=0.5r,/hs[234]/=0.5rn');
$b->chromosomes_reverse('/hs[234]/');
$b->chromosomes_color('hs1=red,hs2=orange,hs3=green,hs4=blue');
$b->chromosomes_radius('hs4:0.9r');

print $c->compile;