#!/bin/bash

## Pass variables
# directory
read -p "Please enter directory path: " my_path
# script name
read -p "Please enter script name: " my_script  

## Create file
FILE=$(echo "${my_path}${my_script}")
if [ -f "$FILE"  ]
then
	echo "$FILE exists"
else
	echo '#!/bin/bash' > $FILE
	echo "" >> $FILE
fi

## Build file
echo '#SBATCH -A sens2018122' >> $FILE
echo '#SBATCH -p core' >> $FILE
echo '#SBATCH -n 1' >> $FILE
echo '#SBATCH -t 00:00:00' >> $FILE
echo '#SBATCH --mail-user=maria.arceo@ki.se' >> $FILE
echo '#SBATCH --mail-type=ALL' >> $FILE
echo '#SBATCH -J xxxxx_                   #### REMEMBER TO KEEP UPDATED ####' >> $FILE
echo '#SBATCH --output=xxxxx_%J.stdout    #### REMEMBER TO KEEP UPDATED ####' >> $FILE
echo "#---------------------------------------------------------------------#" >> $FILE
echo "" >> $FILE
echo "# Load software modules" >> $FILE
echo "module load R/x.x.x" >> $FILE
echo "module load R_packages/x.x.x" >> $FILE
echo "#---------------------------------------------------------------------#" >> $FILE
echo "" >> $FILE
echo "# slurm arguments" >> $FILE
echo 'echo "JOB_ID=${SLURM_JOB_ID}"' >> $FILE
echo 'echo "JOB_NAME=${SLURM_JOB_NAME}"' >> $FILE
echo "#-----------------------------------------------------------------------#" >> $FILE
echo "" >> $FILE
echo "# Code and logs directories" >> $FILE
echo 'codedir="/castor/project/proj/maria.d/xxxx/code.d/"' >> $FILE
echo 'logdir=$(echo "${codedir}routs.d/00_xxx/")' >> $FILE
echo "#-----------------------------------------------------------------------#" >> $FILE
echo "" >> $FILE
echo "# LOCAL VARIABLES" >> $FILE
echo "# Input files" >> $FILE
echo "args1=" >> $FILE
echo "args2=" >> $FILE
echo "args3=" >> $FILE
echo "#-----------------------------------------------------------------------#" >> $FILE
echo "" >> $FILE
echo "# Print arguments passed" >> $FILE
echo 'var_=$( echo "$(compgen -v | grep -i 'args' -)" )' >> $FILE
echo 'read -d " " -a  var_array <<< "$var_"' >> $FILE
echo 'echo "VARIABLES EXPORTED:"' >> $FILE
echo 'for i in ${var_array[@]}' >> $FILE
echo "do" >> $FILE
echo 'eval temp='$'$i\necho "$i: $temp"' >> $FILE
echo "done" >> $FILE
echo "unset var_ var_array i temp" >> $FILE
echo "#-----------------------------------------------------------------------#" >> $FILE
echo "" >> $FILE
echo "# Run" >> $FILE
echo 'if [  ! -z "$SLURM_JOB_ID" ]' >> $FILE
echo "then" >> $FILE
echo 'Rscript --vanilla ${codedir}xxxx.R $args1 $args2 $args3 > ${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.ROUT' >> $FILE
echo "else" >> $FILE
echo 'Rscript --vanilla ${codedir}xxxxx.R $args1 $args2 $args3 > ${logdir}xxxxx.ROUT' >> $FILE
echo "fi" >> $FILE
echo "unset args1 args2 args3" >> $FILE
echo "#-----------------------------------------------------------------------#" >> $FILE
echo "" >> $FILE
echo "# Collect standard output" >> $FILE
echo 'if [ ! -z "$SLURM_JOB_ID" ]' >> $FILE
echo "then" >> $FILE
echo 'mv ${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout ${logdir}' >> $FILE
echo 'echo "LOG FILES ARE IN:"' >> $FILE
echo 'echo "${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout"' >> $FILE
echo "fi" >> $FILE

# Set file permissions
chmod u=rwx,og=rx $FILE
