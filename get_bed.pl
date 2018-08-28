use warnings;
use strict;

die "Usage:\nperl $0 <gff> <outbed>\n" unless $#ARGV == 1;

my (%hash_mrna, %hash_exon);

open FILE, $ARGV[0] or die $!;
while (<FILE>) {
	chomp;
	my($chr,$class, $type, $end, $stand, $var) = (split(/\t/, $_))[0,1,2,4,6,8];
	$var=~/gene=(.+?)\;/;
	my $gene = $1;
	if ($class eq 'BestRefSeq' &&  $type eq 'mRNA' ) {
		my @temp = ($chr,$stand);
		$hash_mrna{$gene}{$end} = \@temp;
	}
	if ($class eq 'BestRefSeq' && $type eq 'CDS') {
		if (!exists $hash_exon{$gene}) { 
			$hash_exon{$gene} = $end;
		}
		if (exists $hash_exon{$gene} && $hash_exon{$gene} <= $end) {
			$hash_exon{$gene} = $end;
		}

	}
	
}
close FILE;

open OUT, ">$ARGV[1]" or die $!;

foreach my $k1 (keys %hash_mrna) {
	my ($k2, $value) = each %{$hash_mrna{$k1}};
	my @temp = @{$value};
	if (exists $hash_exon{$k1}) {
		if ($k2 > $hash_exon{$k1}) {
			print OUT "$temp[0]\t$hash_exon{$k1}\t$k2\t$k1\t0\t$temp[1]\n";
		}
	}

}
close OUT;
