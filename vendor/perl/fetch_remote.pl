#!/usr/bin/perl  For vendor/amax-prebuilt
use strict;

# Read branch file
my $base_origin = "/home/junzheng_zhang/Desktop/kim";	
my $base_folder = "$base_origin/vendor";

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
	print "\n********** Fetch remote: $remotes[$i]************\n\n";
	system("git fetch $remotes[$i]");

	$branches[$i] = $temp[2];
}

print "\n*************Checkout branch ****************\n\n";
foreach(@branches) {
	system("git checkout $_");
}

close BRANCH

