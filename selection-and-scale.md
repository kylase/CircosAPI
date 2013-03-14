# Ideogram Labels

The last method that we can use to change the values of the parameters is by accessing the parameters via its setter.

From Example 1 and 2, our `chromosomes_display_default` is initialized as `yes` by default. But we want to change it to `no` so we can hide some chromosomes for this example.

{% highlights perl %}
$base_hg19->chromosomes_display_default('no');
{% endhighlights %}

Using single quote instead of double quote is recommended because you can pass in regular expressions, function such as `eval` to the value of the parameters.

{% highlights perl %}
$base_hg19->chromosomes('/hs[1-4]$/');
$base_hg19->chromosomes_scale('hs1=0.5r,/hs[234]/=0.5rn');
$base_hg19->chromosomes_reverse('/hs[234]/');
$base_hg19->chromosomes_color('hs1=red,hs2=orange,hs3=green,hs4=blue');
$base_hg19->chromosomes_radius('hs4:0.9r');
{% endhighlights %}

Compile `$c` and print it on console to get your .conf file.