#!/usr/bin/perl 
use strict;
use warnings;
use lib::CircosAPI;
use Data::Dumper;

my $b = Base->new(karyotype => 'hg19');
my $c = CircosAPI->new(base => $b);

my $p = Plot->new(file => '/data/data.txt', r1 => '0.99r', r0 => '0.95r', t => 'scatter');
$p->addRule(Rule->new(importance => 100, condition => 'eval( _LABEL_ eq "A")', params => { show => 'yes', color => 'blue'} ));
$c->addPlot($p);
$c->addPlot($p);

#print Dumper($c);
print $c->compile;