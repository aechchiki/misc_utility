library(rtracklayer)
library(GenomicRanges)
gtf = import.gff("file.gtf")
grl = split(gtf, gtf$gene_id)
grl = endoapply(grl, function(x) {
    foo = x[1]
    foo$type = 'gene'
    start(foo) = min(start(x))
    end(foo) = max(end(x))
    return(c(foo, x))
    })
gr = unlist(gr)
