---
title: Links and Rules
layout: default
---

# Links and Rules

We have come to the essence of Circos. Links.

When you are creating your instances different data tracks, rules, etc. I encourage you to make your variable names descriptive so you can make sense of the code you are writing, allowing people to easily understand what you are doing and lastly, reusable instances (especially rules!).

This is the 5th example which we are making links. So we should create a variable named `$segdup_link_black` to describe it as using the segdup data and the links are black. 

{% highlight perl %}
my $segdup_link_black = Link->new(file => 'data/5/segdup.txt', radius => '0.8r', bezier_radius => '0r', color => 'black_a4', thickness => 2);
{% endhighlight %}

I understand it could become very verbose, but many text editors can help autocomplete your variable names. So you shouldn't worry. Check out [Sublime Text 2](http://www.sublimetext.com/2) if you do not have a great text editor.

Adding rules are simple. You can make either add the `rule` instance into the `link` instance directly.

{% highlight perl %}
$segdup_link_black->addRule(Rule->new(condition => 'var(intrachr)', params => { show => 'no' } ));
$segdup_link_black->addRule(Rule->new(condition => '1', params => { color => 'eval(var(chr2))', flow => 'continue' }));
{% endhighlight %}

Or, you can create a variable that contains the rule. 

{% highlight perl %}
my $rule_fromhs1 = Rule->new(condition => 'from(hs1)', params => { radius1 => '0.99r' });
my $rule_tohs1 = Rule->new(condition => 'to(hs1)', params => { radius2 => '0.99r' });

$segdup_link_black->addRule($rule_fromhs1, $rule_tohs1);
{% endhighlight %}

Lastly, add the link to the CircosAPI instance.

{% highlight perl %}
$c->addLink($segdup_link_black);
{% endhighlight %}