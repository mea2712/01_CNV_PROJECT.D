#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 03:00:00
#SBATCH -J 02.1.1_run_infercnv___SS2_17_281
#SBATCH --output 02.1.1_run_infercnv_SS2_17_281_%J.stdout
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

### for details see 02.1.1_run_infercnv_generator.sh ###

module load R/4.0.0
module load R_packages/4.0.0

echo "JOB_ID=${SLURM_JOB_ID}"
echo "JOB_NAME=${SLURM_JOB_NAME}"

codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/"
logdir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/routs.d/04_routs/"
lognm="02.1.1_run_infercnv"
outnm="SS2_17_281"

indir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/04_out/01.2.1_input_infercnv'
outdir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/04_out/'
jobnm1='02.1.1_run_infercnv'
BT='0.1'
OF='png'
i='SS2_17_281'
#------------------------------------------------------#
# LOCAL VARIABLES
# Input files
#args1=$(echo "\"as.character('${indir}___COUNTS-${i}')\"")  #counts
args1="as.character('${indir}___COUNTS-${i}')"  #counts
args2="as.character('${indir}___CELLS-${i}')" #cells
args3="as.character('${indir}___GENES')" #genes

# Get normal reference
args4=$(grep 'normal' ${indir}___CELLS-${i} | awk '{print $2}' | sort | uniq )
args4="c('${args4//[[:space:]]/','}')"

# output dir
args5="as.character('$outdir')"

# sample and local parameters
args6="as.character('$i')"
args7="as.character('$jobnm1')"
args8="as.character('$BT')"
args9="as.character('$OF')"
#---------------------------------------------------------#

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
#-----------------------------------------------------------------------#


# Run
if [  ! -z "$SLURM_JOB_ID" ]
then
Rscript --vanilla ${codedir}/02.1_run_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 > ${logdir}${SLURM_JOB_NAME}_${SLURM_JOB_ID}.ROUT
else
Rscript --vanilla ${codedir}/02.1_run_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 > ${logdir}${lognm}_${outnm}.ROUT
fi
unset args1 args2 args3 args4 args5 args6 args7 args8 args9

# Collect standard output
if [ ! -z "$SLURM_JOB_ID" ]
then
mv ${SLURM_JOB_NAME}_${SLURM_JOB_ID}.stdout ${logdir}
echo "LOG FILES ARE IN:"
echo "${logdir}${SLURM_JOB_NAME}${SLURM_JOB_ID}.stdout"
fi
