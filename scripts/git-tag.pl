#!/usr/bin/perl

use strict;
use constant MAX => 9;

my $res;
`git fetch --all --tags --prune`;
my @tag = `git tag -l "v*"`;
my $tag = pop @tag;

if ($tag =~ /^v.(\d{1,}).(\d{1,})$/g) {
  if ($2 < MAX) {
    $res = sprintf "v.%d.%d", $1, $2 + 1;
  } else {
    $res = sprintf "v.%d.%d", $1 + 1, 1;
  }
} else {
  $res = "v.1.0";
}

print $res;
