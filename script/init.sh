#!/bin/bash

# 1. Definition
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 1.1 define path
declare -r  work_dir="/home/cyy/Desktop/wzn/work_dir"
declare -r  wrf_dir="/home/cyy/Desktop/wzn/WRFV3"

# 1.2 define run
declare -r  run="mpiexec -np 16 ./wrf.exe"

# 1.3 define wrf parameter
# time
start_time=(2013 10 05 00 00 00)
end_time=(2013 10 06 00 00 00)


# 2. Prepare for compute CNOP
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 2.1 copy and link files for initial status
cp $work_dir/files/wrfinput_d01 $work_dir/files/wrfinput_new
ln -sf $work_dir/files/wrfinput_new $work_dir/WRF/wrfinput_d01
ln -sf $work_dir/files/wrfbdy_d01 $work_dir/WRF/wrfbdy_d01
ln -sf $work_dir/files/namelist.input $work_dir/WRF/namelist.input

# 2.2 link files for wrfplus
ln -sf $wrf_dir/run/CAM_ABS_DATA $work_dir/WRF/CAM_ABS_DATA
ln -sf $wrf_dir/run/CAM_AEROPT_DATA $work_dir/WRF/CAM_AEROPT_DATA
ln -sf $wrf_dir/run/ETAMPNEW_DATA_DBL $work_dir/WRF/ETAMPNEW_DATA
ln -sf $wrf_dir/run/ETAMPNEW_DATA_DBL $work_dir/WRF/ETAMPNEW_DATA_DBL
ln -sf $wrf_dir/run/ETAMPNEW_DATA.expanded_rain $work_dir/WRF/ETAMPNEW_DATA.expanded_rain
ln -sf $wrf_dir/run/ETAMPNEW_DATA.expanded_rain_DBL $work_dir/WRF/ETAMPNEW_DATA.expanded_rain_DBL
ln -sf $wrf_dir/run/GENPARM.TBL $work_dir/WRF/GENPARM.TBL
ln -sf $wrf_dir/run/gribmap.txt $work_dir/WRF/gribmap.txt
ln -sf $wrf_dir/run/LANDUSE.TBL $work_dir/WRF/LANDUSE.TBL
ln -sf $wrf_dir/run/MPTABLE.TBL $work_dir/WRF/MPTABLE.TBL
ln -sf $wrf_dir/run/RRTM_DATA_DBL $work_dir/WRF/RRTM_DATA
ln -sf $wrf_dir/run/RRTMG_LW_DATA_DBL $work_dir/WRF/RRTMG_LW_DATA
ln -sf $wrf_dir/run/SOILPARM.TBL $work_dir/WRF/SOILPARM.TBL
ln -sf $wrf_dir/run/URBPARM.TBL $work_dir/WRF/URBPARM.TBL
ln -sf $wrf_dir/run/URBPARM_UZE.TBL $work_dir/WRF/URBPARM_UZE.TBL
ln -sf $wrf_dir/run/VEGPARM.TBL $work_dir/WRF/VEGPARM.TBL
ln -sf $wrf_dir/main/wrf.exe $work_dir/WRF/wrf.exe

# 2.3 modify filePath in ncl files
sed -i "8c\    wrf_dir = ${work_dir}" "${work_dir}/script/add_pert.ncl"
sed -i "7c\    wrf_dir = ${work_dir}" "${work_dir}/script/get_adap.ncl"


# 3 run the module 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cd $work_dir/WRF
${run} > run.log

ln -sf wrfout_d01_${start_time[0]}-${start_time[1]}-${start_time[2]}_${start_time[3]}:00:00 $work_dir/files/wrfout_start
ln -sf wrfout_d01_${end_time[0]}-${end_time[1]}-${end_time[2]}_${end_time[3]}:00:00 $work_dir/files/wrfout_end
