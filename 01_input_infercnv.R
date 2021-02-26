rm(list=ls())
#----------------------------------------------------------
library("dplyr")
#-----------------------------------------------------------
source("/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/ANNOT_f.R")
rm(list=ls()[! ls() %in% c("rtrnClstrsPAGODARds","longTranscript","partcell")])
#--------------------------------------------------------------------
args<- commandArgs(trailingOnly=TRUE)

for(i in 1:length(args)){
        assign(paste("args",i,sep=""),eval(parse(text=args[i])))
        cat(paste("args",i,sep=""),":\n")
        str(eval(parse(text=paste("args",i,sep=""))))
}

##------------------------------------------------------------------
start_time<-Sys.time()
#--------------------------------------------------------------------
cat("LOADING DATA\n")
# RDS file with data
pagoda_rds <-args1
clus<- data.frame(t(rtrnClstrsPAGODARds (pagoda_rds)) )
cat(".. reading cluster information:",pagoda_rds,"\n")

# count data
count_nm<-args4
count_mat<-read.csv(count_nm)
rnm<- count_mat[,1]
count_mat<- count_mat[,-1]
rownames(count_mat)<- rnm
count_mat<- data.matrix(count_mat)
cat(".. reading count information:", args4, "\n")

# gene data
gene_nm<- args5
gene_loc<-read.table(file= gene_nm,header= FALSE, sep="\t")
gene_loc<- gene_loc[gene_loc[,3]=="transcript",c(9,1,4,5)]
gene_loc$gene<-sapply(gene_loc[,1], function(x) strsplit(strsplit(as.character(x),";")[[1]][3]," ")[[1]][2])
gene_loc<-gene_loc[,c(5,2,3,4)]
colnames(gene_loc)<- c("gene", "chr", "start", "end")
cat(".. reading gene information:",args5,"\n")

cat("Done",Sys.time(),"-----------------------------------------------------------------------------------------------------------\n")

cat("PROCESSING DATA\n")
cat(".. Cell Data\n")
## Annotate the cells as "normal"  
clus$Cells<- rownames(clus)
clus$Samples<- sapply(clus$Cells, function(x) strsplit(x,"\\.")[[1]][1])

cat(".. .. samples present:\n")
unique(clus$Samples)

cat(".. .. clusters present in all samples combined\n")
table(clus$groups)

norm_cl<-as.numeric(args2)
nms<-data.frame(groups= as.integer(names(args3)), tag= args3)
clus$tag<- nms$tag[match(clus$groups,nms$groups)]

clus$annotCLUS<- with(clus, ifelse(groups == norm_cl, paste("normal_", as.character(tag), sep=""), paste("malignant_", as.character(tag),sep="")))
	           
# Get annotation per sample
cellAnBySamp<- partcell(uniq_samples = unique(clus$Samples), clus = clus)

## Check how many cells in each cluster
cat(".. .. number of cells per cluster below. Clusters with only one cell will be removed\n.. samples order:\n.. ..",names(cellAnBySamp),"\n") 
min_num<-1
cellAnBySamp<-lapply(cellAnBySamp, function(x) {a<-x %>% count(groups);
                                                b<-a %>% filter(n==as.integer(min_num)) %>% select(groups);
                                                x<-x %>% filter(! groups %in% b$groups );
 				                print("clusters present:")
					        print(a);
					        print("remaining clusters:");
                                                print(x %>% count(groups))							                                
				                return(x);
                                                rm(a); rm(b); rm(x);
                                                })

# Remove samples with no normal cluster
cat(".. .. checking which samples have the normal reference present\n")
sampWithRef<-lapply(cellAnBySamp, function(x) {n<-x%>% filter(., groups %in% norm_cl) %>% count() %>% as.integer()
                                               if (n > 0) {return(x)} else { return(NA_character_)}})
sampWithRef<-sampWithRef[!is.na(sampWithRef)]
cat(".. .. .. samples with reference are:\n",names(sampWithRef),"\n")

## Get count data by sample
cat(".. Count data\n")

# For samples with normal cluster 
count_l<- lapply(sampWithRef, function(x) {idx <- unique(x$Cells);
                                           a<- count_mat[,colnames(count_mat) %in% idx];
                                           return(a);
                                           rm(a); rm(idx);
                                           })

## Gene location
cat(".. Gene data\n")
# Get clean annotation file, include only transcripts with the longest span
cat(".. .. getting longest spanning transcripts\n")
annot_clean<- longTranscript(gene_loc)	
# Sort file based on chr and starting position
cat(".. .. sorting based on chromosome and starting position\n")
idx<- sapply(annot_clean$chr, function(x) strsplit(as.character(x),"r")[[1]][2])
idx[idx == "X"] <- 23; idx[idx == "Y"] <- 24; idx[idx == "M"] <- 25
idx<- as.numeric(idx); annot_clean<- cbind(annot_clean, idx)
annot_clean<- annot_clean[order(annot_clean[,"idx"],annot_clean[,"start"]),-5]

cat("Done",Sys.time(),"-----------------------------------------------------------------------------------------------------\n")

cat("WRITING OUTPUT FILES\n")
outdir1<- args6
outdir2<- args7

nm1<-paste(outdir2,"01_input_infercnv.RData",sep="")
nm2<-paste(outdir1,"01_input_infercnv___CELLS-",sep="")
nm3<-paste(outdir1,"01_input_infercnv___COUNTS-",sep="")
nm4<-paste(outdir1,"01_input_infercnv___GENES",sep="")

comment(clus)<- paste('pagoda cluster information for the 11 NB samples labeled "SS2_17_...". Created by: ',Sys.getenv("SLURM_JOB_USER"), "on ", Sys.Date(),sep="")
comment(count_l)<- paste('count matrix for each NB sample. Created by: ',Sys.getenv("SLURM_JOB_USER"), "on ", Sys.Date(),sep="")
comment(sampWithRef)<- paste('samples containing the normal cluster. Kept clusters with > 1 cell. Created by: ',Sys.getenv("SLURM_JOB_USER"), "on ", Sys.Date(),sep="")
save(clus, count_l, sampWithRef, annot_clean, file=nm1)
cat(".. saving temp rdata:",nm1,"\n")

for (i in 1:length(sampWithRef)){
	write.table(sampWithRef[[i]][,c("Cells","annotCLUS")], file= paste(nm2,names(sampWithRef)[i],sep=""),sep="\t",row.names=FALSE,col.names=FALSE,quote=FALSE)
	cat(".. saving per sample CELL information: ",paste(nm2,names(sampWithRef)[i],sep=""),"\n")
}

for (i in 1:length(count_l)){
	write.table(count_l[[i]], file= paste(nm3,names(count_l)[i],sep=""),sep="\t",row.names=TRUE,col.names=TRUE,quote=FALSE)
	cat(".. saving per sample COUNT information: ",paste(nm3,names(sampWithRef)[i],sep=""),"\n")
}

write.table(annot_clean[-1,], file=nm4, sep="\t", row.names= FALSE, col.names= FALSE, quote=FALSE) 
cat(".. saving GENE information:",nm4,sep="\n")

cat("DONE",Sys.time(),"-----------------------------------------------------------------------------------------------------------------------------------\n");
end_time<- Sys.time()
paste("USER:", Sys.getenv(c("SLURM_JOB_USER")))
paste("DATE:", as.POSIXct(Sys.time(),format="%Y-%m-%d %H:%M:%OS"))
end_time-start_time
cat("----------------------------------------------------------------------------------------------------------------------------------------------------------\n")
sessionInfo()	

if(FALSE){
args1 <- args[1]   # /castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/allSmpls_app.rds
args2 <- args[2]   # 5 normal cluster
args3 <- args[3]   # c("1"="undifferentiated","2"="undifferentiated_CD133","3"="MSC","4"="endothelial","5"="immune","6"="NOR","7"="MYCNamp_neural","8"="undifferentiated_NOR")
args4 <- args[4]  # /castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/hg38.noIntrns.highQC.allGns.counts.htsq.clltyHQ.nuclei.cncr.csv
args5 <- args[5]  # /castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/hg38.genecodeV28Comp.ERCCeGFP.cfflinks.noIntrns.gnNms.biotyp.gtf
args6 <- args[6]   # /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/
args7 <- args[7]  # /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_temp/

}	

	
