#Adds code to all the perl files in a directory 
#That when runs prints the subroutines name to a log file
#Log file is opened for appending so you must delete file if you want to clear it
#Will also remove this code by changing the $remAddFunc
#Code cannot have excess white space between the subname and { ex:
#WILL WORK
#sub subname{
#    
#}
#    OR
#sub subname
#{
#
#}
#WILL NOT WORK
#sub subname
#
#
#{
#
#}
use strict;
use warnings;
use File::Copy;
use File::Basename;
use Getopt::Long;

my $startDir = 'C:/Users/patma/OneDrive/Documents/Computer\ Science/PERL';
my $logFilePath = 'C:/Work/logFile.txt';

my $usageMessage = "Usage:
-l (Required)\n\tA OR add -> Add log statements\n\tR OR rem OR remove -> Remove log statements
-d (Optional will use hardcoded if not given)\n\t Path to start directory ex: C:/path/to/start
-lp (Optional will use hardcoded if not given)\n\t Path to log file, will create file if does not exist ex: C:/path/to/log.txt
-c (optional)\n\tT OR true -> Enable console output showing what subroutines/files got log statements printed to
-help\n\tShows command line options\n";

#Get command line options
my $remAddInput;
my $startDirInput;
my $logFileInput;
my $showConsole;
my $helpInput;
my $result = GetOptions('help' => \$helpInput,
                        'l=s' => \$remAddInput,
                        'd:s' => \$startDirInput,
                        'lp:s' => \$logFileInput,
                        'c:s' => \$showConsole
) or die $usageMessage;

if($helpInput){
    die $usageMessage;
}

#A = ADD = 1
#R = REMOVE = REM =0
my $remAddFunc;
if($remAddInput){
    $remAddInput = uc $remAddInput;
    if($remAddInput eq "A" || $remAddInput eq "ADD"){
        $remAddFunc = 1;
    }elsif($remAddInput eq "R" || $remAddInput eq "REMOVE" || $remAddInput eq "REM"){
        $remAddFunc = 0;
    }else{
        die "Incorrect usage of option l\n$usageMessage";
    }
}else{
    die "Option l requires an argument\n$usageMessage";
}

#Checks to see if a start directory path is given
if($startDirInput){
    $startDir=$startDirInput;
    print("Using start directory: $startDir\n")
}else{
    print("No argument for option d detected using hardcoded start directory: $startDir\n");
}

#Checks to see if a log file path is given
if($logFileInput){
    $logFilePath=$logFileInput;
    print("Log file path: $logFilePath\n")
}else{
    print("No argument for option lp detected using hardcoded log file path: $logFilePath\n");
}

#T = TRUE = 1 = on
#0 = off (Default)
my $showFunctionAndFileName=0;
if($showConsole){
    $showConsole = uc $showConsole;
    if($showConsole eq "T" || $showConsole eq "TRUE"){
        $showFunctionAndFileName=1;
        print("Console output enabled\n")
    }else{
        die "Incorrect usage of option c\n$usageMessage";
    }
}else{print("No argument for option c detected hiding console output")};

goThroughDir($startDir);

sub goThroughDir {
    my ($currentDir) = @_;
    my @files = <"$currentDir/*">;

    foreach my $file (@files) {
        if((substr $file, -3) =~ /.pl$/){
            if(basename($file) ne "addLogToPerl.pl"){
                dealWithPERL($file);
            }
        }elsif((substr $file, -3) =~ /.pm$/){
            dealWithPERL($file);
        }else{
            if(basename($file) =~ /(^.*[.]{1}.+)/){
                next;
            }
            goThroughDir($file);
        }
    }
}

sub dealWithPERL {
    my ($file) = @_;
    my $fileExtension = substr $file,-2;
    #Read file in
    open my $fileIn, "<", "$file" or die "Can't open $file: $!";
    #Create empty temp file
    open my $tempFile, ">", "temp.$fileExtension" or die "Can't open file: $!";

    my $prevLine = "";

    #Writing log messages
    if ($remAddFunc == 1){

        #Iterate each line of file
        while (<$fileIn>) {

            #{ on line after sub declaration
            if($_ =~ /^[{]+\s*$/ && $prevLine =~ /^sub[^{]+\n/){
                #Removes new line char
                $prevLine = substr $prevLine, 0, -1;

                if($showFunctionAndFileName){print "Log Statement added to $prevLine in file ",basename($file),"\n"};
                print $tempFile "{\t#Ran Through addLogToPM, DO NOT CHANGE ANYTHING BETWEEN THIS MESSAGE AND { OR REMOVE WILL FAIL\n\topen my \$logFile, \">>\", \"$logFilePath\" or die \"Can't open $logFilePath!\";\n\tprint \$logFile \"$prevLine in file: ",basename($file),"\\n\";\n\tclose \$logFile or die \"Can't close $logFilePath!\";\n";
            
            #{ on same line as sub declaration
            }elsif($_ =~ /^[^{]+$/ && $prevLine =~ /^sub[^\n]+{\n/ && $_ ne "\t#Ran Through addLogToPM, DO NOT CHANGE ANYTHING BETWEEN THIS MESSAGE AND { OR REMOVE WILL FAIL\n"){
                #Gets only the subname without the {
                if($prevLine =~ /(^sub[^{]+)/){$prevLine = $1;};

                if($showFunctionAndFileName){print "Log Statement added to $prevLine in file ",basename($file),"\n"};
                print $tempFile "\t#Ran Through addLogToPM, DO NOT CHANGE ANYTHING BETWEEN THIS MESSAGE AND { OR REMOVE WILL FAIL\n\topen my \$logFile, \">>\", \"$logFilePath\" or die \"Can't open $logFilePath!\";\n\tprint \$logFile \"$prevLine in file: ",basename($file),"\\n\";\n\tclose \$logFile or die \"Can't close $logFilePath!\";\n";
                if($_ =~ /^[^\n]/){
                    print $tempFile $_;
                }
            }else{
                print $tempFile $_;
            }
            $prevLine = $_;
        }
    }else{
        #Removing log statement
        my $skipLine = 0;
        while(<$fileIn>) {
            #Skips a certain number of lines to write to temp file
            if($skipLine>0){
                $skipLine-=1;
                next;

            #{ on line after sub declaration 
            }elsif($_ =~ /{\t#Ran Through addLogToPM, DO NOT CHANGE ANYTHING BETWEEN THIS MESSAGE AND { OR REMOVE WILL FAIL\n/ && $prevLine =~ /^sub[^{]+\n/){
                $skipLine = 3;
                print $tempFile "{\n";
                $prevLine = substr $prevLine, 0, -1;
                if($showFunctionAndFileName){print "Removed log statement from $prevLine in file ",basename($file),"\n"};
            
            #{ on same line as sub declaration
            }elsif($_ =~ /\t#Ran Through addLogToPM, DO NOT CHANGE ANYTHING BETWEEN THIS MESSAGE AND { OR REMOVE WILL FAIL\n/ && $prevLine =~ /^sub[^{]+{\n/){
                $skipLine = 3;
                
                #Gets only the subname without the {
                if($prevLine =~ /(^sub[^{]+)/){$prevLine = $1;};
                if($showFunctionAndFileName){print "Removed log statement from $prevLine in file ",basename($file),"\n"};

            }else{
                print $tempFile $_;
            }
            $prevLine = $_;
        }
    }
    close $tempFile or die "Can't close $tempFile: $!";
    close $fileIn or die "Can't close $file: $!";
    unlink $file or die "Could not delete file: $!";
    rename "temp.$fileExtension",$file or die "Could not rename file: $tempFile to $fileIn";
}