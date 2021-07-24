#!/usr/bin/perl

use strict;

sub ss;
sub run;

my @a = (
  {"c"=>"lscpu | grep 'CPU'","k"=>'CPU.*',"n"=>"CPU Check","t"=>"CPU"},
  # {"c"=>"grep MemTotal /proc/meminfo","k"=>'.*\skB',"n"=>"RAM Check","t"=>"memory"},
  # {"c"=>"dmesg | grep blocks","k"=>'^(?=.*\\bsda\\b)(?=.*\\bsdb\\b)(?=.*\\bsdc\\b)?.*$',"n"=>"Disk Mount","t"=>"disk mounts"},
  {"c"=>"dmesg | grep blocks","k"=>'^.*EXT4-fs.*$',"n"=>"Disks","t"=>"disk mounts"},
  {"c"=>"ip a s","k"=>'(?=.*eth0)(?=.*eth1)?.*',"n"=>"Network Check","t"=>"network"},
  {"c"=>"cat /etc/resolv.conf","k"=>'127.0.0.53',"n"=>"DNS Entry","t"=>"dns resolver setup"},
);

foreach my $h (@a) {
  run $h;
}

sub t {
  my $h = shift;
  my @t = ();
  my $line = '{';
  foreach my $k (keys %$h) {
    push @t, qq("$k":"$h->{$k}");
  }
  $line .= join ',', @t;
  $line .= '}';
}

sub run {
  my $h = shift;
  ss t($h);
  print `$h->{c}`;
}

sub ss {
  my $n = shift;
  printf "%s $n %s\n", '='x20, '='x20;
}
