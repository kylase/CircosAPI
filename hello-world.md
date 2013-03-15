---
title: Hello, World!
layout: default
---

# Hello World

This tutorial assumes you have used Circos before and you have programming experience. Experience in Perl is highly desired.

This tutorial is written with reference to the [Circos Quick Guide tutorial](http://circos.ca/documentation/tutorials/quick_guide/).

Every block in Circos configuration file is converted to an object in CircosAPI. The objects in CircosAPI contains the parameters you can put in the blocks. Therefore, there are subtle differences between the original configuration file and the configuration generated via this API.

There are several methods you can create your configuration file using CircosAPI.

1. Defaults
2. Hash
3. Passing individual parameters as arguments

### Using Defaults
You can set your default parameters for the following blocks in the JSON file (found in /defaults):

* Ideogram
* Ideogram > Spacing
* Image

{% highlight perl %}
#!/usr/bin/perl 
use strict;
use warnings;
use lib::CircosAPI;
# The above lines will be omitted for subsequent examples for brevity

my $base_hg19 = Base->new(karyotype => 'hg19');
my $c = CircosAPI->new(base => $base_hg19);
print $c->compile;
{% endhighlight %}

I highly recommend you to use single quote for the values as you may be passing values as valid Perl function during the course of making the graphics. 

Passing a value to only karyotype (`'hg19'`) for `Base` will initialize other parameters such as `chromosomes_unit` to their default values. Please refer to [Base](http://www.github.com/kylase/CircosAPI/wiki/) and [others](http://www.github.com/kylase/CircosAPI/wiki/) for their respective default values and the parameters that you are required to pass values to it.

The other parameters in Ideogram, Spacing and Image blocks will take the values from the JSON file (defaults.json). This example JSON file is the minimal you should have.

CircosAPI allows you to set your default parameters to your configuration via a JSON file that is found in the /defaults directory.

The defaults.json looks like this.

{% highlight javascript %}
{
   "ideogram" : {
      "fill" : "yes",
      "show" : "yes",
      "radius" : "0.9r",
      "label_font" : "default",
      "thickness" : "15p"
   },
   "spacing" : {
      "default" : "0.005r"
   },
   "base" : {
      "karyotype" : "hg19",
      "chromosome_units" : 1000000,
      "chromosomes_display_default" : "yes"
   },
   "image" : {
      "png" : "yes",
      "radius" : "1500p",
      "background" : "white",
      "file" : "circos.png",
      "dir" : ".",
      "angle_offset" : -90,
      "auto_alpha_steps" : 5,
      "auto_alpha_colors" : "yes",
      "svg" : "yes",
      "angle_orientation" : "clockwise"
   }
}
{% endhighlight %}

So you can change the values in this file.

### Output
Circos parses the .conf file to generate the graphics. Therefore you need to convert this Perl script to .conf. To do so, the last line in script.pl you saw above do just that. 

However, you need to run this script in the command line.

{% highlight bash %}
$ perl script.pl > circos.conf
{% endhighlight %}

This command creates a .conf file based on the script.pl.

After you get your .conf file, just do like what you have been doing with your .conf files previously.

{% highlight bash %}
$ circos -conf circos.conf
{% endhighlight %}