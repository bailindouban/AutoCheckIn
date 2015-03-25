#!/usr/bin/perl  For vendor/amax-prebuilt
use strict;
use feature qw(switch);

print "\n*********** Get Format Tag ************\n\n";

my $project = $ARGV[0];
if($project eq "") {
	print "\nPlease use the script as: 'perl get_tag.pl project-name(ex. AsusDeskClock)'.\n\n";
} else {
	# determine the output folder path.
	opendir(DIR, "./") or die $!;
	my @dir = readdir(DIR);

	my $vendor_or_out = "vendor";
	if(grep /^out$/, @dir) {
		$vendor_or_out = "out";
	}
	close DIR;   
    
	# Read branch file
	my $base_origin = "/home/junzheng_zhang/Desktop/kim";	
	my $base_folder = "$base_origin/$vendor_or_out";
        
	open (BRANCH, "$base_folder/branches.csv") or die $!;
	my @device_remote_branch = <BRANCH>;
	my $branch_count = scalar(@device_remote_branch);

	# Welcome and require user input parameters.
	my @devices = ();
	my @remotes = ();
	my @branches = ();
	for(my $i = 0; $i < $branch_count; $i++) {
		chomp $device_remote_branch[$i];
		my @temp = split(",", $device_remote_branch[$i]);
		$devices[$i] = $temp[0];
		$remotes[$i] = $temp[1];
		$branches[$i] = $temp[2];
		print "$i\t$branches[$i]\n";
	}
	print "$branch_count\tAll\n";
	print "Please select the branch number(ex: 0,1...):";
	my $input = <STDIN>;
	chomp $input;

	#check user input
	my @select_num = split(",", $input);
	my $select_count = scalar(@select_num);
	my $flag = 0;
	foreach(@select_num) {
	    if(/\d+/) {
		if ($select_count > 1 && $_ == $branch_count) {
		    print "\n************** It seems you have already select some branches, so you should not select all\n\n";
		    $flag = 1;
		    last;
		} elsif ($_ >= 0 && $_ <= $branch_count) {
		    next;
		} else {
		    print "\n************** Please input one or more proper numbers which is between 0 and $branch_count\n\n";
		    $flag = 1;
		    last;      
		}
	    } else {
		print "\n************** Please input digital numbers\n\n";
		$flag = 1;
		last;  
	    }
	}

	# Open output tag file
        my $base_tag = "$base_origin/tags";
        if(-e "$base_tag") {
	} else{	
		system("mkdir $base_tag");	
	}

        if(-e "$base_tag/temp") {
	} else{	
		system("mkdir $base_tag/temp");	
	}

	if(-e "$base_tag/$project") {
	} else{	
		system("mkdir $base_tag/$project");	
	}

	my $output = "$base_tag/$project/tags_format_".$project."_".$vendor_or_out."_format.csv";
	my $output_old = "$base_tag/$project/tags_format_".$project."_".$vendor_or_out."_format_old.csv";
	my $output_com = "$base_tag/$project/tags_format_".$project."_".$vendor_or_out."_format_compare.csv";
	# Copy to old
	system("rm $output_old $output_com");
	system("cp $output $output_old");	
	system("rm $output");

	open(OUTPUT, ">>$output") or die $!;
	open(OUTPUT_COM, ">>$output_com") or die $!;
	open(OUTPUT_OLD, "$output_old") or die $!;
	my @olds = <OUTPUT_OLD>;
	shift @olds;
	shift @olds;
	my $olds_count = scalar(@olds);

	# print title
	print OUTPUT "$project - $vendor_or_out\n";
	print OUTPUT_COM "$project - $vendor_or_out\n";
	my @titles = ("Branch", "Tags", "APK Version", "TT Bugs", "Change Link", "Message", "Commit Id");
	print OUTPUT (join(",", @titles), "\n");	
	print OUTPUT_COM (join(",", @titles), "\n");

	my $output_num = 1;
	# Do work!
	if($flag == 0) {
	   # User select All
	   if($input == $branch_count) {
	       for(my $i = 0; $i < $branch_count; $i++) {
		   &doWork($i, $branch_count, $olds[$i]);
	       }
	   }
	   # User select some branches
	   else {
	       foreach(@select_num) {
		   &doWork($_, $select_count, $olds[$_]);
	       }
	   }
	}

	close BRANCH;
	close MESSAGE;
	
	sub getCompareEle() {
		(my $bra, my $ele_index) = @_;
		for(my $i = 0; $i < $olds_count; $i++) {
			chomp $olds[$i];
			my @ele = split(',', $olds[$i]);
			if($bra eq $ele[0]) {
				given($ele_index) {
					when(0) {return $ele[0]; }
					when(1) {return $ele[1]; }
					when(2) {return $ele[2]; }
					default {return "error param"; }
				}
			}
		}
		return "new branch";
	}
	
	sub doWork {
	    (my $p1, my $p2, my $old) = @_;

	    # checkout, reset and pull
	    print "\n\n************************** Now at branch $p1. $branches[$p1], total branch count: $p2\n\n";
	    print "\n\n************************** Checkout $branches[$p1] ***************************\n\n";
	    system("git ch $branches[$p1]");

	    print "\n\n************************** Reset ****************************\n\n";
	    for(my $k = 0; $k < 3; $k++) {
		if($vendor_or_out == "out") {
			system("git reset --hard HEAD~1"); 
		} else {
			system("git reset --hard HEAD~3"); 
		}
	    }
	    print "\n\n*************************** Pull ****************************\n\n";
	    system("git p");
	    
	    chomp $old; 		
	    my @ele = split(",", $old);
	    # 1. print tags to file tags.txt
	    print "\n******************** device: $devices[$p1],remote: $remotes[$p1],branch: $p1. $branches[$p1] ******************\n\n";
	    my $bra = "$devices[$p1] \[$branches[$p1]\]";
	    my $bra_com = &getCompareEle($bra, 0);
	    if($bra_com ne $bra) {
		print OUTPUT_COM "$bra_com -> ";
            }
	    print OUTPUT "$bra,";
	    print OUTPUT_COM "$bra,";
	    #system("git log --grep=$project --pretty=oneline -$output_num $branches[$p1] | git name-rev --tags --stdin >> $output");
	 
	    my $output_temp = "$base_tag/temp/$project/format_".$vendor_or_out."_temp.txt";
	    my $output_temp2 = "$base_tag/temp/$project/format".$vendor_or_out."_temp2.txt";
	    my $output_temp3 = "$base_tag/temp/$project/format".$vendor_or_out."_temp3.txt";
	    
	    if(-e "$base_tag/temp/$project") {
	    } else{	
		system("mkdir $base_tag/temp/$project");	
	    }

	    system("git log --grep=$project -$output_num --pretty=format:\"%h\" $branches[$p1] > $output_temp");
	    system("git log --grep=$project -$output_num --pretty=oneline $branches[$p1] | git name-rev --tags --stdin > $output_temp2");

	    # print extract result to tags.txt
	    open(OUTPUT_T, $output_temp) or die $!;
	    open(OUTPUT_T2, $output_temp2) or die $!;
	    my @t = <OUTPUT_T>;
	    my @t2 = <OUTPUT_T2>;
	    if($t[0] eq "") {
		print OUTPUT "\n";
		print OUTPUT_COM "\n";
            } else {
		 for(my $i = 0; $i < scalar(@t); $i++) {
			chomp $t[$i];  
			# tag
			my $tag_com = &getCompareEle($bra, 1);
			if($t2[$i] =~ /\((tags\/.+?)\)/) {
			    my $tag = $1;
			    $tag =~ s/tags\///;
			    $tag =~ s/[\^\~].*//;
			    if($tag_com ne $tag) {
			    	print OUTPUT_COM "$tag_com -> ";
			    }
			    print OUTPUT "$tag,";
			    print OUTPUT_COM "$tag,";
			} else {
			    if($tag_com ne "") {
			    	print OUTPUT_COM "$tag_com -> ";
			    }
			    print OUTPUT ",";
			    print OUTPUT_COM ",";
			}

			# apk version
			my $apk_com = &getCompareEle($bra, 2);
			if($t2[$i] =~ /\].*([vV]\d[\d\._]+)/) {
			    if($apk_com ne $1) {
			    	print OUTPUT_COM "$apk_com -> ";
			    }
			    print OUTPUT "$1,";
			    print OUTPUT_COM "$1,";	
			} else {
			    if($apk_com ne "") {
			    	print OUTPUT_COM "$apk_com -> ";
			    }
			    print OUTPUT ",";
			    print OUTPUT_COM ",";
			}

			# TT bugs
			if($t2[$i] =~ /\[TT.*?(\d.*?)\]/) {
			    my $bug = $1;
			    $bug =~ s/,/ & /g;
			    print OUTPUT "$bug,";
			    print OUTPUT_COM "$bug,";
			} else {
			    print OUTPUT ",";
			    print OUTPUT_COM ",";
			}	      
	 
			# Change Link
			system("git show $t[$i] | grep Reviewed-on > $output_temp3");
			open(OUTPUT_T3, $output_temp3) or die $!;
			my @cls = <OUTPUT_T3>;
			if($cls[0] ne "") {
				chomp $cls[0];
				$cls[0] =~ s/    Reviewed-on: //;
				print OUTPUT "$cls[0],";
				print OUTPUT_COM "$cls[0],";
			} else {
				print OUTPUT ",";
				print OUTPUT_COM ",";
			}				
			close OUTPUT_T3;
		    	
			# Message
			if($t2[$i] =~ /.*\](.*)/) {
			    my $mes = $1;
			    $mes =~ s/,/./g;
			    print OUTPUT "$mes,";
			    print OUTPUT_COM "$mes,";
			} else {
			    print OUTPUT ",";
			    print OUTPUT_COM ",";
			}
		
			# Commit Id
			print OUTPUT $t[$i].","; 
			print OUTPUT_COM $t[$i].",";

			#system("git show $t[$i] | grep Reviewed-by >> $output");
			print OUTPUT "\n";
			print OUTPUT_COM "\n";
		    }
	    }

	   

	    close OUTPUT_T;
	    close OUTPUT_T2;
	}

	print "\n\n**************** Finished ! \ntags.txt path is $output\n\n";
	close OUTPUT;
	close OUTPUT_COM;
	close OUTPUT_V;
	close OUTPUT_OLD;

}
