#!/usr/bin/Rscript
args <- commandArgs(trailingOnly = FALSE)
script.basename <- dirname(sub('--file=', '', args[grep('--file=', args)]))
source(paste(script.basename, 'shared_functions.R',sep='/'))


genes=c("HADH","GLUD1","GCK","KCNJ11","INS","KLF11","BLK","SLC30A8",
	"HNF1A","HNF4A","ABCC8",
	"HNF1B","PDX1","PAX4","CEL")

#genes=c("NeuroD1")

#bams=c("2351-SJ-0001_S1.bam","2351-SJ-0002_S2.bam","2351-SJ-0003_S3.bam")
bams=paste("/export/astrakanfs/stefanj/data/amplicon_based_Jan2014/",
           c(paste("2351-SJ-000",1:9,"_S",1:9,sep=""), paste("2351-SJ-00",10:96,"_S",10:96,sep="")),
           ".bam",sep="")

PLOT=T

Y_MAX=2500  
line.stat.name = "% bp above 20X"

mean.gene.cvrg = list()  

for (gene in genes) {
  
  cat(paste("\nAnalyzing ", gene, " in...\n", sep=""))
 
  boxplot.data = c()
  figure.name=paste(gene,'-exon-coverage-stats.png',sep='')

  for (bam in bams) {
    
    cat(paste(bam,"\n")) 
        
    stats <- get.gene.coverage.stats(gene,bam)[['coverage.stats']]
    number.exons = ncol(stats)-1
    
    if (bam == bams[1]) {  # the first bam
      if (PLOT) {
	png(figure.name, width=(round(number.exons/30)+1)*1024, height=768)
      }
      par(mar=c(5,4,4,5))
      boxplot(as.list(rep(NA,number.exons)), xlab="Exons", ylim=c(1,Y_MAX), ylab="Mean coverage across samples", log="y")    
      #at = c(0:10)*(Y_MAX/10)
      at = 10**(c(0:10)*(log10(Y_MAX)/10))
      axis(4, at=at, labels=F, col='red', col.ticks='red', col.lab='red')
      mtext(side = 4, at=at, text=c(0:10)*10, col = "red", line = 1) 
      mtext(line.stat.name, 4, col='red', line=3)
    } 

    # extend/plot per-exome stats 
    boxplot.data = c(boxplot.data, unlist(stats['mean coverage',(1:number.exons)+1]))   # mean cvrg for all exons
    line.stats = unlist(stats[line.stat.name,(1:number.exons)+1])
    points(10**(line.stats*log10(Y_MAX)), type='l', lwd=2, col='red')  # line.stat.name statistic for all exons
    
    # extend data for all-genes-boxplot
    mean.gene.cvrg[[gene]] <- c(mean.gene.cvrg[[gene]], stats['mean coverage','entire gene'])
  }
  
  boxplot(matrix(boxplot.data, byrow=T, nc=number.exons), add=T)
  title(gene)
  dev.off()    
  
  cat(paste("Saved ", figure.name, "\n"))
}

png('all-genes-mean-coverage.png')
boxplot(mean.gene.cvrg, ylab='Mean coverage across samples', xlab="Gene")
dev.off()
cat("Saved all-genes-mean-coverage.png\n")

