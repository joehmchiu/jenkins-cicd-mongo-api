#!/usr/bin/perl

use strict;
<<<<<<< HEAD
use constant MAX => 9;

my $res;
`git fetch --all --tags --prune`;
my @tag = `git tag -l "v*"`;
=======
use constant MAX => 10;

my $res;
my @tag = `git describe --tags --abbrev=0`;
>>>>>>> 66b7bf567780e9210759da07a12c705dda58491e
my $tag = pop @tag;

if ($tag =~ /^v.(\d{1,}).(\d{1,})$/g) {
  if ($2 < MAX) {
    $res = sprintf "v.%d.%d", $1, $2 + 1;
  } else {
    $res = sprintf "v.%d.%d", $1 + 1, 1;
  }
} else {
<<<<<<< HEAD
  $res = "v.1.0";
=======
  $res = "v.1.1";
>>>>>>> 66b7bf567780e9210759da07a12c705dda58491e
}

print $res;
