#!/usr/bin/perl
#==========================================
# GBSS Project
#==========================================
#
# (/u0254) Copyleft 2015, by GBSS.
#
# 
# -----------------
# NuclearPedigree
# -----------------
# GNU GPL 2015, by GBSS and Contributors.
#
# Original Author: Giordano Bruno Soares-Souza
# Contributor(s): 
# Updated by: Giordano Bruno Soares-Souza
#
# Command line: perl nuclearped.pl -i input
# Dependencies: 
# Description: Counts the number of nuclear families in a pedigree
#
################################################################################
use Getopt::Long;
use Data::Dumper;

#use feature "switch";

our ($input, $filter, $output, $pedigree);
our (%hash, %phenotype, %genotype, %dads, %moms, %indv);

#$filter = 0;

GetOptions (
	"input=s"=>\$input,
	"filter=s"=>\$filter,
	"pedigree=s"=>\$pedigree,
	"output=s"=>\$output,
)or die("Wrong parameters\n");

# Filter
# 1 = phenotype
# 2 = genotype
# 3 = phenotype and genotype
# Pedigree
# trios
# parentoffspring

# Open Input

open(INPUT, "$input") || die "Can't open file $input: $!\n";

# Data Reading

while (<INPUT>)
{
	@split = split /\s+/;

	if($split[7] != 0) {
		$phenotype{$split[0]}=1;
	} 
	if ($split[8] != 0) {
		$genotype{$split[0]}=1;
	}
	
	if($pedigree eq "trios"){
		if($split[2] == 0 || $split[3] == 0) { next; }
		if(exists $hash{$split[2]}{$split[3]}){
			push @{ $hash{$split[2]}{$split[3]} }, $split[0];
		} else {
			@{ $hash{$split[2]}{$split[3]} }= $split[0];
		}
	}
	if($pedigree eq "triosPed"){
		if($split[2] == 0 || $split[3] == 0) { next; }
		if(exists $hash{$split[1]}{$split[2]}{$split[3]}){
			push @{ $hash{$split[1]}{$split[2]}{$split[3]} }, $split[0];
		} else {
			@{ $hash{$split[1]}{$split[2]}{$split[3]} }= $split[0];
		}
	}
	if($pedigree eq "parentoffspring"){
		if($split[2] == 0 || $split[3] == 0) { next; }
		if(exists $dads{$split[2]}){
			push @{ $dads{$split[2]} }, $split[0];
		} else {
			@{ $dads{$split[2]}}= $split[0];
		}
		if(exists $moms{$split[3]}){
			push @{ $moms{$split[3]} }, $split[0];
		} else {
			@{ $moms{$split[3]}}= $split[0];
		}
	}

}

if($filter == 0){
$filterName = "No filter";
} elsif ($filter == 1){
$filterName = "Phenotype";
} elsif($filter == 2){
$filterName = "Genotype";
} elsif($filter == 3){
$filterName = "Phenotype-Genotype";
}


open (OUT, ">$output");
open (LOG , '>>', "nuclearped.log");
# Flow control
if($pedigree eq "trios"){
	print "Trios\n";
	trios();
}
if($pedigree eq "parentoffspring"){
	print "Parent Offspring\n";
	parentoffspring();
}
if($pedigree eq "triosPed"){
	print "Trios Ped\n";
	triosped();
}


# Data Printing

sub trios(){

$count = 0;
$fam = 0;

	foreach my $dad (sort keys %hash) {
	#	print OUT $dad."\t";
		if($filter == 1 && !exists $phenotype{$dad}) {next;}
		if($filter == 2 && !exists $genotype{$dad}) {next;}
		if(($filter == 3) && (!exists $phenotype{$dad} || !exists $genotype{$dad})) {next;}
		foreach my $mom (keys %{ $hash{$dad} }) {
			if($filter == 1 && !exists $phenotype{$mom}) {next;}
			if($filter == 2 && !exists $genotype{$mom}) {next;}
			if(($filter == 3) && (!exists $phenotype{$mom} || !exists $genotype{$mom})) {next;}
			
	#		print OUT $dad."\t".$mom."\t";
			$first = 0;
			foreach (@{ $hash{$dad}{$mom} }) {
				$ind = $_;
				if($filter == 1 && !exists $phenotype{$ind}) {next;}
				if($filter == 2 && !exists $genotype{$ind}) {next;}
				if(($filter == 3) && (!exists $phenotype{$ind} || !exists $genotype{$ind})) {next;}
				if($first == 0){
					print OUT $dad."\t".$mom."\t".$ind;
#					$count+=3;
					$first = 1;
					$fam++;
					if (exists $indv{$ind}) { 
					} else {
						$indv{$ind} = 0;
						$count++;
					}
					if (exists $indv{$mom}) { 
					} else {
						$indv{$mom} = 0;
						$count++;
					}
					if (exists $indv{$dad}) { } else {
						$indv{$dad} = 0;
						$count++;
					}
				} else {
					print OUT "\t".$ind;
#					$count++;
					if (exists $indv{$ind}) { 
					} else {
						$indv{$ind} = 0;
						$count++;
					}
				}
			}
			if ($first == 1) {print OUT "\n"};
			
		}
		
	#		$fam++;
	#		$count++;
	}
	#	$count++;
	my $size = keys %indv;
	print LOG "Filter = ".$filterName."\tIndividuals = ".$count."-".$size."\tNuclear families = ".$fam."\n";
}


sub parentoffspring(){

$count = 0;
$dadcount = 0;
$momcount = 0;
#$fam = 0;
	foreach my $dad (sort keys %dads) {
		if($filter == 1 && !exists $phenotype{$dad}) {next;}
		if($filter == 2 && !exists $genotype{$dad}) {next;}
		if(($filter == 3) && (!exists $phenotype{$dad} || !exists $genotype{$dad})) {next;}
		my $first = 0;
		foreach (@{ $dads{$dad} }){
			$ind = $_;
			if($filter == 1 && !exists $phenotype{$ind}) {next;}
			if($filter == 2 && !exists $genotype{$ind}) {next;}
			if(($filter == 3) && (!exists $phenotype{$ind} || !exists $genotype{$ind})) {next;}
				if($first == 0){
					print OUT $dad."\t".$ind;
#					$count++;
					$first = 1;
					$dadcount++;
					if(exists $sons{$ind}){
						$count++;
					} else {
						$sons{$ind}= 1;
						$count++;
					}
					if (exists $indv{$ind}) { 
					} else {
						$indv{$ind} = 0;
					}
					if (exists $indv{$dad}) { } else {
						$indv{$dad} = 0;
					}
				} else {
					print OUT "\t".$ind;
					if(exists $sons{$ind}){
#						$count++;
					} else {
						$sons{$ind}= 1;
						$count++;
					}
					if (exists $indv{$ind}) { 
					} else {
						$indv{$ind} = 0;
					}

				}
			
		}
		if ($first == 1) {print OUT "\n"};
	}
print LOG "There are ".$dadcount." dads with ".$count." sons in parent offspring families\n";

$countB = 0;

	foreach my $mom (sort keys %moms) {
		if($filter == 1 && !exists $phenotype{$mom}) {next;}
		if($filter == 2 && !exists $genotype{$mom}) {next;}
		if(($filter == 3) && (!exists $phenotype{$mom} || !exists $genotype{$mom})) {next;}
		my $first = 0;
		foreach (@{ $moms{$mom} }){
			$ind = $_;
			if($filter == 1 && !exists $phenotype{$ind}) {next;}
			if($filter == 2 && !exists $genotype{$ind}) {next;}
			if(($filter == 3) && (!exists $phenotype{$ind} || !exists $genotype{$ind})) {next;}
				if($first == 0){
					print OUT $mom."\t".$ind;
	#				$count++;
					$first = 1;
					$momcount++;
					if(exists $sons{$ind}){
						$countB++;
					} else {
						$sons{$ind}= 1;
						$count++;
						$countB++;
					}
					if (exists $indv{$mom}) { 
					} else {
						$indv{$mom} = 0;
					}
					if (exists $indv{$ind}) { } else {
						$indv{$ind} = 0;
					}
				} else {
					print OUT "\t".$ind;
					if(exists $sons{$ind}){
						$countB++;
					} else {
						$sons{$ind}= 1;
						$count++;
						$countB++;
					}
					if (exists $indv{$ind}) { 
					} else {
						$indv{$ind} = 0;
					}

				}			
		}
		if ($first == 1) {print OUT "\n"};
	}
my $parents = $momcount+$dadcount;
my $size = keys %indv;
print LOG "There are ".$momcount." moms with ".$countB." sons in parent-offspring families\n";
print LOG "Filter = ".$filterName."\tParents = ".$parents."\tSons = ".$count."\tUnique individuals ".$size." \n";
#$s1 = keys %dads;
#$s2 = keys %sons;
#print $s1."\n";
#print $s2."\n";
}

sub triosped(){

$count = 0;
$fam = 0;
$fsize = 0;
	foreach my $family(sort keys %hash) {
		$ped = 0;
		foreach my $dad (keys %{ $hash{$family} }) {
		#	print OUT $dad."\t";
			if($filter == 1 && !exists $phenotype{$dad}) {next;}
			if($filter == 2 && !exists $genotype{$dad}) {next;}
			if(($filter == 3) && (!exists $phenotype{$dad} || !exists $genotype{$dad})) {next;}
			foreach my $mom (keys %{ $hash{$family}{$dad} }) {
				if($filter == 1 && !exists $phenotype{$mom}) {next;}
				if($filter == 2 && !exists $genotype{$mom}) {next;}
				if(($filter == 3) && (!exists $phenotype{$mom} || !exists $genotype{$mom})) {next;}
				
		#		print OUT $dad."\t".$mom."\t";
				$first = 0;
				foreach (@{ $hash{$family}{$dad}{$mom} }) {
					$ind = $_;
					if($filter == 1 && !exists $phenotype{$ind}) {next;}
					if($filter == 2 && !exists $genotype{$ind}) {next;}
					if(($filter == 3) && (!exists $phenotype{$ind} || !exists $genotype{$ind})) {next;}
					if($first == 0){
						print OUT $dad."\t".$mom."\t".$ind;
	#					$count+=3;
						$first = 1;
						$ped = 1;
						$fam++;
						if (exists $indv{$ind}) { 
						} else {
							$indv{$ind} = 0;
							$count++;
						}
						if (exists $indv{$mom}) { 
						} else {
							$indv{$mom} = 0;
							$count++;
						}
						if (exists $indv{$dad}) { } else {
							$indv{$dad} = 0;
							$count++;
						}
					} else {
						print OUT "\t".$ind;
	#					$count++;
						if (exists $indv{$ind}) { 
						} else {
							$indv{$ind} = 0;
							$count++;
						}
					}
				}
				if ($first == 1) {print OUT "\n"};
				
			}
			
		#		$fam++;
		#		$count++;
		}
	#	$count++;
	print OUT "Family ".$family."-------------------------------------------------------------------\n";
	if($ped == 1){ $fsize++; }
	}
#	my $size = keys %indv;
#	my $fsize = keys %hash;
	print LOG "Filter = ".$filterName."\tIndividuals = ".$count."\tNuclear families = ".$fam."\tPedigrees = ".$fsize."\n";
}


close(INPUT);
close(OUT);
close(LOG);

# sub parentoffspring2(){

# $count = 0;
# $fam = 0;
# foreach my $parent (sort keys %hash) {
		# my $firstD = 0;
		# my $firstM = 0;
        # foreach (@{ $hash{$dad}{$mom} }) {
			# $ind = $_;
			# if($filter == 1 && !exists $phenotype{$ind}) {next;} else {
				# if(exists $phenotype{$dad}) {
					# if($first == 0){
						# print OUT $dad."\t".$ind;
# #						$count+=2;
# #						$first = 1;
# #						$fam++;
					# } else {
						# print OUT "\t".$ind;
# #						$count++;
					# }
				
				# }
			
			
			# }
			# if($filter == 2 && !exists $genotype{$ind}) {next;}
			# if($filter == 3 && exists $phenotype{$ind} && exists $genotype{$ind}) {} else {next;}
				# if($first == 0){
					# print OUT $dad."\t".$mom."\t".$ind;
					# $count+=3;
					# $first = 1;
					# $fam++;
				# } else {
					# print OUT "\t".$ind;
					# $count++;
				# }
	  		# if()
		# }
		# if ($first == 1) {print OUT "\n"};
# #		$fam++;
# #		$count++;
	# }
# #	$count++;
# }
# print "There are ".$count." individuals in ".$fam." nuclear families\n";
# }
