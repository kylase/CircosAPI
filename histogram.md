# Histogram

Reusablilty is a double-edged sword. It can help to save time but create more mess.

`type` is a reserved keyword in Perl. We can't use `type` as a parameters. We use `t` in place of `type`. Don't worry, when it compiles, `t` will be converted to `type`.

{% highlights perl %}
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
{% endhighlights %}

I hope by now you can understand how this API works just by reading the code. =)
