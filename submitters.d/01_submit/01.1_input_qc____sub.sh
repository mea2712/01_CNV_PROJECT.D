#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J 01.1_input_qc 
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

# This script executes:
# .. /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/01.1_input_qc.sh 

source /castor/project/proj/maria.d/.profile

# locate code
codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d"

chmod 'u+x' $codedir/01.1_input_qc.sh

bash $codedir/01.1_input_qc.sh 
