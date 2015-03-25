#!/usr/bin/perl  For vendor/amax-prebuilt
use strict;

print "\n*********** Get Common Tag ************\n\n";

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

	my $output = "$base_tag/$project/tags_".$project."_".$vendor_or_out.".txt";
	my $output_verbose = "$base_tag/$project/tags_".$project."_".$vendor_or_out."_verbose.txt";

	system("rm $output $output_verbose");
	open(OUTPUT, ">>$output") or die $!;
	open(OUTPUT_V, ">>$output_verbose") or die $!;

	my $output_num = 5;
	# Do work!
	if($flag == 0) {
	   # User select All
	   if($input == $branch_count) {
	       for(my $i = 0; $i < $branch_count; $i++) {
		   &doWork($i, $branch_count);
	       }
	   }
	   # User select some branches
	   else {
	       foreach(@select_num) {
		   &doWork($_, $select_count);
	       }
	   }
	}

	close BRANCH;
	close MESSAGE;

	sub doWork {
	    (my $p1, my $p2) = @_;

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
	    
	    # 1. print tags to file tags.txt
	    print "\n******************** device: $devices[$p1]\tremote: $remotes[$p1]\tbranch: $p1. $branches[$p1] ******************\n\n";
	    print OUTPUT "******************** device: $devices[$p1]\tremote: $remotes[$p1]\tbranch: $p1. $branches[$p1] ******************\n\n";
	    system("git log --grep=$project --pretty=oneline -$output_num $branches[$p1] | git name-rev --tags --stdin >> $output");
	    print OUTPUT "\n";
	 
	    my $output_temp = "$base_tag/temp/$project/".$vendor_or_out."_temp.txt";
	    my $output_temp2 = "$base_tag/temp/$project/".$vendor_or_out."_temp2.txt";
	    
	    if(-e "$base_tag/temp/$project") {
	    } else{	
		system("mkdir $base_tag/temp/$project");	
	    }

	    system("git log --grep=$project -$output_num --pretty=format:\"%h\" $branches[$p1] > $output_temp");
	    system("git log --grep=$project -$output_num --pretty=oneline $branches[$p1] | git name-rev --tags --stdin > $output_temp2");

	    # 2. print tags to file tags_verbose.txt
	    print OUTPUT_V "******************** device: $devices[$p1]\tremote: $remotes[$p1]\tbranch: $p1. $branches[$p1] ******************\n\n";
	    system("git log --grep=$project --oneline --dec -$output_num $branches[$p1] >> $output_verbose");
	    print OUTPUT_V "\n\n";

	    # print extract result to tags.txt
	    open(OUTPUT_T, $output_temp) or die $!;
	    open(OUTPUT_T2, $output_temp2) or die $!;
	    my @t = <OUTPUT_T>;
	    my @t2 = <OUTPUT_T2>;
	    for(my $i = 0; $i < scalar(@t); $i++) {
		chomp $t[$i];
		print OUTPUT $t[$i]."\n";     
		system("git show $t[$i] | grep Reviewed-on >> $output");
	      
		# apk version
		if($t2[$i] =~ /\].*([vV][\d\.]+)/) {
		    print OUTPUT "    APK Version: $1\n";
		} else {
		    print OUTPUT "    APK Version: \n";
		}

		# TT bugs
		if($t2[$i] =~ /\[TT.*?(\d.*?)\]/) {
		    print OUTPUT "    TT Bugs: $1\n";
		} else {
		    print OUTPUT "    TT Bugs: \n";
		}
		
		# tag
		if($t2[$i] =~ /\((tags\/.+?)\)/) {
		    my $tag = $1;
		    $tag =~ s/\//: /;
		    $tag =~ s/[\^\~].*//;
		    print OUTPUT "    $tag\n";
		} else {
		    print OUTPUT "    tags: \n";
		}
	    
		system("git show $t[$i] | grep Reviewed-by >> $output");
		print OUTPUT "\n";
	    }  
	    print OUTPUT "\n";

	    close OUTPUT_T;
	    close OUTPUT_T2;
	}

	print "\n\n**************** Finished ! \ntags.txt path is $output\ntags_verbose.txt path is $output_verbose\n\n";
	close OUTPUT;
	close OUTPUT_V;

}
