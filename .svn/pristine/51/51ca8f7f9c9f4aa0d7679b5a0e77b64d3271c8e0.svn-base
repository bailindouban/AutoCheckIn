#!/usr/bin/perl  For vendor/amax-prebuilt
use strict;

# Read branch file
my $base_origin = "/home/junzheng_zhang/Desktop/kim";	
my $base_folder = "$base_origin/out";

open (BRANCH, "$base_folder/branches.csv") or die $!;
my @device_remote_branch = <BRANCH>;
my $branch_count = scalar(@device_remote_branch);

# Welcome and require user input parameters.
my @remotes = ();
my @branches = ();
for(my $i = 0; $i < $branch_count; $i++) {
	chomp $device_remote_branch[$i];
	my @temp = split(",", $device_remote_branch[$i]);
	$remotes[$i] = $temp[1];

	print "\n************* Delete branch ****************\n\n";
	$branches[$i] = $temp[2];
	system("git b -D $branches[$i]");
}

foreach(@remotes) {
	print "\n********** Remove remote: $_************\n\n";
	system("git remote rm $_");
}

