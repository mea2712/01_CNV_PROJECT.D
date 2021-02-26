#!/bin/bash 

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 2
#SBATCH -t 00:15:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J 06.0.1_plot_                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=06.0.1_plot_%J.stdout    #### REMEMBER TO KEEP UPDATED ####

#---------------------------------------------------------------------------------------------------------#
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
# Input files
args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/05.0-06.0_pipe_1_05.0_plot.RData')"

# FDR threshold
args2="c(0.05)"

# File with chromosome lengths
args3="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/ChrRegions_pq')"

# Output directory
args5="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/')"

# Output files
args4="as.character('06.1.1_plot')"

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
	Rscript --vanilla ${codedir}06.1_plot.R $args1 $args2 $args3 $args4 $args5 > ${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.ROUT
else
		Rscript --vanilla ${codedir}06.1_plot.R $args1 $args2 $args3 $args4 $args5 > ${logdir}06.1.1_plot.ROUT
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
