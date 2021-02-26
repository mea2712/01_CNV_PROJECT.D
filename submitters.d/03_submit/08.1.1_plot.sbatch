#!/bin/bash 

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 00:15:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J 08.1.1_plot                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=08.1.1_plot_%J.stdout    #### REMEMBER TO KEEP UPDATED ####

#---------------------------------------------------------------------------------------------------------#

# Load software modules
module load R/4.0.0
module load R_packages/4.0.0
#------------------------------------------------------------------------------------------------------------#

# slurm arguments
if [ ! -z "$SLURM_JOB_ID" ] && [ ! "$SLURM_JOB_NAME" = "_interactive" ]
then
	echo "JOB_ID=${SLURM_JOB_ID}"
	echo "JOB_NAME=${SLURM_JOB_NAME}"
fi
#---------------------------------------------------------------------------------------------------------#

# Code and logs directories
codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/"
logdir=$(echo "${codedir}routs.d/03_routs/")
lognm="08.1.1_plot"
#-------------------------------------------------------------------------------------------------------#

# LOCAL VARIABLES
# input files
args0="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/03_temp/03.1.1_collect_results_infercnv__"
args00=$( ls ${args0}* )
args1="c('${args00//[[:space:]]/','}')"

# Samples
## ## redundant. Just to not mess up old code
## ## make sure the samples order is the same in $args1 and $args2
args2=$( ls ${args0}* | grep -oE "SS2_[0-9]{1,}_[0-9]{1,}" )
args2="c('${args2//[[:space:]]/','}')"

# chr region pattern pass to grep
args3="list(c('chr'='chr1','pattern'='*p[0-9].[0-9]*','state'= -1),c('chr'='chr11','pattern'='*q[0-9].[0-9]*', 'state'=-1),c('chr'='chr17','pattern'='*q[0-9].[0-9]*','state'=1))"
args3="$(echo -e "${args3}" | tr -d '[:space:]')"

# cluster tags
args4="c('1','MSC_1',\
'2','Undifferentiated_2',\
'3','Undifferentiated_3',\
'4','Endothelial_4',\
'5','NOR_5',\
'6','Tcells_6',\
'7','Macrophages_7',\
'8','NOR_8',\
'9','NOR_9',\
'10','NOR_10')"
args4="$(echo -e "${args4}" | tr -d '[:space:]')"

# Cluster color key
args11="c('1'='#9edae5',\
'2'='#7b4173',\
'3'='#9ecae1',\
'4'='#1f77b4',\
'5'='#fbd6f0',\
'6'='#e377c2',\
'7'='#62c05b',\
'8'='#bfff40',\
'9'='#d62728',\
'10'='#17becf')"
args11="$(echo -e "${args11}" | tr -d '[:space:]')"

# pagoda files
args5="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/03_data/NB_KEql10.rds')"

# Input file to inferCNV
args6="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/03_out/01.2.1_input_infercnv___CELLS-')"

# Input file with bulk seq reference CNV
args13="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/03_data/bulk_seq_CNV.txt')"

# Input file with chromosome regions
args15="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/03_data/ChrRegions_pq')"

# Consolidate pagoda/inferCNV cells? (due to filtering in inferCNV)--> YES/NO
args7="as.character('YES')"

# FDR threshold to call significance
args16="c(0.05)"

# chrs to plot in karyoplot
args12="data.frame(chr=c('chr1','chr11','chr17'),state=c(-1,-1,1))"

# Output directory
args8="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/03_plots/')"
args10="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/03_temp/')"
args14="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/03_out/')"

# Output files
args9="as.character('08.1.1_plot')"

# sample coding
args17="c('SS2_17_281'='K87',\
			'SS2_17_285'='K10',\
			'SS2_17_286'='23',\
			'SS2_17_374'='K55',\
			'SS2_17_376'='K3',\
			'SS2_17_378'='19',\
			'SS2_17_382'='K6')"
args17="$(echo -e "${args17}" | tr -d '[:space:]')"
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
if [ ! -z "$SLURM_JOB_ID" ] && [ ! "$SLURM_JOB_NAME" = "_interactive" ]
then
	Rscript --vanilla ${codedir}08.1_plot.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 $args10 $args11 $args12 $args13 $args14 $args15 $args16 $args17 > ${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.ROUT
else
		Rscript --vanilla ${codedir}08.1_plot.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 $args10 $args11 $args12 $args13 $args14 $args15 $args16 $args17 > ${logdir}${lognm}.ROUT
fi 

unset args1 args2 args3 args4 args5 args6 args7 args8 args9 args10 args11 args12 args13 args14 args15 args16 args17
#---------------------------------------------------------------------------------------------------------#

# Collect standard output
if [ ! -z "$SLURM_JOB_ID" ] && [ ! "$SLURM_JOB_NAME" = "_interactive" ]
then
	mv ${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout ${logdir}
	echo "LOG FILES ARE IN: " 
	echo "${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout"
fi
