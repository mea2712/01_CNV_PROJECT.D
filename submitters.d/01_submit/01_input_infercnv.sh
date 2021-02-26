#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J 01_input_infercnv 
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

# This code executes:
# .. castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/01_input_infercnv.R
# .. .. INPUT: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/hg38.noIntrns.highQC.allGns.counts.htsq.clltyHQ.nuclei.cncr.csv
# .. .. .. ..  2) /castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/hg38.genecodeV28Comp.ERCCeGFP.cfflinks.noIntrns.gnNms.biotyp.gtf
# .. .. .. ..  3) /castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/allSmpls_app.rds
# .. .. OUTPUT: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_temp/01_input_infercnv.rout
# .. .. .. ..   2) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01_input_infercnv___CELLS-/sample/
# .. .. .. ..   3) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01_input_infercnv___COUNTS-/sample/
# .. .. .. ..   4) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01_input_infercnv____GENES


source /castor/project/proj/maria.d/.profile

# locate code
codedir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d'

# code arguments
args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/allSmpls_app.rds')"
args2=5
args3="c('"1"'='"undifferentiated"','"2"'='"undifferentiated_CD133"','"3"'='"MSC"','"4"'='"endothelial"','"5"'='"immune"','"6"'='"NOR"','"7"'='"MYCNamp_neural"','"8"'='"undifferentiated_NOR"')"
args4="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/hg38.noIntrns.highQC.allGns.counts.htsq.clltyHQ.nuclei.cncr.csv')"
args5="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/hg38.genecodeV28Comp.ERCCeGFP.cfflinks.noIntrns.gnNms.biotyp.gtf')"
args6="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/')"
args7="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_temp/')"

# Run
Rscript $codedir/01_input_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 > $codedir/routs.d/01_routs/01_input_infercnv.rout

