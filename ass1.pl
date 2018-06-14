#!/usr/bin/perl

# Copyright (c) 2017 Ronald Cotton
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Ronald Cotton
#
# CS 355 spring 2017
# Assignment 1 (Due: 2/2/2017)
# This program processes a text file that has singleline and multiline
# comments, subsitutes user input for time and date tags, and uppercases
# single and multiline h tags.
#
# Program tested on Ubuntu 16.04 running perl v5.22.1
#
# ass1.pl can be executed two ways:
# 	perl ass1.pl
#
#   or change execute permissions for ass1.pl and run the following:
#		./ass1.pl
#
# The program keeps the original file and generates an .output file
# and a .backup file.

use strict;
use warnings;
use utf8;

my $ifn;		# input filename
my $ofn;		# output filename	
my $fnb;		# filename backup
my $date;		# date
my $time;		# time

# Prompt the user to enter the time, 
# which must be five-character strings “HH:MM”,
# where the hours range from 00–23 and the minutes from 00–59.
sub enterTime {
	while ( (print "Enter time in the format HH:MM where HH is 00-23 and MM is 00-59: "),(my $time = <STDIN>) ) {
		next if $time =~ /^\s*$/;  # blank or whitespace newline to reask question
		
		chomp $time;
		
		if ($time =~ /(^[0-1][0-9]:[0-5][0-9]$)|(^2[0-3]:[0-5][0-9]$)/) # from 00:00 - 23:59
			{ return $time; } # time processed correcly - remove newline
		print "ERROR: The time in not in the correct format - please reenter time\n";
		} # end if
} # end sub enterTime

# Prompt the user to enter the date, which must be ten-character 
# strings “YYYY-MMDD”.
# For example, 2016-04-01 represents April 1 2016, whereas 2016-04-31 
# is not a valid date. You should account for leap years by assume that
# Feb 29th is valid if the year is evenly divisible by four. E.g., 
# 2016-02-29 is a valid date but 2017-02-29 is invalid.

# January - 31 days
# February - 28 common year, 29 - leap year
# March - 31 days
# April - 30 days
# May - 30 days
# June - 30 days
# July - 31 days
# August - 31 days
# September - 30 days
# October - 31 days
# November - 30 days
# December - 31 days
 
sub enterDate {
	while ( (print "Enter valid date in the format YYYY-MM-DD: "),
			(my $date = <STDIN>) ) {
		next if $date =~ /^\s*$/;  # blank or whitespace (line-feed) to reask question
		
		chomp $date;
		
		if ($date =~ /
		(^[0-9]{4}-(01|03|07|08|10|12)-[0][1-9]$)|
		(^[0-9]{4}-(01|03|07|08|10|12)-[1-2][0-9]$)|
		(^[0-9]{4}-(01|03|07|08|10|12)-3[0-1]$)|
		(^[0-9]{4}-02-[0][1-9]$)|
		(^[0-9]{4}-02-[1-2][0-9]$)|
		(^[0-9]{4}-(04|05|06|09|11)-[0][1-9]$)|
		(^[0-9]{4}-(04|05|06|09|11)-[1-2][0-9]$)|
		(^[0-9]{4}-(04|05|06|09|11)-30$)
		/x) {
					my $year = substr $date, 0, 4;
					my $day = substr $date, 8, 2;
					
					if ( $year%4==0 ) { 
						# leap year
						return $date; # 29
					}
					else {
						# common year
						if ( $day<29 ) { 
							return $date; 
						}
					}
		} # end if
		print "ERROR: The date in not in the correct format - please reenter date\n"
	} # end while
} # end enterDate

# Prompt the user to enter a path for the text file to be processed.
#
# Note: The file must exist, must be non-zero size, is an ascii
# text file and is readable by uid/gid
sub enterFilename {
	while ( ( print "Enter valid path for text file to process: "),
			( $ifn = <STDIN> ) ) {
		chomp $ifn;
		if ( -s $ifn ) {
			if ( -T $ifn ) { 
				if ( -R $ifn ) { $fnb = $ifn.'.backup'; $ofn = $ifn.'.output'; return; }
				else { print ("ERROR: file is not readable by real uid/gid.\n"); }
			}
			else { print ("ERROR: File is not an ASCII or UTF-8 text file.\n"); }
		} else { print ("ERROR: File does not exist or is zero size\n"); }
	} # end while
} # end enterPath

# In the file, any line with “#” will have that char and all after it
# removed.  Save what is removed into <filename>.backup.
sub removeHashComments {
	my $infile_ref = shift;
	my @return = ();
	foreach (@{$infile_ref}) {
		if ( $_ =~ /^(.*)(#.*)$/ )
			{ appendBackupFile(\$2);
			  $_ = $1."\n"; }
		push @return,$_;
	}
	return @return;	
} # end removeHashComments

# Any lines between “=begin comment” and “=cut” will be removed 
# including those two lines. For example, all the following lines
# in the file will be removed.
#
# =begin comment
# This is a
# multiline
# comment
# =cut
sub removeEqualMultilineComment {
	my $infile_ref = shift;
	my @return = ();
	my $readlines = 1;
	foreach (@{$infile_ref}) {
		if ($_ =~ /^=begin comment.*$/) { $readlines = 0; }
		if ($readlines) { push @return, $_; } 
			else { appendBackupFile(\$_); }
		if ($_ =~ /^=cut.*$/) { $readlines = 1; }
	}
	return @return;
} # end removeEqualMultilineComment

# In the file, any string “*DATE*” will be replaced with the user
# input date.
sub replaceDate {
	my $infile_ref = shift;
	my @return = ();
	foreach (@{$infile_ref}) {
		if ($_ =~ /\*DATE\*/) {
			appendBackupFile(\$_);
			$_ =~ s/\*DATE\*/$date/g;
		}
		push @return, $_;
	}
	return @return;
} # end replaceDate

# Any string “*TIME*” will be replaced with the user input time.
sub replaceTime {
	my $infile_ref = shift;
	my @return = ();
	foreach (@{$infile_ref}) {
		if ($_ =~ /\*TIME\*/) {
			appendBackupFile(\$_);
			$_ =~ s/\*TIME\*/$time/g;
		}
		push @return, $_;
	}
	return @return;
} # end replaceTime

# Any string between “<h>” and “</h>” will be converted in all
# uppercase.
sub hTagsToUpper {
	my $infile_ref = shift;
	my @return = ();
	my $boldText=0;
	my $test;
	foreach (@{$infile_ref}) {
		if ($_ =~ /^(.*)<h>(.*)<\/h>(.*)$/) {
			appendBackupFile(\$_);
			my $upper = uc $2;
			$test = "$1$upper$3\n";
		} elsif ($_ =~ /^(.*)<h>(.*)$/) { # next two cases handle multiline <h> tags
			appendBackupFile(\$_);
			my $upper = uc $2;
			$test = "$1$upper\n";
			$boldText = 1;
		} elsif ($_ =~ /^(.*)<\/h>(.*)$/) {
			appendBackupFile(\$_);
			my $upper = uc $1;
			$test = "$upper$2\n";
			$boldText = 0;
		} elsif ($boldText == 1) { # is bold still on?
			appendBackupFile(\$_);
			$test = uc $_;
		}else { $test = $_; }
	push @return, $test;
	}
	return @return;
}

sub deleteFiles {
	# if the backup file already exists, delete it!
	if ( -f $fnb ) {
		unlink("$fnb");
	}
	if ( -f $ofn ) {
		unlink("$ofn");
	}
} # end truncateBackupFile

sub appendBackupFile {
	print FILE_BACKUP $_
} # end appendBackupFile

sub userInput {
	$time = enterTime;
	$date = enterDate;
	enterFilename;
} # end userInput

# Main Program
userInput;
deleteFiles;
open(FILE_IN, $ifn);
open(FILE_BACKUP, ">>".$fnb);
open(FILE_OUT, ">>".$ofn);

my @infile = <FILE_IN>;
my @outfile = removeHashComments(\@infile); # pass by reference
@outfile = removeEqualMultilineComment(\@outfile);
@outfile = replaceDate(\@outfile);
@outfile = replaceTime(\@outfile);
@outfile = hTagsToUpper(\@outfile);

 foreach (@outfile) { # write .output file
 	print FILE_OUT $_;
 }

close(FILE_OUT);
close(FILE_IN);
close(FILE_BACKUP);
