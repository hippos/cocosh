#!/usr/bin/perl
# cocosh.pl

#  Created by hippos on 10/04/14.
#  Copyright 2010 hippos-lab.com. All rights reserved.

use strict;
use Cwd;

print "Hello (perl) World\n";
my $wd = Cwd::getcwd();
print "Current Directory is $wd\n";