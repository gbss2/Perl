#!/usr/bin/perl
#==========================================
# LDGH Project
#==========================================
#
# (/u0254) Copyleft 2012, by LDGH and Contributors.
#
# 
# -----------------
# tHIERs g'nome, the slaughterscript
# -----------------
# GNU GPL 2012, by LDGH and Contributors.
#
# Original Author: Giordano Bruno Soares-Souza
# Contributor(s):
# Updated by:
#
# Command line: tHIERs.pl -i input_sdat -p input_pop -o output_file
# Dependencies: Perl Interpreter
# Description: Based on SDAT and POP file this script makes an input for R's Hierfstat library.
# The POP File needs a minimum of two columns with sample code in first column and populations labels in the second. 
# The number of columns in POP file specifies the hierarquical levels to be setted at the input file, at this script is possible to set 2-4 
# hierarquical levels (from deme to more hierarquical levels of individual agroupment). Notice that Hierfstat's manual didn't consider the
# individuals as a numbering level.
# Example of POP file:
#  Column 1		Column 2	Column 3		Column 4
# Sample_code	 deme		subpopulation	population
#
################################################################################
#use warnings;
print("\n\n####################################################################\n####################################################################\n\ntHIERs Script\n\n(\u0254) Copyleft 2012, by LDGH and Contributors. GNU GPL 2012\n\n####################################################################\n\n");
##############################	Getting parameters #############################

if ($#ARGV != 5)
{
	die "usage: tHIERs.pl -i input_sdat -p input_pop -o output_file\n";
}
while (scalar @ARGV > 0)
{
	$option = shift;

	if ($option eq "-o")
	{
		$out_file = shift;
	}
	elsif ($option eq "-i")
	{
		$input_file1 = shift;
	}
	elsif ($option eq "-p")
	{
		$input_file2 = shift;
	}
	else
	{
		die "usage: tHIERs.pl -i input_sdat -p input_pop -o output_file\n";
	}
}
############################# DATA READING - SDAT FILE ####################################

print("Reading SDAT input... \n");
open(INPUT1, "$input_file1") || die "Can't open file $input_file: $!\n";

$i = 0;
$j = 0;
my @matrix1 = ();

while (<INPUT1>)
{
	@split = split /\t+/;
	for($j=0; $j <= $#split; $j++)
	{
		$matrix1[$i][$j] = $split[$j];
		if ($i>0 && $j>0 && $matrix1[$i][$j] ne "NA")
		{
		$matrix1[$i][$j] =~ s/A/1/g;
        $matrix1[$i][$j] =~ s/C/2/g;
        $matrix1[$i][$j] =~ s/G/3/g;
        $matrix1[$i][$j] =~ s/T/4/g;
        $matrix1[$i][$j] =~ s/\+/5/g;
        $matrix1[$i][$j] =~ s/\-/6/g;
		}
		if ($split[$j] eq /\s+/ || $split[$j] eq "??")
		{
		$matrix1[$i][$j] = "NA";
		}
	}
	$i++;
}

# $split[$j] eq /\t/ ||

my $num_pol = $j-1;
my $num_ind = $i-1;

printf("num-pol = %i\n", $num_pol);
printf("num-ind = %i\n", $num_ind);

close(INPUT1);

################################ DATA READING - POP FILE #################################

print("Reading Pop File... \n");
open(INPUT2, "$input_file2") || die "Can't open file $input_file: $!\n";

$i = 0;
$j = 0;
my @matrix2 = ();
my $x = 0;
my $y = 0;
while (<INPUT2>)
{
	@split = split /\t+/;
	for($j=0; $j <= $#split; $j++)
	{
		$matrix2[$i][$j] = $split[$j];
                if ($j == 1)
					{
					$pops[$i] = $split[$j];
					}
                elsif ($j == 2)
					{
					$conts[$i] = $split[$j];
					}
	}
	$i++;
}

$num_levels = $j;
$num_individuals = $i;

printf("num-levels = %i\n", $num_levels);
printf("num-ind = %i\n", $num_individuals);

close(INPUT2);

############################## DATA PROCESSING ###############################

print("Processing Data... \n");

# Selecting Uniques

my @uniq_pops = ();
%seen = ();
foreach $pop (@pops) {
    $seen{$pop}++;
}
@uniq_pops = keys %seen;

my @uniq_conts = ();
%seen = ();
foreach $cont (@conts) {
    $seen{$cont}++;
}
@uniq_conts = keys %seen;
chomp(@uniq_conts);
#print for("@uniq_conts\n");
$num_pops = @uniq_pops;
$num_conts = @uniq_conts;

printf("num-pops = %i\n", $num_pops);
printf("num-continents = %i\n", $num_conts);


############################## DATA PRINTING #######################################

print("Printing Output...\n");

open(OUTPUTc, ">FileCorrespondance.txt") || die "Can't open file Correspondence File:$!\n";

for ($i=0; $i< $num_conts; $i++) {
	print OUTPUTc sprintf("%i %s\n", $i+1, $uniq_conts[$i]);
	}

for ($i=0; $i< $num_pops; $i++) {
	print OUTPUTc sprintf("%i %s\n", $i+1, $uniq_pops[$i]);
	}
close(OUTPUTc);

open(OUTPUT, ">$out_file") || die "Can't open file $out_file:$!\n";

for ($i=0; $i<= $num_ind; $i++)
{
	for ($j=0; $j<= $num_pol; $j++)
	{
		if ($j == 0 && $i == 0)
		{
		print OUTPUT "CON\tPOP";
		}
		
		if ($j == 0)
		{
#			 print OUTPUT sprintf("\t%s", $matrix1[$i][$j]);
			 for ($k=0; $k<= $num_individuals; $k++)
				{
				if ($matrix1[$i][0] eq $matrix2[$k][0]) 
					{
#					print OUTPUT sprintf("\t%s", $matrix2[$k][0]);
					$temp_cont = $matrix2[$k][2];
					chomp($temp_cont);
					$temp_pop = $matrix2[$k][1];
					for ($l=0; $l<= $num_conts; $l++)
						{
							if ($temp_cont eq $uniq_conts[$l])
							{	
								$temp = $l+1;
#								print OUTPUT sprintf("\t%s\t", $uniq_conts[$l]);
								print OUTPUT sprintf("%s", $temp);
							}	
						}
					$temp_pop = $matrix2[$k][1];
#					print OUTPUT sprintf("\t%s", $temp_pop);
					for ($l=0; $l<= $num_pops; $l++)
						{
							if ($temp_pop eq $uniq_pops[$l]) 
							{
								$temp = $l+1;
#								print OUTPUT sprintf("\t%s", $uniq_pops[$l]);
								print OUTPUT sprintf("\t%s", $temp);
							}	
						}
						#return (1);
					}
				}
		}
		if ($j > 0)
			{
				print OUTPUT sprintf("\t%s", $matrix1[$i][$j]);
			}
	}
#	print OUTPUT "\n";
}
print("Done! Check your output\n");

close(OUTPUT);
exit(0);