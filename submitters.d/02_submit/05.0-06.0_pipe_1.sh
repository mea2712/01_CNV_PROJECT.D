#!/bin/bash 

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 00:15:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J 05.0-06.0_pipe_1_                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=05.0-06.0_pipe_1_%J.stdout    #### REMEMBER TO KEEP UPDATED ####

#---------------------------------------------------------------------------------------------------------#
# This code: /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/submitters/02_submit/05.0.2_plot.sh
# What this snippet of code does:
# .. Executes: /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/05.0_plot.R -->
# .. .. .. .. .. Goes into the temp output directory and loads the binary file produced by 03.0_collect_results_infercnv.R. Then it plots a heatmap of Fisher's exact test on cluster comparison for CNVs a and karyotipe (for sample SS2_17_382) 
# .. .. Input: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/$args1
# .. .. .. ..  2) /castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/11NBs_noMitchnd_KEql12.pagodaApp.rds
# .. .. .. ..  3) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___CELLS-${args2}
# .. .. Output: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/05.0.1_plot[1,2,3].[svg,svg,png]
# .. A dump of the R code is in: /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/routs.d/02_routs/05.0.2.1_plot.ROUT

#--------------------------------------------------------------------------------------------------------------#
# Load software modules
module load R/4.0.0
module load R_packages/4.0.0

#------------------------------------------------------------------------------------------------------------#
# slurm arguments
echo "JOB_ID=${SLURM_JOB_ID}"
echo "JOB_NAME=${SLURM_JOB_NAME}"
#---------------------------------------------------------------------------------------------------------#

# Code and logs directories
codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/"
logdir=$(echo "${codedir}routs.d/02_routs/")
#-------------------------------------------------------------------------------------------------------#

# LOCAL VARIABLES
# input files
ARGSA="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/"
ARGSB="03_collect_results_infercnv__"
ARGSC="03.0.1_collect_results_infercnv__"
args1="c('${ARGSA}${ARGSC}SS2_17_281.RData','${ARGSA}${ARGSB}SS2_17_285.RData','${ARGSA}${ARGSC}SS2_17_286.RData','${ARGSA}${ARGSB}SS2_17_374.RData','${ARGSA}${ARGSC}SS2_17_376.RData','${ARGSA}${ARGSB}SS2_17_378.RData','${ARGSA}${ARGSC}SS2_17_380.RData','${ARGSA}${ARGSC}SS2_17_382.RData')"
args1="$(echo -e "${args1}" | tr -d '[:space:]')" # Make sure and remove all white spaces otherwise it will complain

# Samples
## ## redundant. Just to not mess up old code
## ## make sure the samples order is the same in $args1 and $args2
args2="c('SS2_17_281','SS2_17_285','SS2_17_286','SS2_17_374','SS2_17_376','SS2_17_378','SS2_17_380','SS2_17_382')"

# chr region pattern pass to grep
args3="list(c('chr'='chr1','pattern'='*p[0-9].[0-9]*','state'= -1),c('chr'='chr11','pattern'='*q[0-9].[0-9]*', 'state'=-1),c('chr'='chr17','pattern'='*q[0-9].[0-9]*','state'=1),c('chr'='chr2','pattern'='*p24.[0-9]*','state'=1))"
args3="$(echo -e "${args3}" | tr -d '[:space:]')"

# cluster tags
args4="c('1'='Undifferentiated_1','2'='Undifferentiated_2','3'='Mesenchymal_stroma_3','4'='Macrophages_4','5'='Endothelial_5','6'='6','7'='NOR_7','8'='Undifferentiated_8','9'='MYCNamp_neural_9','10'='NOR_Undifferentiated_10','11'='Tcells_11','12'='NOR_12')"

# Cluster color key
args11="c('1'='#fbd6f0','2'='#f7b6d2','3'='#d62728','4'='#62c05b','5'='#17becf','6'='gainsboro','7'='#9edae5','8'='#e377c2','9'='#7b4173','10'='#1f77b4','11'='#bfff40','12'='#9ecae1')"

# pagoda files
args5="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/11NBs_noMitchnd_KEql12.pagodaApp.rds')"

# Input file to inferCNV
args6="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___CELLS-')"

# Input file with bulk seq reference CNV
args13="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/bulk_seq_CNV.txt')"

# Input file with chromosome regions
args15="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/ChrRegions_pq')"

# Consolidate pagoda/inferCNV cells? (due to filtering in inferCNV)--> YES/NO
args7="as.character('YES')"

# FDR threshold to call significance
args16<-"c(0.05)"

# chrs to plot in karyoplot
args12="data.frame(chr=c('chr1','chr2','chr11','chr17'),state=c(-1,1,-1,1))"

# Output directory
args8="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/')"
args10="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/')"
args14="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/')"

# Output files
args9="as.character('05.0-06.0_pipe_1_05.0_plot')"
#---------------------------------------------------------------------------------------------------------#

# Print arguments passed
var_=$( echo "$(compgen -v | grep -i 'args' -)" )
read -d " " -a  var_array <<< "$var_"

echo "VARIABLES EXPORTED:"
for i in ${var_array[@]} 
do 
        eval temp='$'$i  
        echo "$i: $temp"
done
unset var_ var_array i temp

#-----------------------------------------------------------------------------------------------------------------#
# Run
if [  -z "$SLURM_JOB_ID" ]
then
	Rscript --vanilla ${codedir}05.0_plot.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 $args10 $args11 $args12 $args13 $args14 > ${logdir}${SLURM_JOB_NAME}05.0_${SLURM_JOB_ID}.ROUT
else
		Rscript --vanilla ${codedir}05.0_plot.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 $args10 $args11 $args12 $args13 $args14 > ${logdir}05.0-06.0_pipe_1_05.0.ROUT
fi 

unset args1 args2 args3 args4 args5 args6 args7 args8 args9 args10 args11 args12 args13 args14
sleep 5m

################################################################################################################

# LOCAL VARIABLES
# Input files
args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/05.0-06.0_pipe_1_05.0_plot.RData')"

# FDR threshold
args2="c(0.05)"

# File with chromosome lengths
args3="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/ChrRegions_pq')"

# Output directory
args5="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/')"

# Output files
args4="as.character('05.0-06.0_pipe_1_06.0_plot')"

#---------------------------------------------------------------------------------------------------------#

# Print arguments passed
var_=$( echo "$(compgen -v | grep -i 'args' -)" )
read -d " " -a  var_array <<< "$var_"

echo "VARIABLES EXPORTED:"
for i in ${var_array[@]} 
do 
        eval temp='$'$i  
        echo "$i: $temp"
done
unset var_ var_array i temp

#-----------------------------------------------------------------------------------------------------------------#
# Run
if [  ! -z "$SLURM_JOB_ID" ]
then
	Rscript --vanilla ${codedir}06.0_plot.R $args1 $args2 $args3 $args4 $args5 > ${logdir}${SLURM_JOB_NAME}06.0_${SLURM_JOB_ID}.ROUT
else
		Rscript --vanilla ${codedir}06.0_plot.R $args1 $args2 $args3 $args4 $args5 > ${logdir}05.0-06.0_pipe_1_06.0.ROUT
fi 

unset args1 args2 args3 args4 args5
#---------------------------------------------------------------------------------------------------------#
# Collect standard output
if [ ! -z "$SLURM_JOB_ID" ]
then
	mv ${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout ${logdir}
	echo "LOG FILES ARE IN: " 
	echo "${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout"
fi
