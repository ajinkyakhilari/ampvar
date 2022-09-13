#!/bin/sh
#Variant callig script using Nanopolish
#MJK LAB
#CSIR_NCL
#

FASTQ=$1
FAST5=$2
REFERENCE=$3
MINLENGTH=$4
MAXLENGTH=$5
PLOIDY=$6
THREADS=$7
GENOME=$8

for NAME in barcode{01..96}
do
echo""
echo""
mkdir $NAME
cd $NAME
echo""
echo "Concatenating fastq files"
echo""
cat $FASTQ/$NAME/*.fastq > $NAME.fastq
echo""
echo "Length filtering"
echo""
NanoFilt -q 10 -l $MINLENGTH --maxlength $MAXLENGTH $NAME.fastq > $NAME.len.fastq
echo""
echo "Mapping files to reference"
echo""
minimap2 -ax map-ont -t $THREADS $REFERENCE $NAME.len.fastq | samtools sort -o reads.sorted.bam -T reads.tmp
samtools index reads.sorted.bam
echo""
echo "Indexing fastq files"
echo""
nanopolish index -d $FAST5/$NAME $NAME.len.fastq
echo""
echo "Variant calling"
echo""
nanopolish variants -r $NAME.len.fastq -b reads.sorted.bam -g $REFERENCE -t $THREADS --ploidy $PLOIDY -o $NAME.vcf
cd ..
done
echo "Thank You"
