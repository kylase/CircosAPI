---
title: Axes and Backgrounds
layout: default
---

# Axes and Background

Axes and backgrounds are associated with the data tracks (namely Plot, Highlight and Link). You can add axes and backgrounds to your tracks by instantiating [Axis](/reference#Axis) and [Background](/reference#Background).

{% highlight perl %}
# Backgrounds
my $bg_whole = Background->new( color => 'vvlgrey' );
my $bg_track1 = Background->new( color => 'vlgrey', y0 => '0.2r', y1 => '0.5r' );
my $bg_track2 = Background->new( color => 'lgrey', y0 => '0.5r', y1 => '0.8r' );
my $bg_track3 = Background->new( color => 'grey', y0 => '0.8r' );

my $bg = Backgrounds->new( show => 'data' );

$bg->addBackground($bg_whole, $bg_track1, $bg_track2, $bg_track3 );

$inner_plot_segdup_hist->backgrounds($bg);

# Axes
my $axes = Axes->new( show => 'data', thickness => 1, color => 'lgrey' );
my $axis1 = Axis->new( spacing => '0.1r' );
my $axis2 = Axis->new( spacing => '0.2r', color => 'grey' );
my $axis3 = Axis->new( spacing => '0.5r', color => 'red' );
my $axis4 = Axis->new( spacing => '0.8r', color => 'green', thickness => 2 );

$axes->addAxis( $axis1, $axis2, $axis3, $axis4 );

$outer_plot_segdup_stacked->axes($axes);
{% endhighlight %}

This concludes the tutorials. Feel free to ask me anything through [github](https://github.com/kylase/CircosAPI/issues).