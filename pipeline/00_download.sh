#!/usr/bin/bash

FILE=lib/species.csv
mkdir -p pep CDS genome
FUNGIDBVERSION=43
FUNGIDBURL="https://fungidb.org/common/downloads/Current_Release"

ENSEMBLVERSION=43
ENSEMBLURL="ftp://ftp.ensemblgenomes.org/pub/release-43/fungi"
NCBIURL="ftp://ftp.ncbi.nlm.nih.gov/genomes/all"
IFS=,

tail -n +2 $FILE | while read Species Strain Prefix Source Version ExtraPref Download
do
 outfile=$(echo "$Species $Strain" | sed 's/ /_/g')
 compress=1
 if [ $Source == "FungiDB" ]; then
     echo "FungiDB download"
     url="${FUNGIDBURL}/${Prefix}/fasta/data/FungiDB-${FUNGIDBVERSION}_${Prefix}"
     cdsurl=${url}_AnnotatedCDSs.fasta
     pepurl=${url}_AnnotatedProteins.fasta
     dnaurl=${url}_Genome.fasta
     gffurl="${FUNGIDBURL}/${Prefix}/gff/data/FungiDB-${FUNGIDBVERSION}_${Prefix}.gff"
     # note - not compressed!
     f=CDS/$outfile.cds.fasta
     if [ ! -s $f ]; then
	 curl -o $f $cdsurl
     fi
     f=pep/$outfile.aa.fasta
     if [ ! -s $f ]; then
	 curl -o $f $pepurl
	 # fix name so that it is gene locus as ID
	 perl -i -p -e 's/>(\S+)-(p\d+)/>$1 $2/' $f
     fi
     f=genome/$outfile.dna.fasta
     if [ ! -s $f ]; then
	 curl -o $f $dnaurl
     fi
     f=genome/$outfile.gff
     if [ ! -s $f ]; then
	 curl -o $f $gffurl
     fi

 elif [ $Source == "Ensembl" ]; then
     echo "Ensembl"
     pref=$(basename $Download | perl -p -e 's/^(\S)/\U$1/').$ExtraPref
     
     url="${ENSEMBLURL}/fasta/$Download"
     dnaurl="${url}/dna/$pref.dna.toplevel.fa.gz"
     cdsurl="${url}/cds/${pref}.cds.all.fa.gz"
     pepurl="${url}/pep/${pref}.pep.all.fa.gz"
     gffurl="${ENSEMBLURL}/gtf/$Download/${pref}.${ENSEMBLVERSION}.gtf.gz"

     f=CDS/$outfile.cds.fasta
     if [ ! -s $f ]; then
	 curl -o $f.gz $cdsurl
	 pigz -d $f.gz
	 perl -i -p -e 's/^>(\S+)\s+(\S+\s+\S+)\s+gene:(\S+)/>$3 $1 $2/' $f
     fi

     f=pep/$outfile.aa.fasta
     if [ ! -s $f ]; then
	 curl -o $f.gz $pepurl
	 pigz -d $f.gz
	 perl -i -p -e 's/^>(\S+)\s+(\S+\s+\S+)\s+gene:(\S+)/>$3 $1 $2/' $f
     fi
     f=genome/$outfile.dna.fasta
     if [ ! -s $f ]; then
	 curl -o $f.gz $dnaurl
	 pigz -d $f.gz
     fi
     f=genome/$outfile.gtf
     if [ ! -s $f ]; then
	 curl -o $f.gz $gffurl
	 pigz -d $f.gz
     fi
     
 elif [ $Source == "GenBank" ]; then     
     pref=$(basename $Download)
     echo "NCBI download $pref"

     url="${NCBIURL}/${Download}/${pref}"
     cdsurl=${url}_cds_from_genomic.fna.gz
     pepurl=${url}_translated_cds.faa.gz
     dnaurl=${url}_genomic.fna.gz
     gffurl=${url}_genomic.gtf.gz

     f=CDS/$outfile.cds.fasta
     if [ ! -s $f ]; then
	 curl -o $f.gz $cdsurl
	 pigz -d $f.gz
	 perl -i -p -e 's/>(\S+)\s+\[locus_tag=([^\]]+)\]/>$2 $1/' $f
     fi

     f=pep/$outfile.aa.fasta
     if [ ! -s $f ]; then
	 curl -o $f.gz $pepurl
	 pigz -d $f.gz
	 perl -i -p -e 's/>(\S+)\s+\[locus_tag=([^\]]+)\]/>$2 $1/' $f
     fi
     f=genome/$outfile.dna.fasta
     if [ ! -s $f ]; then
	 curl -o $f.gz $dnaurl
	 pigz -d $f.gz
     fi
     f=genome/$outfile.gtf
     if [ ! -s $f ]; then
	 curl -o $f.gz $gffurl
	 pigz -d $f.gz
     fi
 else
     echo "skipping $Species - unknown $Source"
     continue
 fi     
 
done

