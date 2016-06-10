---
title: Circos on Linux Virtual Machine
layout: default
---

# Circos on Virtual Machine

This tutorial provides a standardized method to set up an environment for easy deployment of Circos.

The images here show a OS X version of Virtualbox. However, the Windows version is similar.

## 1. Download Virtualbox

Virtualbox is a free virtualization software that allows you to run other operating systems in your main operating system.

Whether you are running OS X or Windows, you can download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for the respective operating systems.

## 2. Download Ubuntu

In this tutorial, we are going to set up an [Ubuntu](http://www.ubuntu.com) VM for your needs. You can use other distributions such as [Mint](http://www.linuxmint.com), [Fedora](http://fedoraproject.org), etc. However, the steps will be different.

We are going to use the [64-bit server version](http://www.ubuntu.com/download/server), instead of the desktop version, since we are going to run Circos on command line. You can choose either 13.04 or 12.04.3 LTS, both are fine.

## 3. Setting up the Virtual Machine (VM)

After you have obtained a copy of Ubuntu, create a new VM using Ubuntu 64-bit.

![Initial Setup](/CircosAPI/img/vm-2.png)

You can set the amount of RAM and disk space you can spare for this VM. For the purpose of a guide, 512 MB or RAM and 8GB of disk space is allocated. The rest of the steps should be default options unless you want to store your VM in other location.

![VM Memory Size](/CircosAPI/img/vm-1.png)

![VM Hard Disk](/CircosAPI/img/vm-3.png)

Next, by default the VM is a single-core VM. We should increase the number of CPU to 2 or more through the **Setting** window. If you want network connection to this VM, you can set the network adapter as Bridged Adapter in the Network tab.

![Network](/CircosAPI/img/vm-4.png)

In the **Storage** tab, click on the disc in the **Attributes** column and browse the location where you downloaded your Ubuntu disc image and select the disc image.

![Mounting Ubuntu](/CircosAPI/img/vm-5.png)

Now we are ready to boot up the VM by clicking on the **Start** button.

You will arrive on a Ubuntu boot screen and select **Install Ubuntu Server**. Choose **United States** as the operating system language.

Follow the subsequent steps to set up your Ubuntu. When prompt for installing software, choose to install **OpenSSH Server** if you want the access your VM through SSH.

After everything has been set up, you should be greeted with a command line interface.

## 4. Setting up Circos

We know that Circos has a few dependencies such as Perl and GD.

Perl is readily available on Ubuntu out of the box. What we need to do is to set up the Perl modules and GD for Circos.

Just like [the OS X guide](/CircosAPI/os-x-installation-guide), it is as simple as a few simple steps.

In order to install libgd and its dependencies,
{% highlight bash %}
$ sudo apt-get install libgd-2-xpm-dev build-essential
{% endhighlight %}

Next, let's install the Perl modules,
{% highlight bash %}
$ sudo cpan
{% endhighlight %}

`cpan[1]> install Clone Config::General Font::TTF List::MoreUtils Math::Bezier Math::VecStat Math::Round Params::Validate Readonly Regexp::Common Set::IntSpan Text::Format GD`

After installing the libraries and Perl modules needed for Circos, the last step is Circos itself.

{% highlight bash %}
$ curl -O http://circos.ca/distribution/circos-0.64.tgz
$ tar xvf circos-0.64.tgz
{% endhighlight %}

You should now able to run Circos via `circos-0.64/bin/circos`.

## 5 Linking up VM to your Mac or Windows

### 5.1 Samba File Server
Setting up a Samba server will be a good option as it allows multiple users to easily access the VM.

Follow the [Samba Server Guide](https://help.ubuntu.com/community/Samba/SambaServerGuide) to set up Samba. You can then access the VM to run Circos via SSH (`ssh ubuntu@VM_IP`).
