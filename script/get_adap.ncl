load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    ; ------------modifiable parameter------------

    wrf_dir = /home/cyy/Desktop/wzn/work_dir
    wrfout1 = wrf_dir + "/files/wrfout_start.nc"
    wrfout2 = wrf_dir + "/files/wrfout_end.nc"
    result_file = wrf_dir + "/files/adapValue.txt"

    cp = 1005.7 ; 定压比热容
    ra = 287.04 ; 干燥空气的气体常数
    tr = 270    ; 参考温度
    pr = 100    ; 参考压强

    ; ------------modifiable parameter------------

    wrfout1 = addfile(wrfout1,"r")
    u1  = wrfout1->$"U"$
    v1  = wrfout1->$"V"$
    t1  = wrfout1->$"T"$
    mu1 = wrfout1->$"MU"$

    wrfout2 = addfile(wrfout2,"r")
    u2  = wrfout2->$"U"$
    v2  = wrfout2->$"V"$
    t2  = wrfout2->$"T"$
    mu2 = wrfout2->$"MU"$

    adapValue = sum((u2-u1)^2) + sum((v2-v1)^2) + cp/tr*sum((t2-t1)^2) + ra*tr*sum((mu2-mu1)^2)/(pr^2)

    asciiwrite (result_file, adapValue)

end