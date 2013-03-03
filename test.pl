#!/usr/bin/perl 
use strict;
use warnings;
use lib::CircosAPI;
use JSON::PP;
use Data::Dumper;
use String::Util qw(trim);

open my $fh, 'lib/CircosAPI/default_pretty.json' or die $!;

my $json = JSON::PP->new;
my $jsonStream = "";
while (<$fh>) {
  chomp;
  $jsonStream .= trim($_);
}

my $defaults_perl = $json->decode($jsonStream);
# print Dumper($defaults_perl->{ideogram});
close($fh);

my $id = Ideogram->new($defaults_perl->{ideogram});
my $c = CircosAPI->new(-ideogram => $id);

print $c->compile;