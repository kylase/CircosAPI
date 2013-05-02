---
title: Installing Circos on OS X
layout: default
---

# Installing Circos on OS X

Installing [Circos](http://www.circos.ca) on Mac is a problem for many new users. This guide provides you the step-by-step guide that helps you install Circos on your Mac (tested on OS X 10.8). 

## Package Manager for OS X

[Homebrew](http://mxcl.github.com/homebrew/) is all you need for your Unix adventure, whether you want to learn to code or just use it for Circos. It is basically a package manager that allows you to download libraries and software easily, analogous to Ubuntu's `apt-get`. It is actively updated via the git system, so it is near the edge.

First, you will need Xcode, so go to the App Store and download it. What you need is the **Command Line Tool**. After you are done with installing Xcode, start the app and go to the menu: **Xcode** > **Preferences**. Under the **Download** tab, you will see the iOS Simulators and Command Line Tools. Click the Install button inline with Command Line Tools.

After installing the Commmand Line Tools, you need to use **Terminal**, a command line interface which you can find in Applications, to install Homebrew.

In Terminal, you will see `computer-name:/ username$`. For brevity, I will omit everything before the `$`. Enter the command after `$`.

{% highlight bash %}
$ ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
{% endhighlight %}

Now you are set to use Homebrew.

## Install the prerequisites for Circos

Circos requires the following to work:

1. Perl (OS X has Perl 5.12.4, so you do not need to do anything)
2. libpng 
3. jpeg
4. freetype
5. gd

You need to get freetype first because when you are installing gd, it will get libpng and jpeg for you automatically.
{% highlight bash %}
$ brew install freetype
{% endhighlight %}
After install freetype, you need to install gd with freetype.

{% highlight bash %}
$ brew install gd --with-freetype
{% endhighlight %}

## Perl modules

Install Perl modules is quite similar to what you have did so far. Perl has a module manager called CPAN. In order to install modules, you have to access CPAN.

{% highlight bash %}
$ sudo cpan
{% endhighlight %}

You will see the command line changed to `cpan[1]>`. Issue the following command (below) to install all the modules Circos needs, except GD.

`cpan[1]> install Config::General Font::TTF List::MoreUtils Math::Bezier Math::VecStat Params::Validate Readonly Regexp::Common Set::IntSpan Text::Format`

After installing the modules, you will need to download the perl GD module on your own and compile it. Exit CPAN by using `exit`.

Now let's download GD manually,
{% highlight bash %}
$ curl -O http://www.cpan.org/authors/id/L/LD/LDS/GD-2.49.tar.gz
{% endhighlight %}

Extract and compile the content,
{% highlight bash %}
$ tar xvfz GD-2.49.tar.gz
$ cd GD-2.49
$ perl Makefile.pl
$ make install
{% endhighlight %}

## Circos and CircosAPI

Now you have everything you need for Circos. Let's download Circos!

{% highlight bash %}
$ curl -0 http://circos.ca/distribution/circos-0.63-4.tgz
$ tar xvf circos-0.63-4.tgz
$ sudo ln -s circos-0.63-4/bin/circos /usr/local/bin/circos
{% endhighlight %}

Now when you type `circos` on your command line. You should see an error prompt by Circos, not `-bash: circos: command not found`.

[CircosAPI](http://www.github.com/kylase/CircosAPI) is Perl module, but it is not available on CPAN. However, you can get it from github by running the following command.

{% highlight bash %}
$ git clone git:github.com/kylase/CircosAPI
{% endhighlight %}

QED isn't it?
