#!/usr/bin/perl  For vendor/amax-prebuilt
use strict;

# Read branch file
my $base_origin = "/home/junzheng_zhang/Desktop/kim";	
my $base_folder = "$base_origin/vendor";

my $output = "$base_folder/perl/all_branches.txt";
system("git b > $output");

open (BRANCH, $output) or die $!;
my @branches = <BRANCH>;
my $branch_count = scalar(@branches);

# Welcome and require user input parameters.
for(my $i = 0; $i < $branch_count; $i++) {
	chomp $branches[$i];
	if($branches[$i]=~/\*/) {
		next;
	}
	print "$i.\tRemove branch $branches[$i]\n";
	system("git b -D $branches[$i]");
}

close BRANCH

