rm(list=ls())
#---------------------
source("/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/ANNOT_f.R")
#------------------------------------------------------------------------
library("cowplot")
library("ggplot2")
library("dplyr")
library("tidyr")
#----------------------------------------------------------------------------
start_time<-Sys.time()
#---------------------
cat("READING SYSTEM VARIABLES\n")
args <-commandArgs(trailingOnly=TRUE)

for(i in 1:length(args)){
        assign(paste("args",i,sep=""),eval(parse(text=args[i])))
        cat(paste("args",i,sep=""),":\n")
        str(eval(parse(text=paste("args",i,sep=""))))
}

cat("Done",Sys.time(),"----------------------------------------------------------------------------------------------------------\n")
cat("LOADING DATA\n")
indir<-args1
samp<-args2
clid<-args4
col_key<-args11
reg<-args12

cat(".. Reading inferCNV files of cells with significant CNV\n")
dat<- vector("list",length(samp))
for(i in 1:length(samp)) {
        #datn<-paste(indir,samp[i],".RData",sep="")
        datn<-indir[i]
        cat(".. .. Iteration ",i,"\n.. .. reading file: ",datn,"\n")
        load(datn)
        dat[[i]]<-cnvdat$All_sig_data_merged
        dat[[i]]$cluster_tags<-clid[dat[[i]]$groups]
        dat[[i]]$color_key<-col_key[dat[[i]]$groups]
        names(dat)[i]<-samp[i]
        rm(sigdat,cnvdat) 
}

pagoda_rds<-args5
pagoda<-rtrnClstrsPAGODARds(pagoda_rds)
pagoda<-data.frame(cell=colnames(pagoda),groups=pagoda["groups",])
pagoda$sample<-sapply(pagoda$cell, function(x) {strsplit(x=x,split=".",fixed=TRUE)[[1]][1]})
embed<- readRDS(pagoda_rds) # not efficient, fix 
embed<- embed$embedding
embed<-tibble::rownames_to_column(as.data.frame(embed))
colnames(embed)<-c("cell","d1","d2")
pagoda<-pagoda %>% left_join(.,embed,by=c("cell")); rm(embed)
cat(".. Reading pagoda file\n.. ..",args5,"\n")

cat(".. Reading files with inputed cells to inferCNV:\n")
incnv<-paste(args6,samp,sep="")
cnvf<-vector("list",length(incnv))
for(i in 1:length(incnv)){
	tmp<-read.table(incnv[i],header=FALSE,sep="\t",colClasses=c("character","character"))
	cnvf[[i]]<- data.frame(cell=tmp[,1],tag=tmp[,2],groups=substr(tmp[,2],nchar(gsub("[0-9]*$","",tmp[,2]))+1,nchar(tmp[,2])))
	cat(".. ..",incnv[i],"\n")
	names(cnvf)[i]<-samp[i]
	}
	
flnm<-args13 
bulk_cnv<-read.table(flnm, colClasses=c(rep("factor",5),rep("numeric",2)), header=TRUE,na.string="NA")
cat(".. Reading bulk seq CNV data:\n.. .. ",flnm,"\n")

chr_nm<-args15
chr_size<-read.table(chr_nm,colClasses=c("factor","numeric","numeric","NULL","NULL"),header=TRUE,sep="\t")
cat(".. Loading:",chr_nm,"\n")

cat("Done",Sys.time(),"-------------------------------------------------------------------------------------------------------------\n")
cat("DATA PROCESSING\n")
# Consolidate cells
cat(".. Get cells that entered CNV analysis are same as in pagoda\n")
for(v in 1:length(cnvf)) {
	spl<-names(cnvf[v])
	cat(".. .. for sample",spl,"\n")
	pgda_cell<- pagoda %>% filter(sample==spl) %>% select(cell) %>% unlist()
	temp<- cnvf[[v]] %>% filter(cell %in% pgda_cell) %>% unlist()
	cat(".. .. .. number of cells that entered inferCNV:", nrow(cnvf[[v]]),"\n.. .. .. number of cells that pass pagoda:",length(pgda_cell),"\n.. .. .. Cells are the same:",all(pgda_cell %in% temp),"\n")
	
	rm(temp);rm(spl);rm(pgda_cell) 
	}

comp<-args7
if(comp=="YES"){
	cat(".. Consolidate inferCNV and PAGODA cells\n")
    idx1<-unlist(cnvf)
    idx2<-pagoda$cell
    temp1<- pagoda %>% filter(cell %in% unlist(cnvf))
    temp2<- lapply(1:length(cnvf), function(x) {spl<- names(cnvf[x])
		                                        idx<- pagoda %>% filter(sample==spl) %>% select(cell) %>% unlist()
												temp<- cnvf[[x]] %>% filter(cell %in% idx)
												return(temp)
												}
					); names(temp2)<-names(cnvf)
	pagoda<-temp1
	cnvf<-temp2
	rm(idx1);rm(idx2);rm(temp1);rm(temp2)
}; cnvf<-bind_rows(cnvf,.id="sample")

chr_bands<-args3
cat(".. Getting contingency tables to test enriched CNVs in specified genomic regions SAMPLE SPECIFIC and within clusters\n")
dat5<-lapply(chr_bands, function(x) {temp<- lapply(1:length(dat), function(z) {
																	spl<-names(dat)[z]
																	z<-dat[[z]]
																	z$old_state<-z$State
																	z$State[z$State < 3]<- -1 ; z$State[z$State > 3]<- 1
																	z$chrRegion<- gsub(pattern=" ",replacement="-",x=z$chrRegion)
																	cat(".. .. Getting CNVs in",x["chr"],"and state",x["state"],"for sample:",spl,"\n")
																	cellsWcnv<-z %>% filter(as.character(chr)==x["chr"]&State==x["state"]) %>% .[grep(x["pattern"],.$chrRegion), c("cell","groups","cnv_name","old_state","Prob")] 
																	cellsWOcnv<- cnvf %>% filter(sample==spl) %>% filter(! cell%in%cellsWcnv[,"cell"]) %>% select(cell, groups) %>% mutate(cnv_name=factor("none"),old_state=3,Prob=0,groups=as.integer(groups))
																	s1<- cellsWcnv %>% group_by(groups) %>% summarize(n_cells_W=n_distinct(cell)) %>% mutate(groups=as.character(groups))
																	s2<- cellsWOcnv %>% group_by(groups) %>% summarize(n_cells_WO=n_distinct(cell)) %>% mutate(groups=as.character(groups))
																	res<- full_join(s2, s1, by="groups");res[is.na(res)]<-0
																	res1<- bind_rows(cellsWcnv,cellsWOcnv)
																	return(list(cells=res1,contingency_table=res))
																	rm(z);rm(cellsWcnv);rm(cellsWOcnv);rm(s1);rm(s2);rm(res);rm(res1)
																	}
													)
									 names(temp)<-names(dat)
									 return(temp)
									 }
			); names(dat5)<- sapply(chr_bands, function(x) x["chr"])
# Format: get only contingency tables
dat55<-lapply(dat5, function(x) { temp<- lapply(x, function(z) {temp1<-z$contingency_table; return(temp1)})})
# Format: get cells
dat56<-lapply(dat5, function(x) {temp<- lapply(x, function(z) {temp1<-z$cells; return(temp1)}
												) %>% bind_rows(.,.id="sample") %>% left_join(pagoda,.,by=c("sample","cell","groups"))
								}
				) %>% bind_rows(.,.id="chr_region")
# Checkings
cat(".. .. Check all cells in each sample are present\n")
for(i in unique(dat56$sample)){
	for(j in unique(dat56$chr_region)){
		sample<-i
		region<-j
		cat(".. ... .. For sample",sample,"and cnvs in chromosomic region",region,"\n.. .. .. .. are all cells included?",
			all(pagoda[pagoda$sample==sample,"cell"]%in%dat56[dat56$sample==sample&dat56$chr_region==region,"cell"]),"\n")
	}
}

dat6<- lapply(dat55, function(p) {temp<-lapply(p, function(m){temp1<-fisher_test(m)})})
cat(".. Calculate Fisher exact test\n.. Return p.values (significance) and odds ratio (effect size)\n.. Significant threshold: Benjamini Hochberg FDR\n.. Alternative hypothesis: true odds ratio is greater than 1\n")
# Format
dat_p6<- lapply(dat6, function(x) {temp<- bind_rows(x, .id="sample"); return(temp)})
dat_p6<-bind_rows(dat_p6, .id="chr")
dat_p6$odds_ratio_estimate[dat_p6$odds_ratio_estimate == Inf]<-max(dat_p6$odds_ratio_estimate[!dat_p6$odds_ratio_estimate == Inf])+1
dat_p6$chr<-factor(dat_p6$chr)
dat_p6$groups<-sapply(dat_p6$comparison,function(x) strsplit(x,"_")[[1]][1]) 
dat_p6$groups<-as.integer(sapply(dat_p6$groups, function(x) strsplit(x,"CL")[[1]][2]))
dat_p6$color_key<-col_key[match(dat_p6$groups,names(col_key))]

thre<-args16
dat_p7<- dat_p6 %>% dplyr::filter (neg_log_adjpvalue > -log(thre)) %>% select(chr, sample, groups)
cat(".. Getting significant CNVs and clusters for a FDR<",thre,"\n")

# Format -further get index of only significant cells based on fdr threshold-
idx<-c(NA)
dat561<- dat56 %>% mutate(chr_region=as.character(chr_region),groups=as.character(groups))
for(i in 1:nrow(dat_p7)){
	x<-dat_p7[i,] %>% mutate(chr=as.character(chr))%>% unlist()
	idx<-c(idx,which(dat561$sample==x["sample"]&dat561$chr_region==x["chr"]&dat561$groups==x["groups"]))
}; idx<-!is.na(idx)								
dat561$cnv_name[!idx]<-"none"
dat561$old_state[!idx]<-3
dat561$Prob[!idx]<-0
dat561$groups<-as.integer(dat561$groups)

dat_p56<- tibble(cell=rep(pagoda$cell,each=length(unique(dat561$chr_region))),
				 groups=rep(pagoda$groups,each=length(unique(dat561$chr_region))),
				 sample=rep(pagoda$sample,each=length(unique(dat561$chr_region))),
				 d1=rep(pagoda$d1,each=length(unique(dat561$chr_region))),
				 d2=rep(pagoda$d2,each=length(unique(dat561$chr_region))),
				 chr_region=rep(unique(dat561$chr_region),nrow(pagoda))) %>% 
			left_join(.,
						dat561 %>% select(cell,groups,sample,d1,d2,chr_region,cnv_name,old_state,Prob), 
						by=c("sample","cell","groups","chr_region","d1","d2")) %>%
			replace_na(list(cnv_name="none",old_state=3,Prob=0)) %>%
			group_by(cell,chr_region) %>%
			summarize(avg_state=mean(old_state),avg_prob=mean(Prob),d1=d1,d2=d2,groups=groups)

# Format
dat_p8<- dat %>% bind_rows(.,.id="sample") %>% select(sample,cell,groups,color_key,cnv_name,State,Prob,chr,start,end)
dat_p8<-unique(dat_p8)
newnm<-c("SS2_17_281"="K87","SS2_17_285"="K10","SS2_17_286"="23","SS2_17_374"="K55","SS2_17_376"="K3","SS2_17_378"="19","SS2_17_380"="K47","SS2_17_382"="K6")

# Format
dat_p1<-lapply(1:nrow(dat_p7), function(i) {
							   temp<-dat_p8; temp$chr<-as.character(temp$chr); temp$sample1<-newnm[match(temp$sample,names(newnm))];
							   x<-dat_p7[i,]; x$chr<-as.character(x$chr)
							   temp1<-temp %>% dplyr::filter(sample==as.character(x[1,"sample"])&chr==as.character(x[1,"chr"])&groups==as.character(x[1,"groups"]))
							   temp1<- temp1 %>% mutate(sample=sample1) %>% select(sample,cell,groups,cnv_name,State,chr,start,end,color_key); temp1$chr<-as.factor(temp1$chr); 
							   return(temp1);rm(temp)}); dat_p1<-bind_rows(dat_p1)

REF<-bulk_cnv; REF$sample<-REF$alt_sample_id; REF<- REF %>% select(sample,chr,cnv,state,start,end)

zoom<-REF%>%filter(cnv=="yes"&chr%in%reg$chr)%>% group_by(chr)%>%summarize(start=min(start),end=max(end))

cat("Done",Sys.time(),"--------------------------------------------------------------------------------------------------------------\n")
cat("PLOTTING\n")

p6<-ggplot(data=dat_p6, aes(x=factor(sample), y=factor(comparison),fill=neg_log_adjpvalue))+
    geom_tile(color="white")+
    coord_equal()+
    labs(x="", y="", fill="-log(FDR)")+
    scale_fill_gradient(low="blue",high="red")+
    scale_x_discrete(labels=c("K87","K10","23","K55","K3","19","K47","K6"))+
    facet_wrap(~chr,ncol=3, labeller=labeller(chr=c(chr1="1p loss",chr11="11q loss",chr17="17q gain",chr2="MYCN amplified")))+
    theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))
cat(".. .. Plot 1\n")    

outD<-args8
scrpt<-args9
samp<-unique(dat_p8$sample)
for(i in 1:length(samp)){
	nm<-paste(outD,scrpt,"2__",samp[i],".png",sep="")
	svg(nm)
	p8<-kp_f1(samp_ID=samp[i],title=newnm[which(names(newnm)==samp[i])],DATA=dat_p8,reference=bulk_cnv,skip="FALSE",colrs="YES", chrom=reg)
	dev.off()
	cat(".. Plotting and writing",nm,"\n")
	rm(nm);rm(p8)
}

outnm1<-paste(outD,scrpt,"_3.svg",sep="")
svg(outnm1)
##### sth wrong  p1<-kp_f3(DATA=dat_p1,reference=REF,chrom=reg,fullC=cnvf,chrom_size=chr_size,zoom=NULL)
dev.off()
cat(".. Plotting and writing:",outnm1,"\n")

outnm2<-paste(outD,scrpt,"_4.svg",sep="")
svg(outnm2)
p1<-kp_f2(DATA=dat_p1,reference=REF,chrom=reg)
dev.off()
cat(".. Plotting and writing:",outnm2,"\n")

for(i in 1:nrow(zoom)){
	### sth wrong Z<-zoom[i,]
	outnm3<-paste(outD,scrpt,"_",i+4,".svg",sep="")
	svg(outnm3)
	p<-kp_f3(DATA=dat_p1,reference=REF,chrom=reg,fullC=cnvf,chrom_size=chr_size,zoom=Z)
	dev.off()
	cat(".. Plotting and writing:",outnm3,"\n")
}

outnm3<-paste(outD,scrpt,"_5.svg",sep="")
p56<-ggplot(data= dat_p56, aes(x=d1,y=d2))+
		facet_wrap(~factor(chr_region),ncol=2)+
		coord_equal()+
		#geom_point(aes(col=avg_state, alpha=1/10))+
		geom_point(aes(col=avg_state, shape=))+
		scale_shape_identity()+
		scale_color_gradient2(low="#000080",mid="#dcdcdc",high="#dc143c",midpoint=3)
#geom_point(aes(col=avg_state,shape=factor(ifelse(avg_state==3,1,19))),size=10)+
#scale_color_gradientn(colors=c("blue","grey50","red"),limits=c(2,5),oob=scales::squish)+
#scale_size_identity()+    
#p5<- p5 + theme_void() + theme(legend.position="top", legend.title=element_blank(), aspect.ratio=1/1)
p56<- p56 + theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(), 
					panel.border=element_blank(), panel.background=element_blank(),
					aspect.ratio=1/1, 
					axis.title=element_blank())
## need to 
#1)remove the alpha scale and 
#2)the background grid and 
#3)the x/y labels
#4)make point size smaller
#5)different shape (full and empty)

outnm3<-paste(outD,scrpt,"_6.svg",sep="")
p566<-ggplot(data= dat_p56, aes(x=d1,y=d2))+
     facet_wrap(~factor(chr_region),ncol=2)+
     coord_equal()+
     #geom_point(aes(col=avg_prob, alpha=1/10))+
     geom_point(aes(col=avg_prob))+
     scale_shape_identity()+
     scale_color_gradient2(low="#dcdcdc",mid="#dcdcdc",high="#dc143c",midpoint=0.5)

p55<- p55 + theme_void() + theme(legend.position="top", legend.title=element_blank(), aspect.ratio=1/1)

p56###<-ggplot(data= dat_p5, aes(x=d1,y=d2))+
     facet_wrap(~factor(chr_region),ncol=2)+
     coord_equal()+
     geom_point(aes(col=factor(groups)))+
     scale_shape_identity()+
	 scale_color_manual(values=args11)

p56<- p56 + theme_void() + theme(legend.position="top", legend.title=element_blank(), aspect.ratio=1/1) 
cat(".. plot 1\n")
cat("Done",Sys.time(),"--------------------------------------------------------------------------------------------------------------\n")

cat("WRITING OUTPUT",Sys.time(),"--------------------------------------------------------------------------------------------------------------------------\n")
outD<-args8
outD1<-args10
scrpt<-args9
nm0<-paste(outD1,scrpt,".RData",sep="")
save.image(file=nm0)
cat(".. Saving\n.. ..",nm0,"\n")

outD2<-args14 #outD2<-"/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/"
nm00<-paste(outD2,scrpt,".csv",sep="")
write.table(dat_p6,nm00,sep="\t")
cat(".. Saving\n.. ..",nm00,"\n")

nm1<-paste(outD,scrpt,"1.svg",sep="")
#ggplot2::ggsave(plot=cowplot::plot_grid(plotlist= p1, ncol=2, nrow=2),filename= outnm2)
ggplot2::ggsave(plot=p6,filename=nm1,device="svg")
cat(".. Saving\n.. ..",nm1,"\n")

cat("DONE",Sys.time(),"--------------------------------------------------------------------------------------------------------------------------\n")
end_time<-Sys.time()
end_time-start_time
cat("--------------------------------------------------------------------------------------------------------------------------\n")
sessionInfo()


if(FALSE){
### 1) In each cluster and across samples: are the number of cells w CNVs larger than the expected number by chance?
cat(".. Getting the total number of CNVs in cells across samples\n")
dat1<-lapply(dat, function(z) {	spl<-unique(sapply(z$cell, function(x) {strsplit(x=x,split=".",fixed=TRUE)[[1]][1]}))
								wCNV<-z %>% group_by(groups) %>% summarize(cells_w_cnv=n_distinct(cell))
								wCNV$groups<-factor(wCNV$groups)
								tot<- cnvf[[which(names(cnvf)==spl)]] %>% group_by(groups) %>% summarize(tot_cells=n_distinct(cell)) 
								tot$groups<-factor(tot$groups)
								res<- full_join(tot,wCNV,by="groups");res[is.na(res)]<-0
								return(res)
								rm(spl);rm(wCNV);rm(tot)
								}
			)
dat1<- do.call(rbind,dat1) %>% group_by(groups) %>% summarize(Ntot_cells=sum(tot_cells),Ncells_w_cnv=sum(cells_w_cnv)) %>% select(Ncells_w_cnv,Ntot_cells)  

### 2) Are CNVs in specific genomic regions enriched in some clusters compared to others?
cat(".. Getting contingency tables to test enriched CNVs in specified genomic regions ACROSS samples and within clusters\n")
dat2<-lapply(chr_bands, function(x) {temp<- lapply(1:length(dat), function(z) {spl<-names(dat)[z]
																	z<-dat[[z]]
																	z$State[z$State < 3]<- -1 ; z$State[z$State > 3]<- 1
																	z$chrRegion<- gsub(pattern=" ",replacement="-",x=z$chrRegion)
																	cat("..Getting CNVs in",x["chr"],"and state",x["state"],"for sample:",spl,"\n")
																	cellsWcnv<-z %>% filter(as.character(chr)==x["chr"]&State==x["state"]) %>% .[grep(x["pattern"],.$chrRegion), c("cell","groups")] %>% distinct()
																	cellsWOcnv<-cnvf[[which(names(cnvf)==spl)]] %>% filter(! cell%in%cellsWcnv[,"cell"]) %>% select(cell, groups) 
																	s1<- cellsWcnv %>% group_by(groups) %>% summarize(n_cells_W=n_distinct(cell)) %>% mutate(groups=as.character(groups))
																	s2<- cellsWOcnv %>% group_by(groups) %>% summarize(n_cells_WO=n_distinct(cell)) %>% mutate(groups=as.character(groups))
																	res<- full_join(s2, s1, by="groups");res[is.na(res)]<-0
																	return(list(cells_W=cellsWcnv,cells_WO=cellsWOcnv,contingency_table=res))
																	rm(z);rm(cellsWcnv);rm(cellsWOcnv);rm(s1);rm(s2);rm(res)
																	}
													)
									names(temp)<-names(dat)
									temp1<-do.call(rbind,lapply(1:length(temp), function(q) {cbind(temp[[q]]$contingency_table,sample=names(temp)[q])})) %>% group_by(groups) %>% summarize(n_cells_W=sum(n_cells_W),n_cells_WO=sum(n_cells_WO)) 
									}	
			); names(dat2)<- sapply(chr_bands, function(x) {x[1]})			
cat(".. .. Calculate Fisher exact test\n.. Return p.values (significance) and odds ratio (effect size)\n.. Significant threshold: Benjamini Hochberg FDR.. Alternative hypothesis: true odds ratio is greater than 1\n")
dat3<- lapply(dat2, function(p) { temp<-fisher_test(contingency_table=p); return(temp)});names(dat3)<-names(dat2)

dat_p1<-data.frame(comparison=rep(names(dat4$chr1$adj_p_values),length(dat4)), 
					chr=rep(names(dat4),each=length(dat4$chr1$adj_p_values)),
					pvalues=(unlist(do.call(rbind,dat4)[,"adj_p_values"])),
					row.names=NULL)
colr<-summary(dat_p1$pvalues[! dat_p1$pvalues== 1])
#p1<-ggplot(data=dat_p1, aes(x=factor(chr), y=factor(comparison),fill=as.factor(pvalues)))+
p1<-ggplot(data=dat_p1, aes(x=factor(chr), y=factor(comparison),fill=pvalues))+
    geom_tile()+
    labs(x="", y="", fill="adjusted p.value")+
	#scale_fill_gradientn(colours=c("#FF0000","#FF6347","#FFA07A","grey50"),values=c(colr["Min."],colr["Mean"],colr["Max."],1), breaks=c(colr["Min."],colr["Mean"],colr["Max."],1))
    scale_fill_gradientn(colors=c("red","grey50"))
    #scale_fill_manual(values=c("#32CD32","#C0C0C0"))
    #ggtitle()
cat(".. Plot 1\n")
    
dat_p2<-data.frame(comparison=rep(names(dat4$chr1$adj_odds_ratio),length(dat4)), 
					chr=rep(names(dat4),each=length(dat4$chr1$adj_odds_ratio)),
					odds.ratio=(unlist(do.call(rbind,dat4)[,"adj_odds_ratio"])),
					row.names=NULL)
p2<-ggplot(data=dat_p2, aes(x=factor(chr), y=factor(comparison),fill=odds.ratio))+
    geom_tile()+
    labs(x="", y="", fill="effect.size")+
    scale_fill_gradientn(colours=c('grey50','red'))
cat(".. Plot 2\n")

dat_p3<- dat[["SS2_17_382"]]
dat_p3<-unique(dat_p3[,c("Prob","State","cnv_name","chr","start","end","cell","groups")]) 
dat_p3$State[dat_p3$State < 3]<- -1 ; dat_p3$State[dat_p3$State > 3]<- 1; 
temp<- dat_p3 %>% group_by(groups) %>% summarize(n_groups= n_distinct(cell))
dat_p3<- dat_p3 %>% group_by(chr,start,end,Prob,State,groups) %>% 
                    summarize(n_cells= n_distinct(cell)) %>% 
                    mutate(ProbXncell= Prob * n_cells,midpoint= ((end - start)/2)+start) %>%
                    right_join(temp,.,by=c("groups")) %>% as.data.frame()
rm(temp)    
comment(dat_p3)<-"chr=chromosome start=CNV_start end= CNV_end midpoint=CNV_midpoint Prob=CNV_significance(Bayesian posterior probability of the state) State=lo
ss/gain groups=clusters n_groups=total number of cells in cluster  n_cells=total # cells in CNV  ProbXncell=Prob * n_cells)"
NM<-"SS2_17_382"
DT<-dat_p3
CHR<-paste("chr",c(1,2,11,17),sep="")
p3<-kp_f(samp_ID=NM,data=DT,reference=NULL, skip=TRUE, plot_type="area",chrom=CHR, mp="midpoint",y1="ProbXncell",scale=TRUE, colR=NULL)
cat(".. Plot 3\n")

p7<-ggplot(data=dat_p6, aes(x=factor(sample), y=factor(comparison),fill=odds_ratio_estimate))+
    geom_tile(color="white")+
    coord_equal()+
    facet_wrap(~factor(chr),ncol=3)+
    theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1))+
    labs(x="", y="", fill="effect size (odds ratio)")+
    scale_fill_gradientn(colours=c('grey50','red'))

}
