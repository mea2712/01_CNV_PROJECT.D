#!/bin/bash -l


source /castor/project/proj/maria.d/.profile

codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d"

samp=(SS2_17_281 SS2_17_286 SS2_17_376 SS2_17_380 SS2_17_382)
for i in "${samp[@]}"
	do
		outnm=$i		
		args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_out/02_run_infercnv_"$i"__v1.0.4_0.1_1_101.d')"
		args2="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/02_data/11NBs_noMitchnd_KEql12.pagodaApp.rds')"
		args3="as.character('normal')"
		args4="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/02_temp/')"
		args5="as.character('$i')"
		args6="as.character('03.0.1_collect_results_infercnv__')"
		Rscript $codedir/03_collect_results_infercnv.R $args1 $args2 $args3 $args4 $args5 $args6 > $codedir/routs.d/02_routs/03.0.1_collect_results_infercnv___$outnm.rout
	done

