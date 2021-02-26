#!/bin/bash

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL
#SBATCH -J 02.1.1_run_infercnv_makeSubmitter                   #### REMEMBER TO KEEP UPDATED ####
#SBATCH --output=02.1.1_run_infercnv_makeSubmitter_%J.stdout    #### REMEMBER TO KEEP UPDATED ####
#---------------------------------------------------------------------#

# Load software modules

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
logdir=$(echo "${codedir}routs.d/04_routs/")
lognm="02.1.1_run_infercnv_makeSubmitter"              #### SAME AS SLURM JOB NAME ####
#-----------------------------------------------------------------------#

# LOCAL VARIABLES
### To pass to makeArgs ### 
# Input files root path for submitters -- $i in makeArgs will be the loop variable that will be updated
indir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/04_out/01.2.1_input_infercnv'
# output dir path 
outdir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/04_out/'
# name of output files 
jobnm1="02.1.1_run_infercnv"
# Bayes infercnv threshold
BT="0.1"
# infercnv plot output format
OF="png"

### Other ###
# root dir path for submitters' logs 
submlogdir="${codedir}submitters.d/04_submit/"
# file where arguments to be pass are
argss='/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/submitters.d/04_submit/02.1_run_infercnv_makeArgs.sh'
#-----------------------------------------------------------------------#

# SUBMITTER GENERATOR
# Pattern of COUNT files (or CELLS files) produced by 01.2_input.infercnv.R -everything but the SAMPLE ID -
args1="01_CNV_PROJECT.D/output.d/04_out/01.2.1_input_infercnv___COUNTS-"
samp=$( ls ${args1}* | cut -d'-' -f2 )
read -d" " -a  samp <<< "$samp"

for i in "${samp[@]}"
do
	## Create the bash script to execute infercnv.R with system requirenments
	subsh="${submlogdir}${jobnm1}___${i}.sh"
	echo '#!/bin/bash -l' > $subsh 
	echo >> $subsh
	echo "#SBATCH -A sens2018122" >> $subsh
	echo "#SBATCH -p core"  >> $subsh
	echo "#SBATCH -n 8" >> $subsh
	echo "#SBATCH -t 03:00:00" >> $subsh
	echo "#SBATCH -J ${jobnm1}___${i}" >> $subsh
	echo "#SBATCH --output ${jobnm1}_${i}_%J.stdout" >> $subsh
	echo "#SBATCH --mail-user=maria.arceo@ki.se" >> $subsh
	echo "#SBATCH --mail-type=ALL" >> $subsh
	echo >> $subsh
	echo "### for details see 02.1.1_run_infercnv_generator.sh ###" >> $subsh
	echo >> $subsh
	echo "module load R/4.0.0" >> $subsh
	echo "module load R_packages/4.0.0" >> $subsh
	echo >> $subsh
	echo 'echo "JOB_ID=${SLURM_JOB_ID}"' >> $subsh
	echo 'echo "JOB_NAME=${SLURM_JOB_NAME}"' >> $subsh
	echo >> $subsh
	echo "codedir=\"$codedir\"" >> $subsh
	echo "logdir=\"$logdir\"" >> $subsh
	echo "lognm=\"$jobnm1\"" >> $subsh
	echo "outnm=\"$i\"" >> $subsh
	# Pass arguments to submitter
	echo >> $subsh
	echo "indir='$indir'" >> $subsh
	echo "outdir='$outdir'" >> $subsh
	echo "jobnm1='$jobnm1'" >> $subsh
	echo "BT='$BT'" >> $subsh
	echo "OF='$OF'" >> $subsh
	echo "i='$i'" >> $subsh
	cat $argss >> $subsh
	echo >> $subsh
	# Run
	echo "# Run" >> $subsh
	echo 'if [  ! -z "$SLURM_JOB_ID" ]' >> $subsh
	echo "then" >> $subsh
	echo 'Rscript --vanilla ${codedir}/02.1_run_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 > ${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.ROUT' >> $subsh
	echo "else" >> $subsh
	echo 'Rscript --vanilla ${codedir}/02.1_run_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 > ${logdir}${lognm}_${outnm}.ROUT' >> $subsh
	echo "fi" >> $subsh
	echo "unset args1 args2 args3 args4 args5 args6 args7 args8 args9" >> $subsh
	echo >> $subsh
	echo "# Collect standard output" >> $subsh
	echo 'if [ ! -z "$SLURM_JOB_ID" ]' >> $subsh
	echo "then" >> $subsh
	echo 'mv ${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout ${logdir}' >> $subsh
	echo 'echo "LOG FILES ARE IN:"' >> $subsh
	echo 'echo "${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout"' >> $subsh 
	echo "fi" >> $subsh
	
	# Permissions
	chmod u=rwx,o=rx,g=x $subsh
done
#--------------------------------------------------------------------------------------------------#

# SUBMITTER RUN
# pattern name for submitters generated
args2="${submlogdir}${jobnm1}___"
subm=$( ls ${args2}* )
read -d" " -a  subm <<< "$subm"

for i in "${subm[@]}"
do
        sbatch ${i}
done

# I could collect jids in an array and send up to the pipeline for jid3 afterok parameter
#--------------------------------------------------------------------------------------------------#

# Collect standard output
if [ ! -z "$SLURM_JOB_ID" ]
then
	mv ${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout ${logdir}
	echo "LOG FILES ARE IN:"
	echo "${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout"
fi

echo "DONE"
