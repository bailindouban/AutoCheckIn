#!/usr/bin/perl  
use strict;

open(FH, "/home/junzheng_zhang/Desktop/index_main_from.php") or die $!;
open(OUTPUT, ">/home/junzheng_zhang/Desktop/kim/parse_html/parse_html.csv") or die $!;
my $i = 1;
my $flag = 0;

my @titles = ("Branch Name", "Name", "Reviewer");

print OUTPUT join(",", @titles),"\n";

while(<FH>) {
	chomp $_;
	# Branch Name
	if(/Branch Name:<blockquote>(.*?)<\//) {
		if($1 ne "") {
			print OUTPUT "$1,";
			$i++;
			$flag = 1;
		} else {
			$flag = 0;		
		}	
	}
	
	# Name
	if($flag == 1 && /Source Code Folder:<blockquote>(.*?)<\//) {
		print OUTPUT "$1,";
	}
	
	# reviewer
	if($flag == 1 && /<div class="CollapsiblePanelContent">(.*?)<\//) {
		my $mail = $1;
		$mail =~ s/,/ & /g;
		print OUTPUT "$mail\n";
	}
}

close FH;
close OUTPUT;
