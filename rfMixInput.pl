#==========================================
# GBSS Project
#==========================================
#
# (/u0254) Copyleft 2015, by GBSS and Contributors.
#
# 
# -----------------
# rfMixInput.pl
# -----------------
# GNU GPL 2016, by GBSS and Contributors.
#
# Original Author: Giordano Bruno Soares-Souza
# Contributor(s): 
# Updated by:
#
# Command line: rfMixInput.pl -haps <admx.haps> -sample <admx.sample> -ref_hap <ref.hap> -ref_sample <ref.sample> -ref_leg <ref.leg> -keep <inds_2_keep> -pop <pop_file> -map <genetic_map> -out <output files>
# Dependencies: 
# Description: Creates rFMix input from shapeit output
# Future development:
#	1) Cleaner design
# 	2) Warnings
#
################################################################################
#use PerlIO::gzip;

# if ($#ARGV != 9)
# {
	# die "usage: rfMixInput.pl -haps -sample -ref_hap -ref_sample -ref_leg -keep -pop -map -out \n";
# }

while (scalar @ARGV > 0)
{
	$option = shift;

	if ($option eq "-haps")
	{
		$haps = shift;
	}
	elsif ($option eq "-sample")
	{
		$sample = shift;
	}
	elsif ($option eq "-ref_hap")
	{
		$ref_hap = shift;
	}
	elsif ($option eq "-ref_sample")
	{
		$ref_sample = shift;
	}
	elsif ($option eq "-ref_leg")
	{
		$ref_leg = shift;
	}
	elsif ($option eq "-keep")
	{
		$keep = shift;
	}
	elsif ($option eq "-pop")
	{
		$pop = shift;
	}
	elsif ($option eq "-map")
	{
		$map = shift;
	}
	elsif ($option eq "-out")
	{
		$out = shift;
	}
	else
	{
		die "usage: rfMixInput.pl -haps -sample -ref_hap -ref_sample -ref_leg -keep -pop -map -out \n";
	}
}

sub openAdmxHaps{
	if ($haps =~ /.gz$/) {
#		open HAP "<:gzip", $haps || die "Can't open file $haps: $!\n";
		open(HAP, "gunzip -c $haps |") || die "Can't open file $haps: $!\n";
	} else {
		open (HAP, "$haps" ) || die "Can't open file $haps: $!\n";
	}
}

sub openAdmxSample{
	if ($sample =~ /.gz$/) {
#		open SAMPLE "<:gzip", $sample || die "Can't open file $sample: $!\n";
		open(SAMPLE, "gunzip -c $sample |") || die "Can't open file $sample: $!\n";
	} else {
		open (SAMPLE, "$sample" ) || die "Can't open file $sample: $!\n";
	}
}

sub openRefHap{
	if ($ref_hap =~ /.gz$/) {
#		open HAP_REF "<:gzip", $ref_hap || die "Can't open file $ref_hap: $!\n";
		open(HAP_REF, "gunzip -c $ref_hap |") || die "Can't open file $ref_hap: $!\n";
	} else {
		open (HAP_REF, "$ref_hap" ) || die "Can't open file $ref_hap: $!\n";
	}
}

sub openRefLeg{
	if ($ref_leg =~ /.gz$/) {
#		open LEG_REF "<:gzip", $ref_leg || die "Can't open file $ref_leg: $!\n";
		open(LEG_REF, "gunzip -c $ref_leg |") || die "Can't open file $ref_leg: $!\n";
	} else {
		open (LEG_REF, "$ref_leg" ) || die "Can't open file $ref_leg: $!\n";
	}
}

sub openRefSample{
	if ($ref_sample =~ /.gz$/) {
#		open SAMPLE_REF "<:gzip", $ref_sample || die "Can't open file $ref_sample: $!\n";
		open(SAMPLE_REF, "gunzip -c $ref_sample |") || die "Can't open file $ref_sample: $!\n";
	} else {
		open (SAMPLE_REF, "$ref_sample" ) || die "Can't open file $ref_sample: $!\n";
	}
}

sub openMap{
	open (MAP, "$map" ) || die "Can't open file $map: $!\n";
}

sub openKeep{
	open (KEEP, "$keep" ) || die "Can't open file $keep: $!\n";
}

sub openPop{
	open (POP, "$pop" ) || die "Can't open file $pop: $!\n";
}

#open (OUTAlleles, "$out.alleles" ) || die "Can't open file $out.alleles: $!\n";
#open (OUTClasses, "$out.classes" ) || die "Can't open file $out.classes: $!\n";
#open (OUTSNPLoc, "$out.snpLoc" ) || die "Can't open file $out.snpLoc: $!\n";

open(OUTAlleles, '>',"$out.alleles") || die "Can't open file $out.alleles: $!\n";
open(OUTClasses, '>',"$out.classes") || die "Can't open file $out.classes: $!\n";
open(OUTSNPLoc, '>',"$out.snpLoc") || die "Can't open file $out.snpLoc: $!\n";


# Select SNPs present on Admixed population
@keepId = "";
open (KEEP, "$keep" ) || die "Can't open file $keep: $!\n";
$i = 0;
while (<KEEP>) {
    chomp;
	$keepId[$i] = $_;
	$i++;
}
close(KEEP);
my $keepSize = $i;
my %keepId = map { $_ => 1 } @keepId;

@sampleA = "";

open (SAMPLE, "$sample" ) || die "Can't open file $sample: $!\n";
$i = 0;
while (<SAMPLE>) {
    chomp;
	@split = split /\s+/;
	if($i>1){
		$sampleA[$i-2] = $split[1];
		if(exists($keepId{$split[1]})){
			print OUTClasses sprintf("%s ", $split[1]);
		}
	}
	$i++;
}
close(SAMPLE);
my $sampleSize = $i;

@sampleR = "";
open (SAMPLE_REF, "$ref_sample" ) || die "Can't open file $ref_sample: $!\n";
$i = 0;
while (<SAMPLE_REF>) {
    chomp;
	@split = split /\s+/;
	if($i>1){
		$sampleR[$i] = $split[1];
		if(exists($keepId{$split[1]})){
			print OUTClasses sprintf("%s ", $split[1]);
		}
	}
	$i++;
}
close(SAMPLE_REF);
my $refSize = $i;

open (MAP, "$map" ) || die "Can't open file $map: $!\n";

%map = "";
$i=0;
while (<MAP>) {
    chomp;
	my ($pos,$combined,$cm) = split /\s+/;
	$map{$pos} = $cm;
}
close(MAP);

%map2 = "";
open(ADMIXPOS, "zcat $haps |" )  || die "Can't open file $haps: $!\n";
$i=0;
while (<ADMIXPOS>) {
    chomp;
	@split = split /\s+/;
	if(exists($map{$split[2]})){
			for($j=0; $j <= $#split; $j++){
				if($j==2){
					$map2{$split[2]} = 1;
					print OUTSNPLoc sprintf("%s\n", $map{$split[2]});
				}
				if($j>4){
					if(exists($keepId{$sampleA[$j-5]})){
						print OUTAlleles sprintf("%s", $split[$j]);
					}
				}
			}
		print OUTAlleles "\n";
	$i++;
	}
}
close(ADMIXPOS);

open(LEG_REF, "gunzip -c $ref_leg |") || die "Can't open file $ref_leg: $!\n";

$i = 0;
while (<LEG_REF>) {
    chomp;
	@split = split /\s+/;
	if($i>0){
		$leg[$i-1] = $split[1];
	}
	$i++;
}

close(LEG_REF);

open(HAP_REF, "zcat $ref_hap |" )  || die "Can't open file $ref_hap: $!\n";
$i=0;
while (<HAP_REF>) {
    chomp;
	@split = split /\s+/;
	if(exists($map2{$leg[$i]})){
		for($j=0; $j <= $#split; $j++){
			if(exists($keepId{$sampleR[$j]})){
				print OUTAlleles sprintf("%s", $split[$j]);
			}
		}
		print OUTAlleles "\n";
	}
}

close(OUTSNPLoc);
close(OUTAlleles);
close(OUTClasses);

