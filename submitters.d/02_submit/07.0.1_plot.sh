#!/bin/bash

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 00:00:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J xxxxx_                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=xxxxx_%J.stdout    #### REMEMBER TO KEEP UPDATED ####
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
logdir=$(echo "${codedir}routs.d/02_routs/")
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
# Input files
# Pagoda embedding for 12 clusters NB
args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/11NBs_noMitchnd_KEql12.pagodaApp.rds')"
# Collected infercnv results
args2="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/05.0-06.0_pipe_1_05.0_plot.RData')"
# FDR significance threshold
arg3="c(0.05)"

#-----------------------------------------------------------------------#

# Print arguments passed
var_=$( echo "$(compgen -v | grep -i args -)" )
read -d " " -a  var_array <<< "$var_"
echo "VARIABLES EXPORTED:"
for i in ${var_array[@]}
do
	eval temp=$i
	echo "$i: $temp"
done
unset var_ var_array i temp
#-----------------------------------------------------------------------#

# Run
if [  ! -z \"$SLURM_JOB_ID\" ]
then
	Rscript --vanilla ${codedir}07.0_plot.R $args1 $args2 > ${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.ROUT
else
	Rscript --vanilla ${codedir}07.0_plot.R $args1 $args2 > ${logdir}07.0.1_plot.ROUT
fi
unset args1 args2
#-----------------------------------------------------------------------#

# Collect standard output
if [ ! -z \"$SLURM_JOB_ID\" ]
then
	mv ${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout ${logdir}
	echo "LOG FILES ARE IN:"
	echo "${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout"
fi
