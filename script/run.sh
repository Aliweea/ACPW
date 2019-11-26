#!/bin/csh
#
#        Zengni Wei NCAR/MMM 2013/10
#
setenv work_dir /home/cyy/Desktop/zllall/zll/WRF_CNOP_NEW_Fitowadj/cnop/
set run='mpiexec -np 16 ./wrf.exe'
#
# end of modification ###
#
echo "add perturbation to initial condition"
cd $work_dir
cp -r ../wrfinput_d01 .
ncl add_pert.ncl > add_pert.log

echo "run wrf_nl"
cd $work_dir/WRF
$run > nl.log
cd $work_dir
ncl get_adap.ncl > adapValue.txt


