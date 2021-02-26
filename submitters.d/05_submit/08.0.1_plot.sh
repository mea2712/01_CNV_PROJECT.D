#!/bin/bash 

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 00:15:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J 08.0.1_plot                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=08.0.1_plot_%J.stdout    #### REMEMBER TO KEEP UPDATED ####

#---------------------------------------------------------------------------------------------------------#

# Load software modules
module load R/4.0.0
module load R_packages/4.0.0
#------------------------------------------------------------------------------------------------------------#

# slurm arguments
if [ ! -z "$SLURM_JOB_ID" ]
then
	echo "JOB_ID=${SLURM_JOB_ID}"
	echo "JOB_NAME=${SLURM_JOB_NAME}"
fi
#---------------------------------------------------------------------------------------------------------#

# Code and logs directories
codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/"
logdir=$(echo "${codedir}routs.d/05_routs/")
lognm="08.0.1_plot"
#-------------------------------------------------------------------------------------------------------#

# LOCAL VARIABLES
# input files
args0="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/05_temp/03.1.1_collect_results_infercnv__"
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
args4="c('1'='Undifferentiated_1',\
			'2'='MSC_2',\
			'3'='nC3',\
			'4'='Undifferentiated_4',\
			'5'='Undifferentiated_5',\
			'6'='NOR_6',\
			'7'='nC7',\
			'8'='Tcells_8',\
			'9'='Endothellial_9',\
			'10'='Macrophages_10',\
			'11'='MYCN_amp_11',\
			'12'='NOR_12',\
			'13'='NOR_13',\
			'14'='NOR_14')"
args4="$(echo -e "${args4}" | tr -d '[:space:]')"

# Cluster color key
args11="c('1'='#dc4b6d',\
			'2'='#d62728',\
			'3'='#d3d3d3',\
			'4'='#fbd6f0',\
			'5'='#e377c2',\
			'6'='#aec7e8',\
			'7'='#f5f5f5',\
			'8'='#bfff40',\
			'9'='#17becf',\
			'10'='#62c05b',\
			'11'='#7b4173',\
			'12'='#9edae5',\
			'13'='#1f77b4',\
			'14'='#9ecae1')"
args11="$(echo -e "${args11}" | tr -d '[:space:]')"

# pagoda files
args5="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/05_data/NB_KEql14.rds')"

# Input file to inferCNV
args6="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/05_out/01.2.1_input_infercnv___CELLS-')"

# Input file with bulk seq reference CNV
args13="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/05_data/bulk_seq_CNV.txt')"

# Input file with chromosome regions
args15="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/05_data/ChrRegions_pq')"

# Consolidate pagoda/inferCNV cells? (due to filtering in inferCNV)--> YES/NO
args7="as.character('YES')"

# FDR threshold to call significance
args16="c(0.05)"

# chrs to plot in karyoplot
args12="data.frame(chr=c('chr1','chr11','chr17'),state=c(-1,-1,1))"

# Output directory
args8="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/05_plots/')"
args10="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/05_temp/')"
args14="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/05_out/')"

# Output files
args9="as.character('08.0.1_plot')"

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
if [ ! -z "$SLURM_JOB_ID" ]
then
	Rscript --vanilla ${codedir}08.0_plot.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 $args10 $args11 $args12 $args13 $args14 $args15 $args16 $args17 > ${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.ROUT
else
		Rscript --vanilla ${codedir}08.0_plot.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 $args10 $args11 $args12 $args13 $args14 $args15 $args16 $args17 > ${logdir}${lognm}.ROUT
fi 

unset args1 args2 args3 args4 args5 args6 args7 args8 args9 args10 args11 args12 args13 args14 args15 args16 args17
#---------------------------------------------------------------------------------------------------------#

# Collect standard output
if [ ! -z "$SLURM_JOB_ID" ]
then
	mv ${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout ${logdir}
	echo "LOG FILES ARE IN: " 
	echo "${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout"
fi
