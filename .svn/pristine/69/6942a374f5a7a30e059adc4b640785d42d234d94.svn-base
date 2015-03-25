#!/usr/bin/perl
use strict; 
use XML::LibXML;
use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');

my $path_res = $ARGV[0];
my $path_new = $ARGV[1];

my $file = 'asus_strings.xml';
opendir(DIR_RES, $path_res) or die $!;
opendir(DIR_NEW, $path_new) or die $!;

my @dir_res = readdir(DIR_RES);
my @dir_new = readdir(DIR_NEW);

my $log_path = $path_res;
$log_path =~ s/\/res[\/]*$//;

my $log = $log_path.'/Log.txt';
open(LOG, ">:encoding(utf8)", $log) or die $!;   # fix the wide character

my $log_error = $log_path.'/Log_error.txt';
open(LOG_E, ">:encoding(utf8)", $log_error) or die $!;

my $i = 0;
foreach my $new(@dir_new) {
        if($new eq '.' or $new eq '..') {
            next;
        }

        foreach my $res(@dir_res) {
                if($new eq $res) {
                    $i++;
                    my $path_res_string = "$path_res/$res/$file";
                    my $path_new_string = "$path_new/$res/$file";
                    # print current file
                    print LOG $i.".\t".$new."\t".$res."\n";
                    print $i.".\t".$new."\t".$res."\n";

                    # check folder files
                    my $return_val = &checkFile($path_res_string);
                    if($return_val == 1) {
                        print "\n\n****** Please check the Log file for Errors: $log ******\n\n";
                        last;
                    }

                    # do work
                    else {
                        my %hash_res = &getRes($path_res_string);
                        my %hash_new = &getRes($path_new_string);
                        foreach my $k_new (keys %hash_new) {
                                my $f = 0;
                                foreach my $k_res (keys %hash_res) {
                                        # need to replace string
                                        if($k_new eq $k_res) {
                                            $f = 1;
                                            print "Do you want to replace\n\n";
                                            print "<string name=\"$k_new\">$hash_res{$k_new}</String>\tWith\t<string name=\"$k_new\">$hash_new{$k_new}</String>\n\n";
                                            print "Please input: y/yes to replace or no/n to do nothing): ";
                                            my $input = <STDIN>;
                                            chomp $input;       # important!!
                                            if($input eq 'y' or $input eq 'yes') {
                                              print LOG "Replace string <string name=\"$k_new\">$hash_res{$k_new}</String>\tWith\t<string name=\"$k_new\">$hash_new{$k_new}</String>\n\n";
                                              print "Replace string <string name=\"$k_new\">$hash_res{$k_new}</String>\tWith\t<string name=\"$k_new\">$hash_new{$k_new}</String>\n\n";

                                              &replaceRes($path_res_string, $k_new, $hash_new{$k_new});
                                              last;
                                            } else {
                                              print LOG "Do nothing: not replace existed string: <string name=\"$k_new\">$hash_res{$k_new}</String>\n\n";
                                              print "Do nothing: \n";
                                            }
                                        }
                                }

                                # add new string
                                if($f == 0) {
                                    print LOG "Add new string: <string name=\"$k_new\">$hash_new{$k_new}</String>\n\n";
                                    print "Add new string: <string name=\"$k_new\">$hash_new{$k_new}</String>\n\n";
                                    &insertRes($path_res_string, $k_new, $hash_new{$k_new});
                                }
                        }
                    }
                }
        }
}

print "\n\nLOG path: $log\n\nLOG_ERROR path: $log_error\n\n";

sub checkFile() {
    my $file = $_[0];
    my $flag = 0;

    # check wheather exist file in res folder
    if(-e $file) {
    } else {
      print LOG_E "Error 1: Can not find File: $file\n\n";
      print "Error 1: Can not find File: $file\n\n";

      $flag = 1;
      return $flag;
    }

    my $parser = XML::LibXML->new();
    my $struct = $parser->parse_file($file);
    my $rootel = $struct->getDocumentElement();

    my $elename = $rootel->getName();

    my @kids = $rootel->childNodes();

    # for check repeat
    my %hash = ();
    LINE: foreach (@kids) {
              my $k_name = $_->getName();
              my @attrs = $_->getAttributes();
              foreach my $att(@attrs) {
                     my $p_name = $att->getName();
                     my $p_value = $att->getValue();
                     if(exists $hash{$p_value}) {
                             print LOG_E "Error 2: Exist repeat property: <string $p_name=\"$p_value\"> in File: $file\n\n";
                             print "Error 2: Exist repeat property: <string $p_name=\"$p_value\"> in File: $file\n\n";

                             $flag = 1;
                             last LINE;
                     } else {
                             $hash{$p_value} = 1;

                             # Merge new string


                     }
              }
            #  print $_->childNodes(), "\n";
    }

    return $flag;
}

sub getRes() {
    my $file = $_[0];

    my $parser = XML::LibXML->new();
    my $struct = $parser->parse_file($file);
    my $rootel = $struct->getDocumentElement();

    my $elename = $rootel->getName();

    my @kids = $rootel->childNodes();

    my %hash = ();
    foreach (@kids) {
              my $k_name = $_->getName();
              my @attrs = $_->getAttributes();
              foreach my $att(@attrs) {
                     my $p_name = $att->getName();
                     my $p_value = $att->getValue();
                     $hash{$p_value} = $_->childNodes();
              }
    }

    return %hash;
}

sub replaceRes() {
    (my $file, my $pro, my $con_new) = @_;

    my $parser = XML::LibXML->new();
    my $struct = $parser->parse_file($file);
    my $rootel = $struct->getDocumentElement();

    my ($node) = $struct->findnodes('//resources/string[@name='."\"$pro\"".']/text()');
    $node->setData($con_new);

    open (FH, ">$file") or die $!;
    print FH $struct;
    close FH;
}

sub insertRes() {
    (my $file, my $pro, my $con_new) = @_;

    my $parser = XML::LibXML->new();
    $parser->keep_blanks(0);
    my $struct = $parser->parse_file($file);
    my $rootel = $struct->getDocumentElement();

    my $node_new = $struct->createElement('string');
    $node_new->setAttribute('name', $pro);
    $node_new->appendText($con_new);

    $rootel->addChild($node_new);

    open (FH, $file) or die $!;
    my $output = $struct->toFile($file, 1);       # format output
    print FH $output;
    close FH;
}

close DIR_RES;
close DIR_NEW;
close LOG;
close LOG_E;
