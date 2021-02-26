#!/bin/bash

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 00:30:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J 01.2.1_input_infercnv                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=01.2.1_input_infercnv_%J.stdout    #### REMEMBER TO KEEP UPDATED ####
#---------------------------------------------------------------------#

# Load software modules
module load R/4.0.0
module load R_packages/4.0.0
#---------------------------------------------------------------------#

# slurm arguments
echo "JOB_ID=${SLURM_JOB_ID}"
echo "JOB_NAME=${SLURM_JOB_NAME}"
#-----------------------------------------------------------------------#

# Code and logs directories
codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/"
logdir=$(echo "${codedir}routs.d/05_routs/")
lognm="01.2.1_input_infercnv"                      #### SAME AS #SBATCH -J ####
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Input files
# NB pagoda rds file
args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/05_data/NB_KEql10.rds')"

# which are the normal clusters
args2="c(6,10)"

# cluster key
args3="c('1'='Undifferentiated_1',\
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
args3="$(echo -e "${args3}" | tr -d '[:space:]')"

# NB counts file
args4="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/05_data/hg38.noIntrns.NBhighQC.allGns.counts.htsq.clltyHQ.noMitchnd.csv')"

# Genes file
args5="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/05_data/hg38.genecodeV28Comp.ERCCeGFP.cfflinks.noIntrns.gnNms.biotyp.gtf')"

# Ouput directories
args6="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/05_out/')"
args7="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/05_temp/')"

# Output files
args8="as.character(\"$lognm\")"
#-----------------------------------------------------------------------#

# Print arguments passed
var_=$( echo "$(compgen -v | grep -i args -)" )
read -d " " -a  var_array <<< "$var_"
echo "VARIABLES EXPORTED:"
for i in ${var_array[@]}
do
	eval temp='$'$i
	echo "$i: $temp"
done
unset var_ var_array i temp
#-----------------------------------------------------------------------#

# Run
if [  ! -z "$SLURM_JOB_ID" ]
then
	Rscript --vanilla ${codedir}01.2_input_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 > ${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.ROUT
else
	Rscript --vanilla ${codedir}01.2_input_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 > ${logdir}${lognm}.ROUT
fi
unset args1 args2 args3 args4 args5 args6 args7 args8
#-----------------------------------------------------------------------#

# Collect standard output
if [ ! -z "$SLURM_JOB_ID" ]
then
	mv ${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout ${logdir}
	echo "LOG FILES ARE IN:"
	echo "${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout"
fi
