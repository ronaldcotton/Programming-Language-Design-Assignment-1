# WSU Vancouver - CS355 - Programming Language Design
## Web Data - Assignment 2 - WSU Vancouver
## Perl Regular Expression/User Input/FileIO Exercise
### Abstract
This program processes a text file that has singleline and multiline comments, subsitutes user input for time and date tags, and uppercases single and multiline h tags.

### Requirements
Perl

### Testcase
Program tested on *Ubuntu 16.04* running *perl v5.22.1.*

### Executing
*The webscrapper which websrapped Wikipedia has already constructed the database, images were added later to the database*
```sh
    perl ass1.pl
```
or change execute permissions for ass1.pl and from the terminal:
```sh
    ./ass1.pl
```

**The program keeps the original file and generates an .output file and a .backup file (appends that to the filename, for example: testcase1.txt --> testcase1.txt.output and testcase1.txt.output).**

User is prompted for time, date, and the file to process (testcase1.txt).  Testcase1.txt contains strings that are processed with perl *regular expressions.*  Examples of processed files can be found in the **/output** folder.
