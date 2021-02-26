#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 02:00:00
#SBATCH -J 04.2.2_plot
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

# This code: /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/submitters/02_submit/04.2.2_plot.sh
# What this snippet of code does:
# .. Executes: /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/04.2_plot.R -->
# .. .. .. .. .. Goes into the infercnv BAYESIAN output directory for each of the samples and loads the last binary file produced. Then it plots a heatmap in pdf format -- as opposed to png format that was the default when the binary was produced --
# .. .. 1) Input: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/02_run_infercnv_[sample]__v1.0.4_0.1_1_101.d/13_HMM_pred.Bayes_NetHMMi6.rand_trees.hmm_mode-subclusters.mcmc_obj             
# .. .. 2) Output: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plot/04.2.2_plot_[sample].pdf
# .. A dump of the R code is in: /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/routs.d/02_routs/04.2.2.1_plot__[sample].ROUT      

source /castor/project/proj/maria.d/.profile

# code location
codedir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d'
cd $codedir

# Input directory
indir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/"
# Input file
nm1="02_run_infercnv_"
nm2="__v1.0.4_0.1_1_101.d/"
nm3="13_HMM_pred.Bayes_NetHMMi6.rand_trees.hmm_mode-subclusters.mcmc_obj"
# Output directory
outdir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/"
# output file name
nm4="04.2.2_plot"
# samples
samp=(SS2_17_374 SS2_17_376 SS2_17_378 SS2_17_281 SS2_17_285 SS2_17_286 SS2_17_380 SS2_17_382)

for i in "${samp[@]}"
	do
		# Input file name		
		args1="as.character('$indir$nm1$i$nm2$nm3')"
		# output file name
		args2="as.character('$outdir')"
		args3="as.character('$nm4"__"$i')"
		# output format
		args4="as.character('pdf')"
		# sample
		args5="as.character('$i')"
		Rscript --vanilla $codedir/04.2_plot.R $args1 $args2 $args3 $args4 $args5 > $codedir/routs.d/02_routs/04.2.2.1_plot__$i.rout
	done
		



