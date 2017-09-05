#/usr/bin/perl -w
#==========================================
# GBSS Project
#==========================================
#
# (/u0254) Copyleft 2015, by GBSS.
#
# 
# -----------------
# splitArpintopops
# -----------------
# GNU GPL 2015, by GBSS and Contributors.
#
# Original Author: Giordano Bruno Soares-Souza
# Contributor(s): 
# Updated by: Giordano Bruno Soares-Souza
#
# Command line: perl splitarp.pl -i input.txt -pop popfile.txt -o output.txt 
# Dependencies: 
# Description: Transform the VCF file into a fasta file
#
################################################################################
use Getopt::Long;

GetOptions (
	"i=s"=>\$input,
	"pop=s"=>\$pop,
	"o=s"=>\$output,
)or die("Wrong parameters\n");

open(LOG,">log.txt") || die "can't open file: $!";

open(FILE,"$input") || die "can't open file: $!";

while (<FILE>){
	chomp; # remove newlines
	s/^\s+//;  # remove leading whitespace
	s/\s+$//; # remove trailing whitespace
	next unless length; # next rec unless anything left
	next if /[Profile]/;
	next if /NbSamples/;
	next if /DataType/;
	next if /GenotypicData/;
	next if /Locus/;
	next if /Missing/;
	next if /Gametic/;
	next if /Recessive/;
	next if /Data/;
	next if /Sample/;
	@split = split /\s+/;
	$seq{$split[0]} = $split[2];
#	print LOG $split[0]."\t".$split[1]."\t".$split[2]."\n";
 }
 
 close(FILE);
 
 open(FILE,"$pop") || die "can't open file: $!";
 
 while (<FILE>){
	@split = split /\s+/;
	$pop=$split[0];
	print LOG "\"".$pop."\"\n";
#	$country=$split[1];
#	print LOG $country."\n";
	$ID = $split[2];
#	print LOG $ID."\n";
#	push @{$lan{$pop}}, $ID;
	push @{$place{$pop}}, $ID;
 
 }
 
 close(FILE);
 
 open(OUT,">$output") || die "can't open file: $!";
 
 foreach $pop (sort keys %place){
#	print LOG $country."\n";
	print OUT "    SampleName = \"".$pop."\"\n";
    print OUT "    SampleSize = ".scalar(@{$place{$pop}})."\n";
	print OUT "    SampleData = {"."\n";
#	print scalar(@{$place{$pop}})."\n";
	foreach (@{$place{$pop}}){
	$indv = $_;
#	print LOG $indv."-1\t";
		foreach $id (keys %seq){
#			print LOG $indv."-1\t";
#			print LOG $id."-2\n";
#			print LOG $seq{$id}."\n";
#			print LOG $place{$country}."\n"."IF\n";
				if ($indv eq $id){
					print OUT "\t".$id."\t".$seq{$id}."\n";
				}
		}
	}
	print OUT "    }"."\n";
 }
 
 close(OUT);
 close(LOG);