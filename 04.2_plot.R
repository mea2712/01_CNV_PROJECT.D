rm(list=ls())
#--------------------------------------------------------------
args <-commandArgs(trailingOnly=TRUE)

for(i in 1:length(args)){
        assign(paste("args",i,sep=""),eval(parse(text=args[i])))
        cat(paste("args",i,sep=""),":\n")
        str(eval(parse(text=paste("args",i,sep=""))))
}
#------------------------------------------------------
start_time<-Sys.time()
#------------------------------------------------------
library("infercnv")
#------------------------------------
cat("LOADING DATA\n")

inm<-args1
infercnv_obj<-readRDS(inm)

cat(".. loaded:",inm,"\n")
cat("DONE",Sys.time(),"--------------------------------------------------------------------------------------\n")

cat("PLOTTING\n")
odir<-args2
ofnm<-args3
of<-args4
samp=args5

plot_cnv(infercnv_obj, title=samp ,out_dir=odir, obs_title="tumor_cells", ref_title="reference_cells", cluster_by_groups=TRUE,hclust_method="ward.D",output_filename=ofnm,output_format=of)

cat(".. plotted to:",paste(odir,ofnm,"__",samp,".",of,sep=""),"\n")
cat("DONE",Sys.time(),"--------------------------------------------------------------------------------------\n")
end_time<- Sys.time()
paste("USER:", Sys.getenv(c("SLURM_JOB_USER")))
paste("DATE:", as.POSIXct(Sys.time(),format="%Y-%m-%d %H:%M:%OS"))
end_time-start_time
cat("----------------------------------------------------------------------------------------------------------------------------------------------------------\n")
sessionInfo()	
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------
if(FALSE){
	args1<-"/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/02.0.2_run_infercnv_SS2_17_281__v1.0.1_0.4_1_101.d/15_denoiseHMMi6.rand_trees.NF_NA.SD_1.5.NL_FALSE.infercnv_obj"
	args2<-"/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/"
	args3<-"todel"
	args4<-"pdf"
	args5<-"SS2_17_281"
}







