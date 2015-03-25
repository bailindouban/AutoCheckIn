#!/usr/bin/perl  
use strict;

open(OLD_VENDOR, "/home/junzheng_zhang/Desktop/kim/vendor/branches.csv") or die $!;
open(OLD_OUT, "/home/junzheng_zhang/Desktop/kim/out/branches.csv") or die $!;
open(NEW, "/home/junzheng_zhang/Desktop/kim/parse_html/parse_html.csv") or die $!;

my @old_vendor = <OLD_VENDOR>;
my @old_out = <OLD_OUT>;
my @old = (@old_vendor, @old_out);
my @new = <NEW>;
shift @new;


my $num_o = scalar(@old);
my $num_n = scalar(@new);

print "Find New: \n";
for(my $i = 0; $i < $num_n; $i++) {
	my @ele_new = split(',', $new[$i]);
	for(my $j = 0; $j < $num_o; $j++) {
		my @ele_old = split(',', $old[$j]);
		if($ele_new[0] eq $ele_old[2]) {
			last;		
		}
		
		if($j == $num_o - 1) {
			print "Can not find new: \n";
			print "$i.\t$new[$i]\n";	
		}
	}
}

print "\nFind Old: \n";
for(my $i = 0; $i < $num_o; $i++) {
	my @ele_old = split(',', $old[$i]);
	for(my $j = 0; $j < $num_n; $j++) {
		my @ele_new = split(',', $new[$j]);
		if($ele_old[2] eq $ele_new[0]) {
			last;		
		}
		
		if($j == $num_n - 1) {
			#print "Can not find old $i.\t$old[$i]";	
		}
	}
}

# Show reviewer diff
if($ARGV[0] eq 'r') {
	print "Show Reviewer diff: \n";
	for(my $i = 0; $i < $num_n; $i++) {
		chomp $new[$i];
		my @ele_new = split(',', $new[$i]);
		for(my $j = 0; $j < $num_o; $j++) {
			chomp $old[$j];
			my @ele_old = split(',', $old[$j]);
			if($ele_new[0] eq $ele_old[2]) {
				if($ele_old[3] =~ m/$ele_new[2]/) {
				} else {
					print $ele_old[2].": \n";
					print $ele_old[3]."\n".$ele_new[2]."\n\n";
				}				
				last;		
			}
		}
	}
}

close OLD_VENDOR;
close OLD_OUT;
close NEW;
