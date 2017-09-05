#!/usr/bin/perl
#==========================================
# LDGH Project
#==========================================
#
# (/u0254) Copyleft 2012, by LDGH and Contributors.
#
# 
# -----------------
# samplit.pl
# -----------------
# GNU GPL 2012, by LDGH and Contributors.
#
# Original Author: Giordano Bruno Soares-Souza
# Contributor(s):
# Updated by:
#
# Command line: samplit.pl -i <text file> or -d <directory> -n <optional: number of lines to be sampled>
# Dependencies: Perl Interpreter, GNU WC
# Description: Sample random lines
# 
# 
#
################################################################################
#use warnings;
#use Getopt::Long;

	my %rand = ();
	my $lock = 0;
	my $sampleLinesN = 0;

while (scalar @ARGV > 0)
{
	$option = shift;

	if ($option eq "-d")
	{
		$dirFiles = shift;
		$opt = 1;
	}
	elsif ($option eq "-i")
	{
		$inputFile = shift;
		$opt = 2;
	} 
	elsif ($option eq "-n")
	{
		$sampleLinesN = shift;
	}
	else
	{
		die "usage: samplIt.pl -d dirFiles OR samplIt.pl -i inputFile AND|OR -n\n";
	}
}

############################################## START PROGRAM   #######################################################

#&inputProcessing($inpuFile);

	if ($opt == 1){
	&dirProcessing($dirFiles);
	} elsif($opt == 2){
	&inputProcessing($inputFile);
	} 	


############################################ DIRECTORY INPUT ##########################################################
################################## DIRECTORY READING AND FILES PRE-PROCESING ##########################################
sub dirProcessing{
my @allfiles = ();
printf("Opening Dir %s\n",$dirFiles);
opendir(Dir, "$dirFiles") || die "Can't open dir $dirFiles: $!\n";
@allFiles= readdir(Dir);
closedir(Dir);
printf("Closed Dir %s\n",$dirFiles);

	@sortedAllFiles = sort { lc($a) cmp lc($b) } @allFiles;
	
	FILE: foreach(@sortedAllFiles){
	$inputFile = $_;
	
	if ($inputFile eq ".") { next; } 
	if ($inputFile eq "..") { next; }
	
	printf("Reading file %s\n", $_);

	if ($lock == 0) {
	# Count file lines
		chomp($inputFile);
		$fullPath = "$dirFiles"."$inputFile";
		my ($lineCount, $temp) = split(/\W+/,`wc -l $fullPath`);

	# Sample Lines
		if ($sampleLinesN != 0){
			&sampleLines($sampleLinesN,$lineCount);
		} else {
			$sampleLinesN = int(rand($lineCount));
			&sampleLines($sampleLinesN,$lineCount);
		}
	}

	
	open(INPUT, $fullPath) || {warn ("Can't open file $fullPath : $!\n"),  next FILE};
	printf("Opening Input %s\n", $inputFile);
	$outFile = "sampled_".$sampleLinesN."$inputFile";
	open(OUTPUT, '>',$outFile) || die "Can't open file $outFile: $!\n";
	printf("Opening Output %s\n", $outFile);

	&fileSampling(INPUT,OUTPUT);
		
	}
	$lock=1;
} # END DIR PROCESSING

################################################### FILE INPUT ######################################################
############################################### FILE PRE-PROCESSING  ################################################

sub inputProcessing{	
	
	if ($lock == 0) {
	# Count file lines

		chomp($inputFile);
#		my ($lineCount, $temp) = split(/\W+/,`wc -l $inputFile`);
		my $lineCount = 50000;

	# Sample Lines
		if ($option eq "-n"){
			&sampleLines($sampleLinesN,$lineCount);
		} else {
			$sampleLinesN = int(rand($lineCount));
			&sampleLines($sampleLinesN,$lineCount);
		}
	}

	open(INPUT, $inputFile) || {warn ("Can't open file $inputFile : $!\n"),  next FILE};
	printf("Opening Input %s\n", $inputFile);
	$outFile = "sampled_".$sampleLinesN."$inputFile";
	open(OUTPUT, '>',$outFile) || die "Can't open file $outFile: $!\n";
	printf("Opening Output %s\n", $outFile);

	&fileSampling(INPUT,OUTPUT);
		
} # END FILE PROCESSING

############################# RANDOM ROUTINES  ###############################################
sub sampleLines{
	
	$sln = $_[0];
	$ln = $_[1];
	$size = 0;
#	my %rand = ();
	printf("Number of lines to be sampled: %s\n", $sln);
	printf("Size of file (lines): %s\n", $ln);

	
	while($size<$sln){
	
#	my @rand = map { rand($ln) } ( 1..$sln );
#	my %rand = map { $_,1 } int(rand($ln));
	my $key = int(rand($ln));
	undef $rand{$key};
#	print for("$key\n");
	
	$size = keys(%rand);

	}
	
}

############################# FILE PROCESSING  ###############################################
sub fileSampling{		

my $i = 0;

	while (<INPUT>) {
			
			chomp($_);
			
			foreach my $key (sort (keys %rand)){
#			for($j=0; $j <= $#rand; $j++){
					
				if($i==$key){
					print OUTPUT sprintf("%s\n", $_);
					last;
				}

			}
			
			$i++;

	} # END OF WHILE
	
	close(OUTPUT);
	close(INPUT);

}

exit(0);
