#!/bin/bash -l

#SBATCH -A snic2019-3-462
#SBATCH -p core
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J 01.1_input_qc 
#SBATCH --mail-user=maria.arceo@ki.se
#SBATCH --mail-type=ALL

# This script compares input files used in the 2 runs of infercnv to make sure they are the same:
# .. .. INPUT: 1) /castor/project/proj/maria.d/output.d/KEql8.d//samples//Cells_0_51
# .. .. .. ..  2) /castor/project/proj/maria.d/output.d/KEql8.d//samples//Counts_0_51
# .. .. .. ..  3) /castor/project/proj/maria.d/output.d/KEql8.d//samples//Genes
# .. .. .. ..  4) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01_input_infercnv___CELLS-/sample/
# .. .. .. ..  5) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01_input_infercnv___COUNTS-/sample/
# .. .. .. ..  6) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01_input_infercnv____GENES
# .. .. OUTPUT: 1) /castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/01.1_input_qc


#source /castor/project/proj/maria.d/.profile

# locate code
codedir='/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d'

outdir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out"
oldir="/castor/project/proj/maria.d/output.d/KEql8.d"
newdir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out"

# out file
outfile="$outdir/01.1_input_qc"
echo "" > $outfile

samp=(SS2_17_281 SS2_17_285 SS2_17_286 SS2_17_374 SS2_17_376 SS2_17_378)

for i in "${samp[@]}"
	do
		# Get old counts file
		oldfile="$oldir/$i/Counts_0_51"
		# Get new counts file
		newfile="$newdir/01_input_infercnv___COUNTS-$i"
		# compare both files
		echo "$i" >> $outfile
		echo "old file: $oldfile" >> $outfile
		echo "new file: $newfile" >> $outfile
		if cmp -s "$oldfile" "$newfile" ; then
   			echo "### SUCCESS: Counts are identical" >> $outfile
		else
   			echo "### WARNING: Counts are different" >> $outfile
		fi
		echo "----------------------------------------------------------------------------------------------------------------------" >> $outfile
	done
echo "***************************************************************************************************************************************************" >> $outfile

for i in "${samp[@]}"
	do
		# Get old cells file
		oldfile="$oldir/$i/Cells_0_51"
		awk '{print $1}' $oldfile > temp1
		# Get new cells file
		newfile="$newdir/01_input_infercnv___CELLS-$i"
		awk '{print $1}' $newfile > temp2
		# compare both files
		echo "$i" >> $outfile
		echo "old file: $oldfile" >> $outfile
		echo "new file: $newfile" >> $outfile
		if cmp -s "$temp1" "$temp2" ; then
   			echo "### SUCCESS: Cells are identical" >> $outfile
		else
   			echo "### WARNING: Cells are different" >> $outfile
		fi
		echo "----------------------------------------------------------------------------------------------------------------------" >> $outfile
		rm  temp1 temp2
	done
echo "************************************************************************************************************************************************" >> $outfile

for i in "${samp[@]}"
	do
		# Get old cells file
		oldfile="$oldir/$i/Genes"
		# Get new cells file
		newfile="$newdir/01_input_infercnv___GENES"
		# compare both files
		echo "$i" >> $outfile
		echo "old file: $oldfile" >> $outfile
		echo "new file: $newfile" >> $outfile
		if cmp -s "$oldfile" "$newfile" ; then
   			echo "### SUCCESS: Genes are identical" >> $outfile
		else
   			echo "### WARNING: Genes are different" >> $outfile
		fi
		echo "----------------------------------------------------------------------------------------------------------------------" >> $outfile
	done


