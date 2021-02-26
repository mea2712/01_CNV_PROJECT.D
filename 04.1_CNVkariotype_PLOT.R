rm(list=ls())
#-------------------------------------------------------------------
source ("/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/ANNOT_f.R")
rm(list=ls()[! ls() %in% c("kp_f")])
#--------------------------------------------------------------
args <-commandArgs(trailingOnly=TRUE)

for(i in 1:length(args)){
        assign(paste("args",i,sep=""),eval(parse(text=args[i])))
        cat(paste("args",i,sep=""),":\n")
        str(eval(parse(text=paste("args",i,sep=""))))
}
args5<-c(549000000,0,83257441,93900000, 28400000,0,0,0,0,0,0,93900000)  ##### need to fix the submitter ####
#------------------------------------------------------
start_time<-Sys.time()
#--------------------------------------------------------------------
#------------------
#library(BiocManager)
#install("BSgenome.Hsapiens.UCSC.hg19")
library("dplyr")
library("karyoploteR")
library("ggplot2")
library("cowplot")
library("dplyr")
library("gridGraphics")
library("scales")
#------------------------------------
cat("LOADING DATA\n")

indir<-args1
samp<-args2

dat<- vector("list",length(samp))
for(i in 1:length(samp)) {
        datn<-paste(indir,samp[i],".RData",sep="")
        cat("Iteration ",i,"\nreading file: ",datn,"\n")
        load(datn)
	sigdat<-unique(cnvdat$All_sig_data_merged[,c("Prob","State","cnv_name","chr","start","end","cell","groups")])    
        dat[[i]]<-sigdat
        names(dat)[i]<-samp[i]
        rm(sigdat,cnvdat)       
}
 


cldat<- lapply(dat, function(x) { 
			x$State[x$State < 3]<- -1 ; x$State[x$State > 3]<- 1; 
			temp<- x %>% group_by(groups) %>% summarize(n_groups= n_distinct(cell))
			x<- x %>% group_by(chr,start,end,Prob,State,groups) %>% 
			    summarize(n_cells= n_distinct(cell)) %>% 
                            mutate(ProbXncell= Prob * n_cells,midpoint= ((end - start)/2)+start) %>%
			    right_join(temp,.,by=c("groups")) %>% 
			    mutate(ProbXpcell= Prob * (n_cells/n_groups)) %>%   
			    as.data.frame()
			return(x)
			rm(temp)    
			} )
comment(cldat)<-"chr=chromosome start=CNV_start end= CNV_end midpoint=CNV_midpoint Prob=CNV_significance(Bayesian posterior probability of the state) State=loss/gain groups=clusters n_groups=total number of cells in cluster  n_cells=total # cells in CNV  ProbXncell=Prob * n_cells  ProbXpcells=Prob * (n_cells/n_groups)"

cat("Done",Sys.time(),"--------------------------------------------------------------------------------------------------\n")
#------------------------------------------------------------------
cat("WRITING REFERENCE CNV DATA\n") # obtained from excel sheet
chr<- args3
start<-args4
end<-args5
state<-args6
#ref_CNV<-data.frame(ID=rep(samp,each=length(chr)),
#                    chr=rep(chr,length(samp)),
#                    start= start,
#                    end=end,
#		   state=rep(state,length(samp))) 

ref_ALL<-data.frame(ID=rep(samp, each=length(unique(unlist(sapply(dat, function(z) z$chr))))),
	            chr=unique(unlist(sapply(dat, function(z) z$chr))),
                    start=0,
                    end=0,
                    state= "9999" )
cat(".. ref_CNV\n")
#ref_CNV
cat("Done",Sys.time(),"----------------------------------------------------------------------------------------------------\n")

cat("PLOTING AND WRITING OUTPUT\n")

outD<-args7
outD1<-args8
scrpt<-args9
  
p1<-lapply(1:length(cldat), function(i) { NM<-names(cldat)[i];
					  DT<-cldat;
					  CHR<-paste("chr",1:22,sep="");
					  nm1<- paste(scrpt,"1__",NM,".png",sep="");
					  outnm<-paste(outD,nm1,sep="");
					  png(outnm)
					  p<-kp_f(samp_ID=NM,data=DT,reference= ref_ALL, skip= FALSE, plot_type="bar",chrom=CHR, mp="midpoint",y1="ProbXncell", scale=TRUE, colR=NULL);
					  dev.off()
					  cat(".. plot 1 bar karyotype for sample:\n.. ..",NM,"\n");
					  rm(NM);rm(DT);rm(CHR);rm(nm1);rm(outnm);
					  return(p)})
	
p2<- lapply(1:length(cldat), function(i) {NM<-names(cldat)[i];
					  DT<-cldat;
					  CHR<-paste("chr",1:22,sep="");
					  nm1<- paste(scrpt,"2__",NM,".png",sep="");
					  outnm<-paste(outD,nm1,sep="");
					  png(outnm)
					  p<-kp_f(samp_ID=NM,data=DT,reference= ref_ALL, skip= FALSE, plot_type="area",chrom=CHR, mp="midpoint",y1="ProbXncell",scale=TRUE, colR=NULL);
					  dev.off()
					  cat(".. plot 2 area karyotype for sample:\n.. ..",NM,"\n");
					  rm(NM);rm(DT);rm(CHR);rm(nm1);rm(outnm);
					  return(p)})

p3<-lapply(1:length(cldat), function(i) { NM<-names(cldat)[i];
					  DT<-cldat;
					  CHR<-paste("chr",1:22,sep="");
					  nm1<- paste(scrpt,"3__",NM,".png",sep="");
					  outnm<-paste(outD,nm1,sep="");
					  png(outnm)
					  p<-kp_f(samp_ID=NM,data=DT,reference= ref_ALL, skip= FALSE, plot_type="bar",chrom=CHR, mp="midpoint",y1="ProbXpcell", scale=FALSE, colR=NULL);
					  dev.off()
					  cat(".. plot 3 bar karyotype for sample:\n.. ..",NM,"\n");
					  rm(NM);rm(DT);rm(CHR);rm(nm1);rm(outnm);
					  return(p)})
	
p4<- lapply(1:length(cldat), function(i) {NM<-names(cldat)[i];
					  DT<-cldat;
					  CHR<-paste("chr",1:22,sep="");
					  nm1<- paste(scrpt,"4__",NM,".png",sep="");
					  outnm<-paste(outD,nm1,sep="");
					  png(outnm)
					  p<-kp_f(samp_ID=NM,data=DT,reference= ref_ALL, skip= FALSE, plot_type="area",chrom=CHR, mp="midpoint",y1="ProbXpcell",scale=FALSE, colR=NULL);
					  dev.off()
					  cat(".. plot 4 area karyotype for sample:\n.. ..",NM,"\n");
					  rm(NM);rm(DT);rm(CHR);rm(nm1);rm(outnm);
					  return(p)})


nm2<-paste(outD1, scrpt,".RData",sep="")
#save(cldat,ref_CNV,ref_ALL,p1,p2,p3,p4,file=nm2)
save(cldat,ref_ALL,p1,p2,p3,p4,file=nm2)
cat(".. Binary file in:\n.. ..",nm2,"\n")	
	
cat("DONE",Sys.time(),"-----------------------------------------------------------------------------------------------------------------------------------\n");
end_time<- Sys.time()
paste("USER:", Sys.getenv(c("SLURM_JOB_USER")))
paste("DATE:", as.POSIXct(Sys.time(),format="%Y-%m-%d %H:%M:%OS"))
end_time-start_time
cat("----------------------------------------------------------------------------------------------------------------------------------------------------------\n")
sessionInfo()	
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------
if(FALSE){
args1<-'/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/03_collect_results_infercnv__'
args2<-c("SS2_17_285","SS2_17_374","SS2_17_378")
args3<-c("chr1","chr11","chr17","chr2")
args4<-c(0,0,29400000,0,0,0,0,0,0,0,0,0)
#args5="c(549000000,83257441,93900000, 28400000,0,0,0,0,0,0,93900000)"  ### fix ###
args5<-NULL
args6<-c("L","L","G","G")
args7<-'/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/'
args8<-'/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/'
}








