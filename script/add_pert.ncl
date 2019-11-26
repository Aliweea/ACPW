load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
;   add perturbation to designated region
;
begin
    ; ------------modifiable parameter------------

    wrf_dir = /home/cyy/Desktop/wzn/work_dir
    wrfinput_file = wrf_dir + "/files/wrfinput_new.nc"
    pert_file = wrf_dir + "/files/ifort.1001"
    var_names = (/"U","V","T","MU"/)
    nVar = 4
    
    ; The region in which the perturbations are added
    ist = 28
    ied = 29
    jst = 33
    jed = 41
    kst = 1
    ked = 20

    ; ------------modifiable parameter------------

    wrfinput = addfile(wrfinput_file,"rw")

    pert = addfile(pert_file,"r")

    do i=0, nVar-1
        var_name = var_names(i)

        ; read initial status in wrfinput_d01
        vc = wrfinput->$var_name$
        dsizes = dimsizes(vc)

        ; read perturbation 
        vb = fbinrecread(pert_file, i, dsizes, "double")

        ; add perturbation to designated region
        vc(0, kst:ked, jst:jed, ist:ied) = vc(0, kst:ked, jst:jed, ist:ied) + vb(0, kst:ked, jst:jed, ist:ied)
        wrfinput->$var_name$ = doubletofloat(vc)

        delete(vc)
        delete(vb)
        delete(dsizes)
    end do
end
