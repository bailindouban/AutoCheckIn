#!/usr/bin/perl
use strict;
use WWW::Mechanize;
use WWW::HtmlUnit;
use HTML::TableExtract qw(tree); 
use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');

# base path
my $path = "/home/junzheng_zhang/Desktop/kim/close_tt_bug/path/";
my $url_base = "http://tp-dpdtt-01/tmtrack/";
my $topicApp = "AMAX_4.4";

# Input Parameter
my $username = &inputSet('username', 'junzheng_zhang');
my $password = &inputSet('password', '123456');

my $project = &inputSet('project', 'DeskClock');
my $rd_manager = &inputSet('RD Manager', 'Junzheng_Zhang');
my $developer = &inputSet('Developer', 'Junzheng_Zhang');

sub inputSet() {
    (my $info, my $default) = @_;

    print "\nPlease input TT $info(default: $default): ";
    my $param = <STDIN>;
    chomp $param;
    if($param eq "") {
        $param = $default;
    }
    return $param;
}

print "\n<Operations>:\n\n\t1. Update Bug\n\t2. Assign To Developer\n\t3. Assign To Developer & Verify Bug Fix\n";
print "\t<Enter>\tOnly Check Bug\n\t<q>\tQuit\n\n";
print "Please Select (1, 2 or 3): ";
my $select = <STDIN>;
chomp $select;

if($select ne "q") {

my $mech = WWW::Mechanize->new(autocheck => 1);
$mech->credentials($username, $password);

my $webClient = WWW::HtmlUnit->new;
my $credentialsProvider = $webClient->getCredentialsProvider;                           
$credentialsProvider->addCredentials($username, $password); 


# Get all bug list by Firefox
my $url_tt = $url_base."tmtrack.dll?ReportPage&Template=reports%2Flist&TableId=1001&Target=Query&QueryName=-6&SolutionId=2&ShowSubLinks=1";
$mech->get($url_tt);
my $link = $mech->find_link(url_regex=>qr/Recno=-1/);
if($link ne "") {
    $url_tt = $link->url();
}

my $path_parse_tt = $path.'parse_tt.html';
my $page_all_tt = $webClient->getPage($url_base.$url_tt);
printFile($page_all_tt->asXml, $path_parse_tt);

my %hash = &getWebHash($path_parse_tt);
&printHash($path.'parse_tt.txt', %hash);

my $path_t = '/home/junzheng_zhang/Desktop/kim/tags/';
my @path_tags = ($path_t."$project/tags_format_".$project."_vendor_format.csv",
                 $path_t."$project/tags_format_".$project."_out_format.csv");

foreach my $path_tag(@path_tags) {
    print "\n***** $path_tag\n\n";
    my %hash_tt = &getTTCloseHash($path_tag, %hash);

    &printHash($path.'mapping_tt.txt', %hash_tt);

    my $num = 0;
    foreach my $key(keys %hash_tt) {
           if($hash_tt{$key} eq '1') {
               next;
           }
           my @p = split(",", $hash_tt{$key});
           my $tt_id = $key;
           my $tag = $p[1];
           my $apk = $p[2];
           my $cl = $p[3];
           my $device_web = $hash{$tt_id};
           $device_web =~ s/ &.*//;
           if($device_web eq $topicApp) {
               $cl .= " ($topicApp)";
               $tag .= " ($topicApp)";
           }

           if($tag eq "" or $apk eq "" or $cl eq "") {
               next;
           }

           $num++;
           print "$num.\t$tt_id\t$tag\t$apk\t$cl\n\n";

           # Get Url in List Page
           my $url_list = $url_base."tmtrack.dll?ReportPage&Template=reports%2Flist&incsub=1&keywords=$tt_id&options=0&searchtid=1001&solutionid=2&tableid=1001&target=QuickIdSearch";
           $mech->get($url_list);

           my $path_list = $path.'list_'.$key.'.html';
           $mech->save_content($path_list, binmode=>':encoding(utf8)');

           # Goto Detail Page
           my $url_detail = $mech->find_link(url_regex=>qr/RecordId=/)->url();
           $mech->get($url_detail);
           my $path_detail = $path.'detail_'.$key.'.html';
           $mech->save_content($path_detail, binmode=>':encoding(utf8)');

           if($select eq "1") {
                 print "Your Select Is: 1. Update Bug ********\n\n";
                 # Sumbit Update
                 &submitUpdate($mech, $path, $cl, $apk, $device_web);
           } elsif ($select eq "2") {
                 # Assign Bug
                 print "Your Select Is: 2. Assign To Developer ********\n\n";
                 if($mech->content() =~ /TransitionId.8/) {
                     print "******** Assign To Developer ********\n\n";
                     &assignToDeveloper($mech, $path, $device_web);
                 } else {
                     print "! Already Assigned To Developer ********\n\n";
                 }
           } elsif ($select eq "3") {
                 print "Your Select Is: 3. Assign to Manager & Verify Close Bug ********\n\n";
                 # Assign Bug
                 if($mech->content() =~ /TransitionId.8/) {
                     print "******** Assign To Developer ********\n\n";
                     &assignToDeveloper($mech, $path, $device_web);
                 } else {
                     print "! Already Assigned To Developer ********\n\n";
                 }

                 # Verify Bug
                 print "******** Verify Bug Fix ********\n\n";
                 &verifyBugFix($mech, $path, $cl, $apk, $tag, $device_web);
           } else {
                 print "! Error Select : Do nothing********\n\n";
           }
    }
}

}
sub submitForm() {
    (my $mech, my $form_button, my $path, my $path_submit, my %hash_fill) = @_;

    # Goto Form-Fill Page
    my $res = $mech->submit_form(
        form_name => 'ViewForm',
        button => $form_button
    );
    
    &printFile($res->content(), $path);

    # Break Assign Lock
    if($res->content() =~ /Break Lock/) {
        my $res_break_lock = $mech->submit_form(
            form_name => 'BreakLockForm',
            button => 'Break'
        );

        &printFile($res_break_lock->content(), $path);
    }

    # Submit Update
    $mech->form_name('TransitionForm');

    my %hash_select = ();
    open(PATH, $path) or die $!;
    my @path = <PATH>;
    close PATH;
    # Check repeat update
    my $flag = 1;
    if($form_button eq 'TransitionId.1') {
            foreach(@path) {
                   if(/id=\"F1112\".*(ChangeLink.*?)<.*?(APK Version.*?)<.*?Add your comment/) {
                       foreach my $key(keys %hash_fill) {
                            print $1."\n".$2."\n\n";
                            if($1."\n".$2 eq $hash_fill{$key}) {
                                print "***** Yep, Repeat Update - Do nothing\n\n";
                                $flag = 0;
                            }
                       }

                       last;
                   }
            }
    }

    if($flag) {
	    print "\n\n********** Submit Form \n\n"; 
	    foreach(@path) {
		   if(/name=\"(\w\d+?)\".*value=\"(\d+?)\".* selected/) {
		       $hash_select{$1} = $2;
		   }
	    }
	    foreach my $key(keys %hash_select) {
		   $mech->select($key, $hash_select{$key});
	    }

	    foreach my $key(keys %hash_fill) {
		   $mech->field($key, $hash_fill{$key}, 1);
	    }

	    my $res_submit = $mech->click('#TransitionForm_ok');
	    &printFile($res_submit->content(), $path_submit);
    }
}

# Verify Bug Fix
sub verifyBugFix() {
    (my $mech, my $path, my $cl, my $apk, my $tag) = @_;

    my %hash_fill = (
         'F233' => $developer,
         'F234' => $rd_manager,
         'H1112' => "ChangeLink: $cl\nAPK Version: $apk",
         'F317' => $tag
    );

    &submitForm($mech, 'TransitionId.19', $path.'verify.html', $path.'verify_submit.html', %hash_fill);
}

# Assign To Developer
sub assignToDeveloper() {
    (my $mech, my $path) = @_;

    my %hash_fill = (
         'F233' => $developer
    );

    &submitForm($mech, 'TransitionId.8', $path.'assign.html', $path.'assign_submit.html', %hash_fill);
}

# Update
sub submitUpdate() {
    (my $mech, my $path, my $cl, my $apk) = @_;

    my %hash_fill = (
         'H1112' => "ChangeLink: $cl\nAPK Version: $apk"
    );

    &submitForm($mech, 'TransitionId.1', $path.'update.html', $path.'update_submit.html', %hash_fill);
}

sub getTTCloseHash() {
     (my $path, my %hash) = @_;
      open(TAG, $path) or die $!;
      my @tag = <TAG>;
      shift @tag;
      shift @tag;
      my %hash_tt = ();
      foreach my $t(@tag) {
             chomp $t;
             my @ele = split(',', $t);
             $ele[3] =~ s/ & /&/g;
             $ele[3] =~ s/ /&/g;
             my @tt_id = split('&', $ele[3]);

             foreach my $id(@tt_id) {
                   $hash{$id} =~ s/ &.*//;
                   if($hash{$id} ne "" && $ele[0] =~ /$hash{$id}/) {
                        $hash_tt{$id} = "$ele[0],$ele[1],$ele[2],$ele[4]";
                   } elsif($hash_tt{$id} eq ""){
                        $hash_tt{$id} = 1;
                   }
             }
      }
      close TAG;
      return %hash_tt;
}

sub getWebHash() {
    (my $path_parse) = @_;

    # Extract table
    use HTML::TableExtract qw(tree); 
    my $te = HTML::TableExtract->new( attribs => {name => "ReportOutput"});
    $te->parse_file($path_parse);

    my %hash = ();
    my $value = "";
    foreach my $table($te->tables) {
        my $table_tree = $table->tree;
        my $t_line = $table_tree->as_HTML;

        if($t_line =~ /projName0"> TopicApp/ or $t_line =~ /projName0\"?> Application/) {
            $value = $topicApp;
        }
        if ($t_line =~ /projName0\"?> (\w+[\s\w\/\(\)-]*?) <\/span><\/td><\/tr>/) {
            if($value eq $topicApp) {
                $value .= " & ".$1;
            } else {
                $value = $1;
            }
        }

        my @all_tt = $t_line =~ /RecordId.*?> (\d+?) </g;
        foreach (@all_tt) {
            $hash{$_} = $value;
        }
    }

    return %hash;
}

sub printHash() {
    (my $path, my %hash) = @_;

    # delete old file
    if(-e $path) {
        unlink $path;
    };

    # sort by value
    foreach my $key ( sort { $hash{$a} cmp $hash{$b} } keys %hash ) {
        printFile2($key." => ".$hash{$key}."\n", $path);
    }
}

sub printFile() {
    (my $content, my $file) = @_;
     open(FH, '>:encoding(utf8)', $file) or die $!;
     print FH $content;
     close FH;
}

sub printFile2() {
    (my $content, my $file) = @_;
     open(FH, '>>:encoding(utf8)', $file) or die $!;
     print FH $content;
     close FH;
}
