#!/bin/bash

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J 03.0.1_collect_results_infercnv_                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=03.0.1_collect_results_infercnv_%J.stdout    #### REMEMBER TO KEEP UPDATED ####
#---------------------------------------------------------------------#

# Load software modules
module load R/4.0.0
module load R_packages/4.0.0
#---------------------------------------------------------------------#

# slurm arguments
if [ ! -z "$SLURM_JOB_ID" ]
then
	echo "JOB_ID=${SLURM_JOB_ID}"
	echo "JOB_NAME=${SLURM_JOB_NAME}"
fi
#-----------------------------------------------------------------------#

# Code and logs directories
codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/"
logdir=$(echo "${codedir}routs.d/03_routs/")
lognm="03.1.1_collect_results_infercnv"
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Input files
# rooth path for results of infercnv run
indir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/03_out/02.1.1_run_infercnv"
# version and paramters used and included in results file names
par="v1.4.0_0.1_1_101"
# pagoda run results
indir1="/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/03_data/NB_KEql10.rds"
# output directory
outdir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/03_temp/"
# output files name
outnm="03.1.1_collect_results_infercnv__"
# files to pass to getCNVdat3()
# .. stateprob
ST="BayesNetOutput.HMMi6.rand_trees.hmm_mode-subclusters/CNV_State_Probabilities.dat"
# .. cellgroupings
CG="17_HMM_predHMMi6.rand_trees.hmm_mode-subclusters.cell_groupings"
# .. cnvreg
CNVR="HMM_CNV_predictions.HMMi6.rand_trees.hmm_mode-subclusters.Pnorm_0.1.pred_cnv_regions.dat"
# .. chrreg
CHRR="/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/04_data/ChrRegions_pq"
# .. genesincnv
GC="HMM_CNV_predictions.HMMi6.rand_trees.hmm_mode-subclusters.Pnorm_0.1.pred_cnv_genes.dat"
# .. genesused
GU="17_HMM_predHMMi6.rand_trees.hmm_mode-subclusters.genes_used.dat"
#---------------------------------------------------------------------------------------------#

# Run
# Pattern of COUNT files (or CELLS files) produced by 01.2_input.infercnv.R -everything but the SAMPLE ID -
patt="01_CNV_PROJECT.D/output.d/03_out/01.2.1_input_infercnv___COUNTS-"
samp=$( ls ${patt}* | cut -d'-' -f2 )
read -d" " -a  samp <<< "$samp"

for i in "${samp[@]}"
do
	args1="as.character('${indir}_${i}__${par}.d')"
	args2="as.character('${indir1}')"
	args3="as.character('normal')"
	args4="as.character('${outdir}')"
	args5="as.character('$i')"
	args6="as.character('${outnm}')"
	args7="as.character('${indir}_${i}__${par}.d/${ST}')"
	args8="as.character('${indir}_${i}__${par}.d/${CG}')"
	args9="as.character('${indir}_${i}__${par}.d/${CNVR}')"
	args10="as.character('${CHRR}')"
	args11="as.character('${indir}_${i}__${par}.d/${GC}')"
	args12="as.character('${indir}_${i}__${par}.d/${GU}')"
	# Run
	if [ ! -z "$SLURM_JOB_ID" ]
	then
		Rscript --vanilla ${codedir}03.1_collect_results_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 $args10 $args11 $args12 > ${logdir}${SLURM_JOB_NAME}_${i}_${SLURM_JOB_ID}.ROUT
	else
		Rscript --vanilla ${codedir}03.1_collect_results_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 $args10 $args11 $args12 > ${logdir}${lognm}_${i}.ROUT
	fi 
done


#-----------------------------------------------------------------------#

# Collect standard output
if [ ! -z "$SLURM_JOB_ID" ]
then
	mv ${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout ${logdir}
	echo "LOG FILES ARE IN:"
	echo "${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout"
fi
