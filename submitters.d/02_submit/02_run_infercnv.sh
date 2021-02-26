#!/bin/bash -l

#SBATCH -A sens2018122
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 1:00:00
#SBATCH -J 02_run_infercnv
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

# This code will create:
# .. /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/submitters.d/02_submit/02_run_infercnv___/samp/.sh
# .. .. .. Each of these scripts will execute:
# .. .. .. .. /castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d/02_run_infercnv.R
# .. .. .. .. .. INPUT: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___COUNTS-/samp/
# .. .. .. .. ..        2) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/01.2_input_infercnv___CELLS-/samp/
# .. .. .. .. ..        3) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01_input_infercnv___GENES
# .. .. .. .. .. OUTPUT: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/02_run_infercnv_/samp/__v1.0.4_0.1_1_101.d

source /castor/project/proj/maria.d/.profile

# locate code
codedir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d'
indir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out'
oldir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out'

samp=(SS2_17_281 SS2_17_285 SS2_17_286 SS2_17_374 SS2_17_376 SS2_17_378 SS2_17_380 SS2_17_382)
for i in "${samp[@]}"
	do
		## Create the bash script to execute infercnv.R with system requirenments
		subsh="$codedir/submitters.d/02_submit/02_run_infercnv___$i.sh"
                echo "#!/bin/bash -l" > $subsh 
                echo >> $subsh
                echo "#SBATCH -A sens2018122" >> $subsh
                echo "#SBATCH -p core"  >> $subsh
                echo "#SBATCH -n 8" >> $subsh
                echo "#SBATCH -t 03:00:00" >> $subsh
                echo "#SBATCH -J 02_run_infercnv___$i" >> $subsh
                echo "#SBATCH --mail-user=maria.arceo@ki.se" >> $subsh
                echo "#SBATCH --mail-type=ALL" >> $subsh
                echo >> $subsh
		echo "# for ddetails see 02_run_infercnv.sh" >> $subsh
		echo >> $subsh
                echo "source /castor/project/proj/maria.d/.profile" >> $subsh
                echo >> $subsh
		echo "codedir=\"$codedir\"" >> $subsh
		echo "outnm=\"$i\"" >> $subsh
		# Input files
		echo "args1=\"as.character('$indir/01.2_input_infercnv___COUNTS-$i')\"" >> $subsh  #counts
		echo "args2=\"as.character('$indir/01.2_input_infercnv___CELLS-$i')\"" >> $subsh #cells
		echo "args3=\"as.character('$oldir/01_input_infercnv___GENES')\"" >> $subsh  #genes
		# Reference
		echo "args4=\"c('"normal_Immune_Tcells_11"','"normal_Immune_macrophages_4"')\"" >> $subsh
		# output dir
		echo "args5=\"as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/')\"" >> $subsh		
		echo "args6=\"as.character('$i')\"" >> $subsh
		echo "args7=\"as.character('02_run_infercnv')\"" >> $subsh
                echo 'Rscript $codedir/02_run_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 $args7 > $codedir/routs.d/02_routs/02_run_infercnv___$outnm.rout' >> $subsh
           	sbatch $subsh
	done
		

