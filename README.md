# Automatically Adds Log Statements to Perl Code
When run on a directory of perl files the program adds code to pm or pl files that writes to a log file whenever a subroutine is called. Can also remove this code with the command line options.

### Usage
1. Download or clone this repo
2. Have this file sit at the top of the directory you want to search through
3. Run via the command line using: `perl addLogToPerl.pl (command line options)`

### Command Line options
Option | Arguments
-------|----------
-l (Required) | A OR add -> Add log statements <br>R OR rem OR remove -> Remove log statements
-d (Optional will use hardcoded if not given) | Path to start directory ex: C:/path/to/start
-lp (Optional will use hardcoded if not given) | Path to log file, will create file if does not exist ex: C:/path/to/log.txt
-c (optional) | T OR true -> Enable console output showing what subroutines/files got log statements added or removed
-help | shows command line options

### Future functionality
- Blacklist certain files from getting modified 
