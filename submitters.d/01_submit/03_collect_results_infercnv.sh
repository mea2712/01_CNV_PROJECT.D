#!/bin/bash -l


source /castor/project/proj/maria.d/.profile

codedir="/castor/project/proj/maria.d/01_CNV_PROJECT.D/code.d"

samp=(SS2_17_281 SS2_17_285 SS2_17_286 SS2_17_374 SS2_17_376 SS2_17_378 SS2_17_382)
for i in "${samp[@]}"
	do
		outnm=$i		
		args1="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_out/02_run_infercnv_"$i"__v1.0.4_0.1_1_101.d')"
		args2="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/data.d/01_data/allSmpls_app.rds')"
		args3="as.character('normal')"
		args4="as.character('/castor/project/proj/maria.d/01_CNV_PROJECT.D/output.d/01_temp/')"
		args5="as.character('$i')"
		Rscript $codedir/03_collect_results_infercnv.R $args1 $args2 $args3 $args4 $args5 > $codedir/routs.d/01_routs/03_collect_results_infercnv___$outnm.rout
	done

