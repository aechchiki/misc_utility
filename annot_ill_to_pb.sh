# import
module add SequenceAnalysis/SequenceAlignment/exonerate/2.2.0

# remove stop codons: kill err 365; ref. issue 3.5
sed -i 's/\.//g' ../Bl71/Bla_annot_final_refProteins.fa

# amphiencode proteins & target scaffolds
ln -s ../Bl71/Bla_annot_final_refProteins.fa .
ln -s ../PB_asm.fa .

# annotate
exonerate \
	--model protein2genome \
	--target PB_asm.fa\
	--query Bla_annot_final_refProteins.fa\
	--showcigar no\
	--showvulgar no\
	--bestn 1\
	--showquerygff no\
	--showtargetgff yes > amphio_exonerate.out

# can split 1/50 (25j; dee-serv04)
