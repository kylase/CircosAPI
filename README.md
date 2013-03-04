CircosAPI
=========

## APIs for [CIRCOS: Circular Genome Data Visualization](http://www.circos.ca)

### Requirements
1. Perl > 5.12
2. Moose
3. JSON::PP
4. String::Util

## Features
* Programmatically generate your Circos graphics via Perl
* Configure your own defaults for your pipelines via JSON

## Getting Started

#### In your script.pl
    #!/usr/bin/perl

    use lib::CircosAPI;
    
    my $c = CircosAPI->new();

By instantiating a new instance of CircosAPI without any parameters will fill the minimal required parameters based on the defaults.json as found in lib/CircosAPI directory. You can change the defaults using a JSON file or pass a Hash to the blocks (shown below).
    
    my $b = Base->new(karyotype => 'hg19');
    my $id = Ideogram->new(radius => '0.95r', thickness => '20p');
    my $c = CircosAPI->new(base => $b, ideogram => $id);
    print $c->compile;

#### In your shell
    $ perl script.pl > circos.conf | circos -conf circos.conf

Please read the [API reference]() for more details on the parameters that you need to provide and the default value for some of the parameters if you do not provide them.