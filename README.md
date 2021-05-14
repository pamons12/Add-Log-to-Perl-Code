# Add-Log-to-Perl-Code
When run on a directory of perl files it adds code to pm or pl files that writes to a log file whenever a subroutine is called. Can also remove this code with correct command line options.

### Usage
1. Download or clone this repo
2. Have this file sit at the top of the directory you want to search through
3. Run using the command
'<perl addLogToPerl.pl [command line options]>'

-l (Required)\n\tA OR add -> Add log statements\n\tR OR rem OR remove -> Remove log statements
-d (Optional will use hardcoded if not given)\n\t Path to start directory ex: C:/path/to/start
-lp (Optional will use hardcoded if not given)\n\t Path to log file, will create file if does not exist ex: C:/path/to/log.txt
-c (optional)\n\tT OR true -> Enable console output showing what subroutines/files got log statements printed to"
