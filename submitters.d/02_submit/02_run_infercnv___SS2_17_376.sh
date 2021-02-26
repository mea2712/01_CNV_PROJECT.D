#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 8
#SBATCH -t 03:00:00
#SBATCH -J 02_run_infercnv___SS2_17_376
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

### for ddetails see 02_run_infercnv.sh ###

source /castor/project/proj/maria.d/.profile

codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d"
outnm="SS2_17_376"
args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___COUNTS-SS2_17_376')"
args2="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___CELLS-SS2_17_376')"
args3="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01_input_infercnv___GENES')"
grep 'normal' /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___CELLS-SS2_17_376 | awk '{print $2}' | sort | uniq > temp
args4="as.character('XXX')"
args5="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/')"
args6="as.character('SS2_17_376')"
args7="as.character('02_run_infercnv')"
Rscript $codedir/02_run_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 > $codedir/routs.d/02_routs/02_run_infercnv___$outnm.rout
rm temp
