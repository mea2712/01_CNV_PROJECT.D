#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 12:00:00
#SBATCH -J 04_CNVkariotype_PLOT
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

# This code will create executes:
# .. .. .. .. /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/04_CNVkariotype.R
# .. .. .. .. .. INPUT: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/03_collect_results_infercnv__/args2/
# .. .. .. .. .. OUTPUT: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/04.0.0_CNVkariotype_plot1__/args2/.png
# .. .. .. .. ..         2) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/04.0.0_CNVkariotype_plot2__/args2/.png 
# .. .. .. .. ..         3) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/04.0.0_CNVkariotype_plot3__/args2/.png 
# .. .. .. .. ..         4) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/04.0.0_CNVkariotype_plot4__/args2/.png 
# .. .. .. .. ..         5) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/04.0.0_CNVkariotype_plot.RData
# A dump of the code is in /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/routs.d/02_routs/04.0.0/1_CNVkariotype_plot.rout
# .. 
source /castor/project/proj/maria.d/.profile

# locate code
codedir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d'

# Script arguments
args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/03_collect_results_infercnv__')"
args2="c('"SS2_17_285"','"SS2_17_374"','"SS2_17_378"')"
# For each of the samples in args2 enter an array of reference CNV positions [chromosome,start,end,state]. 
# If there's none, enter 0. State = L for loss and G for gain
args3="c('"chr1"','"chr11"','"chr17"','"chr2"')"
args4="c(0,0,29400000,0,0,0,0,0,0,0,0,0)"
#args5="c(549000000,83257441,93900000, 28400000,0,0,0,0,0,0,93900000)"  ### fix ###
args5="as.character('NULL')"
args6="c('"L"','"L"','"G"','"G"')"
args7="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/')"
args8="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/')"
args9="as.character('04.0.0_CNVkariotype_plot')"

Rscript $codedir/04_CNVkariotype_PLOT.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 > $codedir/routs.d/02_routs/04.0.0.0_CNVkariotype_plot.rout


args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/03.0.1_collect_results_infercnv__')"
args2="c('"SS2_17_281"','"SS2_17_286"','"SS2_17_376"','"SS2_17_380"','"SS2_17_382"')"
args3="c('"chr1"','"chr11"','"chr17"','"chr2"')"
args4="c(0,0,29400000,0,0,0,0,0,0,0,0,0)"
args5="as.character('NULL')"
args6="c('"L"','"L"','"G"','"G"')"
args7="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_plots/')"
args8="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/')"
args9="as.character('04.0.0_CNVkariotype_plot')"

Rscript $codedir/04_CNVkariotype_PLOT.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 $args8 $args9 > $codedir/routs.d/02_routs/04.0.0.1_CNVkariotype_plot.rout

