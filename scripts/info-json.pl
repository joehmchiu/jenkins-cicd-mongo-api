#!/usr/bin/perl

use JSON;
use Data::Dumper;
use lib '.';
use JSON::Parse 'read_json';
use Data::Dumper;

$log = "/tmp/adp-vm-info.log";
$json = "/tmp/junit-adp-vm-info.json";

@a = ();
@c = ();
$h = {};
$j = [];

eval {
  $p = read_json($log);
};
die "Invalid JSON format file - '$log'" if $@;

foreach (@$p) {
  $hh = {};
  chomp;
  $l = $_;
  if (/^={10,} (.*) ={10,}$/) {
    $js = $1;
    eval {
      $hh = from_json($js);
    };
    die "Invalid JSON string - '$js'" if $@;
    push @a, $hh;
    $c = $hh->{t};
    $h->{$c} = '';
  } else {
    $h->{$c} .= $l.'<br>';
    $l = q2($l);
  }
}

# access to servers

foreach $hh (@a) {
  $hh->{t} || next;
  $k = $hh->{k};
  $hh->{r} = $h->{$hh->{t}};
  push @$j, $hh;
}

$j2 = to_json($j);
print $j2;

# use open qw(:std :utf8);
# open FILE, "> $json"; 
# print FILE $j2; 
# close FILE;

sub q2 {
  s/"/\\"/g;
  $_;
}
