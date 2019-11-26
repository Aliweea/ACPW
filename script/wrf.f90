! parameters and operations for WRF
module WRF
    implicit none
    ! include 'netcdf.inc'

    integer, parameter :: nVars = 4
    character(len=8), parameter :: vNam(nVars) =  (/character(8)::"U", "V", "T", "MU"/) 
    integer, parameter :: we = 55, sn = 55, vert = 21               ! 经度格点数，纬度格点数，垂直格点数
    integer, parameter :: nLon(nVars) = (/we, we-1, we-1, we-1/)
    integer, parameter :: nLat(nVars) = (/sn-1, sn, sn-1, sn-1/)
    integer, parameter :: nLev(nVars) = (/vert-1, vert-1, vert-1, 1/)
    integer, parameter :: nTim(nVars) = (/1,  1,  1,  1/)

    integer, parameter :: nmax = 238356             ! m×n×l×s, 所有被叠加扰动的变量的特征维数之和
    integer, parameter :: delta = 60                ! 扰动的限制范围
    
    ! integer, parameter :: iprint = 1
    ! integer, parameter :: maxit = 50
    ! integer, parameter :: maxfc = 500
    ! double precision, parameter :: epsopt = 1.0d-06

    character(70), parameter :: work_dir = "/home/cyy/Desktop/wzn/work_dir"
    character(70), parameter :: PCA_file = trim(work_dir)//"/files/PCA.out"
    character(70), parameter :: pert_file = trim(work_dir)//"/files/pert.out"
    character(70), parameter :: adap_file = trim(work_dir)//"/files/adapValue.txt"
    character(70), parameter :: result_file = trim(work_dir)//"/files/result.txt"

contains

    subroutine init_fields()
        call system('./init.sh')
    end subroutine
    
    function adapFunction(dim, X) result(adapValue)
        integer dim
        real*4 X(dim), adapValue
        character(200) echo
        
        ! 获取符合限制的扰动，并将其写入pert_file文件
        call addPert(dim, X)
        ! 将扰动叠加到初始场上，并运行WRF模式，计算适应度值
        call system('./run.sh > log.run')

        open(1, file=result_file, status='old')
        read(1,*) adapValue
        close(1)

        write(echo,*) 'echo parameters:', X, ', adapValue: ', adapValue
        call system(echo)
	
        open(66, file=result_file, status='old', position='append')
        write(66,*) 'parameters:', X, ', adapValue: ', adapValue
        close(66)
    end function

    subroutine addPert(dim, X)
        integer dim
        real*4 X(dim)

        real*4 th_part(nmax, dim), pert(nmax)
        integer i, m, n

        ! 读取PCA文件
        open(375, file=PCA_file, form='unformatted')
        do i=1, nmax
            read(375) th_part(i,:)
        end do 
        close(375)

        ! 
        pert=0.0
        do i=1, dim
            pert = pert + th_part(:,i) * X(i) 
        end do

        ! 限制扰动
        call constrainPert(pert)

        ! 将扰动写入pert_file文件
        open (1001, file=pert_file, form='unformatted')
        m = 1
        do i = 1, nVars
            n = nLon(i) * nLat(i) * nLev(i) * nTim(i) + m - 1
            write(1001) x(m:n)
            m = n + 1
        end do
        close(1001)

    end subroutine

    subroutine constrainPert(pert)
        real*4 pert(nmax)
        real*4 sqrtsum
 
        sqrtsum = sqrt(sum(pert * pert))
        if (sqrtsum <= delta)then
            print*,'proj sqrtsum<= ',sqrtsum
            return
        else
            pert = pert * delta / sqrtsum
            print*,'proj sqrtsum>  ', sqrtsum, delta / sqrtsum
        end if
    end subroutine

end module
