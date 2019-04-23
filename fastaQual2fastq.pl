#!/usr/bin/perl
# 
# Original code (kmcarr): http://seqanswers.com/forums/showthread.php?t=2775
# Patched by drio
# TS added an adiditonal fix on line 43
#
use warnings;
use strict;
use Data::Dumper;
use File::Basename;

my $inFasta = $ARGV[0];
my $baseName = basename($inFasta, qw/.fasta .fna/);
my $inQual = $baseName . ".qual";
my $outFastq = $baseName . ".fastq";

my %seqs;

$/ = ">";

open (FASTA, "<$inFasta");
my $junk = (<FASTA>);

while (my $frecord = <FASTA>) {
	chomp $frecord;
	my ($fdef, @seqLines) = split /\n/, $frecord;
	my $seq = join '', @seqLines;
	$seqs{$fdef} = $seq;
}

close FASTA;

open (QUAL, "<$inQual");
$junk = (<QUAL>);
open (FASTQ, ">$outFastq");

while (my $qrecord = <QUAL>) {
	chomp $qrecord;
	my ($qdef, @qualLines) = split /\n/, $qrecord;
	my $qualString = join ' ', @qualLines;
	chomp $qualString;
	$qualString =~ s/\s+/ /g; # this is in case there are multiple spaces, it will substitute by one space only
	$qualString =~ s/^\s+|\s+$//g; # TS ADDED: remove white space on left and right of the quality string to avoid print warning 
	my @quals = split / /, $qualString;
	#print "@quals\n"; # printing the array helped me troubleshoot this issue
	print FASTQ "@","$qdef\n";
	print FASTQ "$seqs{$qdef}\n";
	print FASTQ "+\n";
	foreach my $qual (@quals) {
		print FASTQ chr($qual + 33);
	}
	print FASTQ "\n";
}

close QUAL;
close FASTQ;