# Ideogram Labels

Previously, you have create a script that will create an image with the ideogram.

{% highlights perl %}
# Headers omitted
my $base_hg19 = Base->new(karyotype => 'hg19');
my $c = CircosAPI->new(base => $base_hg19);
print $c->compile;
{% endhighlights %}

Now we want to add labels to the ideogram. You can specify the parameters in the defaults.json, but you can do it programmatically as well. You can use the update method on any objects to change the values of the parameters.

{% highlights perl %}
my $labels_params = { show_label => 'yes', 
                      label_font => 'default', 
                      label_radius => '1r + 75p', 
                      label_size => '30', 
                      label_parallel => 'yes' };

$c->{ideogram}->update($labels_params);
{% endhighlights %}

We want ticks on the ideogram. Therefore we need to create the local `tick` blocks and a global `ticks` block.

{% highlights perl %}
# Global ticks block
my $ticks = Ticks->new(radius => '1r', color => 'black', thickness => '2p', multiplier => '1e-6', format => '%d');

# Local tick blocks
my $minor_tick = Tick->new(spacing => '5u', size => '10p');
my $major_tick = Tick->new(spacing => '25u', size => '15p', show_label => 'yes', label_size => '20p', label_offset => '10p', format => '%d');
{% endhighlights %}

Now we have the global `ticks` block and the local `tick` blocks. We know that the `tick` blocks should be in the `ticks` block. So in order to do that, we add `tick` by calling `addTick` on the `ticks` block.

{% highlights perl %}
$ticks->addTick($minor_tick, $major_tick);
$c->ticks($ticks);
{% endhighlights %}

Lastly, we need to add the `ticks` to our `CircosAPI` block.

{% highlights perl %}
$c->ticks($ticks);
{% endhighlights %}

Print the compile and run circos to get the image.