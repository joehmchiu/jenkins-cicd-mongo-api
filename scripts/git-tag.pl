#!/usr/bin/perl

use strict;
use constant MAX => 10;

my $res;
my @tag = `git describe --tags --abbrev=0`;
my $tag = pop @tag;

if ($tag =~ /^v.(\d{1,}).(\d{1,})$/g) {
  if ($2 < MAX) {
    $res = sprintf "v.%d.%d", $1, $2 + 1;
  } else {
    $res = sprintf "v.%d.%d", $1 + 1, 1;
  }
} else {
  $res = "v.1.1";
}

print $res;
