#!/usr/bin/perl  For packages/apps/../out
use strict;

# Determine the output folder path.
opendir(DIR, "./") or die $!;
my @dir = readdir(DIR);

my $vendor_or_out = "vendor";
if(grep /^out$/, @dir) {
	$vendor_or_out = "out";
}
close DIR;  

my $dir_cur;
if($vendor_or_out eq "out") {
	my @project = ("AsusDeskClock", "ASUSAccount", "AsusSoundRecorder", "AsusFlashLight");
	my $dir = $ENV{'PWD'};
	foreach(@project) {
	    if($dir=~/$_/) {
	         $dir_cur = $_;
	         last;
	    }
	}
} else {
	if($ARGV[0] ne "") {
		$dir_cur = $ARGV[0];
	} else {
		my %project = ("clock"=>"AsusDeskClock", "asusaccount"=>"ASUSAccount", "soundrecorder"=>"AsusSoundRecorder", "flashlight"=>"AsusFlashLight");

		my $dir = $ENV{'PWD'};
		foreach(keys %project) {
		    if($dir=~/$_/) {
			 $dir_cur = $project{$_};
			 last;
		    }
		}
	}
}

print "\n**************** Your project is \"$dir_cur\"\n\n";

# Read branch file
my $base_origin = "/home/junzheng_zhang/Desktop/kim";	
my $base_folder = "$base_origin/$vendor_or_out";

open (BRANCH, "$base_folder/branches.csv") or die $!;
my @device_remote_branch = <BRANCH>;
my $branch_count = scalar(@device_remote_branch);

# Read file
open (MESSAGE, "$base_folder/$dir_cur/message.txt") or die $!; 
my @messages = <MESSAGE>;
chomp $messages[0];

# Welcome and require user input parameters.
my @devices = ();
my @remotes = ();
my @branches = ();
my @reviewers = ();
for(my $i = 0; $i < $branch_count; $i++) {
    chomp $device_remote_branch[$i];
    my @temp = split(",", $device_remote_branch[$i]);
    $devices[$i] = $temp[0];
    $remotes[$i] = $temp[1];
    $branches[$i] = $temp[2];
    $reviewers[$i] = $temp[3];
    print "$i\t$branches[$i]\t\t\t\[$devices[$i]\]\n";
}
print "$branch_count\tAll\n";
print "Please select the branch number(ex: 0,1...):";
my $input = <STDIN>;
chomp $input;

# Check user input
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

my $temp_pcl = "$base_origin/tags/push_changelink/temp_$dir_cur"."_".$vendor_or_out.".txt";
system("rm $temp_pcl");
open(TEMP, ">>$temp_pcl") or die $!;

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
close TMP;

# Get push change link
&getPushChangeLink();

sub doWork {
    (my $p1, my $p2) = @_;
    # checkout, reset and pull
    print "\n\n************************** Now at branch $p1. $branches[$p1], total branch count: $p2\n\n";
    print "\n\n************************** Checkout $branches[$p1] ***************************\n\n";
    system("git ch $branches[$p1]");
    print "\n\n************************** Reset ****************************\n\n";
    for(my $k = 0; $k < 3; $k++) {
	if($vendor_or_out eq "out") {
        	system("git reset --hard HEAD~1"); 
	} else {
        	system("git reset --hard HEAD~3"); 
	}
    }
    print "\n\n*************************** Pull ****************************\n\n";
    system("git p");
       
	if($vendor_or_out eq "out") {
		# copy file
		system("rm -rf out");
		system("cp -r $base_folder/$dir_cur/apk/* ./"); 
		system("rm Android.mk~");

		# staged
		system("git rm out/Android.mk");
		system("git add out/");
		system("git add Android.mk");
	} else {
		# copy file
		system("rm -rf $dir_cur/");
		system("cp -r $base_folder/$dir_cur/apk/* ./");
		system("rm Android.mk~ $dir_cur/Android.mk~");
	    
		# staged
		system("git add $dir_cur/*");
	}
	

	# commit
	print "\n\n*************************** Commit ***********************************\n\n";
	system("git commit -m \"[$devices[$p1]]$messages[0]\"");

	# push
	$reviewers[$p1] =~ s/&/--reviewer/g;
	print "\n\n**************************** Push git push $remotes[$p1] HEAD:refs/for/$branches[$p1] --receive-pack='git receive-pack --reviewer $reviewers[$p1]' ******************************\n\n";
	
	print TEMP "branch $p1: $branches[$p1]\tdevice: $devices[$p1]\tremote: $remotes[$p1]";
	if($messages[0] =~ /(\[.*\])\[([vV].*?)\]/) {
		print TEMP "\tAPK Version: $1 $2";
	}
	print TEMP "\n";	

	# 2>&1 | grep http | tee -a $temp_pcl
    	system("git push $remotes[$p1] HEAD:refs/for/$branches[$p1] --receive-pack='git receive-pack --reviewer $reviewers[$p1]' 2>&1 | tee -a $temp_pcl");  
}

sub getPushChangeLink {
	my $pcl = "$base_origin/tags/push_changelink/pcl_$dir_cur"."_".$vendor_or_out.".txt";
	open(TEMP_OPEN, $temp_pcl) or die $!;
	open(PCL, ">>$pcl") or die $!;

	while (<TEMP_OPEN>) {
		chomp $_;
		$_ =~s/\[K//;
		if(/device: /) {
			print PCL "$_\n";
		} elsif (/http/) {
			print PCL "\t$_\n\n";
		}
	}	
	
	print "\n\n********* The newest push change link path is: $pcl\n\n";
	close TEMP_OPEN;	
	close PCL;
}

