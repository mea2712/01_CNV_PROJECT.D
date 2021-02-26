rm(list=ls())
#-------------------------------------------------------------------
source ("/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/ANNOT_f.R")
rm(list=ls()[! ls() %in% c("getCNVdat2","rtrnClstrsPAGODARds")])
#--------------------------------------------------------------
args <-commandArgs(trailingOnly=TRUE)

for(i in 1:length(args)){
        assign(paste("args",i,sep=""),eval(parse(text=args[i])))
        cat(paste("args",i,sep=""),":\n")
        str(eval(parse(text=paste("args",i,sep=""))))
}
#------------------------------------------------------
start_time<-Sys.time()
#--------------------------------------------------------------------
library("dplyr")
#----------------------------------------------
cat("LOADING AND PROCESSING DATA\n")

## Directories where infercnv and pagoda rds results are
wd<- args1
rds<-args2
ref<-args3

## Get all data from infercnv
cat(".. Getting data from infercnv\n")
cutoff<-0.1
cnvdat<- getCNVdat2(WD = wd, BayesMaxPNorm= cutoff, pagoda_rds= rds, reference= ref)

## Get significant CNV without cell assigning
cat(".. Filtering cnvs\n")
sigdat<-unique(cnvdat$All_sig_data_merged[,c("Prob","State","cnv_name","chr","start","end","chrRegion","number_of_genes","genes","groups")])	

cat("Done",Sys.time(),"----------------------------------------------------------------------------------------------------------------------\n")

cat("WRITING OUTPUT\n")

outD<-args4
samp<-args5
scrpt<-args6

nm1<- paste(outD,scrpt,samp,".RData",sep="")
save(cnvdat,sigdat, file = nm1)
cat(".. saving",nm1,"\n")

cat("DONE",Sys.time(),"-----------------------------------------------------------------------------------------------------------------------------------\n");
end_time<- Sys.time()
paste("USER:", Sys.getenv(c("SLURM_JOB_USER")))
paste("DATE:", as.POSIXct(Sys.time(),format="%Y-%m-%d %H:%M:%OS"))
end_time-start_time
cat("----------------------------------------------------------------------------------------------------------------------------------------------------------\n")
sessionInfo()	

