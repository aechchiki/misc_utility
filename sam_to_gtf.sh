# idea: map transcripts to reference genome (minimap2, sam; or asm, gtf) and convert the alignment to compare with the ref annotation (gtf)

# but first: sometimes the assemblies are reported in gtf format. need to convert to fasta before re-mapping to reference genome
/home/aechchik/bin/gffread transcripts.gtf -g ref-genome.fasta -w transcripts.fasta

# map transcripts in fasta format to the reference genome
minimap2 -ax splice ref-genome.fasta transcripts.fasta > alignment.sam

# keep uniquely mapped in sam
# remove unmapped & multimappings
cat alignment.sam  | grep -v ^@ | awk '{if($2!=4 && $2!=256 && $2!=272 && $2!=2048 && $2!=2064){print$0}}' > seen_once.sam
# verify that you removed all but forward/reverse -- should only display 0, 16 flags
cat seen_once.sam | cut -f2 | sort | uniq -c
# save header
cat alignment.sam | grep ^@ > sam.header
# merge header & forward/reverse mapped
cat sam.header seen_once.sam > seen_once_header.sam

# for later: extract junctions
/home/aechchik/software/minimap2/misc/paftools.js junceval -e /scratch/beegfs/monthly/aechchik/isoforms/ref/Drosophila_melanogaster.BDGP6.84.gtf seen_once_header.sam > junctions.txt

# convert sam to bam
module add UHTS/Analysis/samtools/1.3
samtools view -bS seen_once_header.sam > seen_once_header.bam

# sort bam
samtools sort -T . -o seen_once_header_sort.bam seen_once_header.bam

# convert to bed
/home/aechchik/bin/bamToBed -bed12 -i seen_once_header_sort.bam > seen_once_header_sort.bed

# convert to gff2
/home/ogustari/galaxy/tools/filters/bed_to_gff_converter.py seen_once_header_sort.bed seen_once_header_sort.gff2

# convert to cufflinks-like gtf
cat seen_once_header_sort.gff2 | sed 's/mRNA/transcript/g' | sed 's/transcript /transcript_id "/g' | sed 's/exon /transcript_id "/g' | sed 's/;/";/g' > seen_once_header_sort.gtf

# compare to ref
/home/aechchik/bin/cuffcompare -G seen_once_header_sort.gtf -r /scratch/beegfs/monthly/aechchik/isoforms/ref/Drosophila_melanogaster.BDGP6.39.gtf
