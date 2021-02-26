#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J 01_input_infercnv 
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

# This code executes:
# .. castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/01.2_input_infercnv.R -- creates input files to run infercnv using 'Tcells'+'macrophages' as references --
# .. .. INPUT: 
# .. .. .. ..  2) castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/hg38.noIntrns.highQC.allGns.counts.htsq.clltyHQ.11NBs.noMitchnd.csv
# .. .. .. ..  3) /castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/11NBs_noMitchnd_KEql12.pagodaApp.rds
# .. .. OUTPUT: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/01.2_input_infercnv.rout
# .. .. .. ..   2) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___CELLS-/sample/
# .. .. .. ..   3) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___COUNTS-/sample/



source /castor/project/proj/maria.d/.profile

# locate code
codedir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d'

# code arguments
args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/11NBs_noMitchnd_KEql12.pagodaApp.rds')"
args2="c(4,11)"
args3="c('"1"'='"Cldn11_transAct_1"','"2"'='"Apoptosis_2"','"3"'='"MSC_3"','"4"'='"Immune_macrophages_4"','"5"'='"Endothelial_5"','"6"'='"Apoptosis_6"','"7"'='"NORadrenergic_7"','"8"'='"Cldn11_8"','"9"'='"MycnAlkAmp_9"','"10"'='"NORadrenergic_10"','"11"'='"Immune_Tcells_11"','"12"'='"NORadrenergic_12"')"
args4="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/hg38.noIntrns.highQC.allGns.counts.htsq.clltyHQ.11NBs.noMitchnd.csv')"
args5="as.character('NULL')"
args6="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/')"
args7="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/')"

# Run
Rscript $codedir/01.2_input_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 > $codedir/routs.d/02_routs/01.2_input_infercnv.rout

