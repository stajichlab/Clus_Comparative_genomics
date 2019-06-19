#!/usr/bin/bash

FILE=lib/species.csv
mkdir -p pep CDS genome
FUNGIDBVERSION=43
FUNGIDBURL="https://fungidb.org/common/downloads/Current_Release/CaurisB8441"

ENSEMBLVERSION=43
ENSEMBLURL="ftp://ftp.ensemblgenomes.org/pub/release-43/"
NCBIURL="ftp://ftp.ncbi.nlm.nih.gov/genomes/all"
IFS=,
tail -n +2 $FILE | while read Species Strain Prefix Source Version Download
do
 outfile=$(echo "$Species $Strain" | sed 's/ /_/g')
 compress="1"
 if [ $Source == "FungiDB" ]; then
     echo "FungiDB download"
     url="${FUNGIDBURL}/data/fasta/FungiDB-${FUNGIDBVERSION}_${Prefix}"
     cdsurl=${url}_AnnotatedCDSs.fasta
     pepurl=${url}_AnnotatedProteins.fasta
     dnaurl=${url}_Genome.fasta
     gffurl="${FUNGIDBURL}/data/gff/FungiDB-${FUNGIDBVERSION}_${Prefix}.gff"
     # note - not compressed!
     echo "$cdsurl"
 elif [ $Source == "Ensembl" ]; then
     echo "Ensembl"
 elif [ $Source == "GenBank" ]; then
     
     pref=$(basename $Download)
     echo "NCBI download $pref"
     url="${NCBIURL}/${Download}/${pref}"
     cdsurl=${url}_cds_from_genomic.fna.gz
     pepurl=${url}_translated_cds.faa.gz
     dnaurl=${url}_genomic.fna.gz
     gffurl=${url}_genomic.gtf.gz
 fi
 
 echo "$cdsurl -> CDS/$outfile.cds.fasta"
done

