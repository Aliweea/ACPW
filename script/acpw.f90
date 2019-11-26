! function adapFunction(dime, X) result(adapValue)
!     implicit none
!     integer dime
!     real*4 X(dime), adapValue

!     print *, X
! end function

! ------------------------------------------------
! parameters and operations for ACPW
! 只需要替换计算适应度的函数
! ------------------------------------------------
module ACPW
    implicit none
    
    ! for PSO
    real*4,  parameter :: w = 0.6               ! 惯性权重
    real*4,  parameter :: c1 = 10, c2 = 20      ! 加速因子
    real*4,  parameter :: step = 0.8            ! 步长

    ! for WSA   
    real*4, parameter :: r = 0.6, s = 1.2       ! 局部优化半径和全局优化半径
    real*4, parameter :: escape = 0.25          ! 逃跑概率

    ! for ACPW
    integer, parameter :: iter = 5                      ! 迭代次数
    integer, parameter :: num = 10                      ! 粒子个数
    integer, parameter :: dime = 20                     ! 粒子维数

    real*4 :: pso_ratio = 0.5                           ! 使用PSO规则更新的粒子的比例
    real*4,  parameter :: pso_ratio_step = 0.05         ! 更新pso_ratio的步长
    real*4,  parameter :: pso_ratio_threshold = 0.1     ! 更新pso_ratio的阈值
    real*4,  parameter :: scope = 60                    ! 粒子步长

    type particle
        real*4 X(dime)          ! 坐标
        real*4 bestX(dime)      ! 适应度最好时的坐标
        real*4 V(dime)          ! 速度
        real*4 adapValue        ! 适应度
        real*4 bestAdap         ! 个体最佳适应度
    end type

    type (particle) Pop(num)            ! 粒子群
    integer :: bestIter = 0             ! 找到最优点时的迭代次数
    integer :: bestPop_idx = 0          ! 最优粒子的索引

contains

    subroutine init_pop(adapFunction)
        real*4, external :: adapFunction
        real*4 rand(dime)
        integer i

        do i=1, num
            call random_number(rand)
            Pop(i)%V = (rand - 0.5) * 0.5 * scope
            call random_number(rand)
            Pop(i)%X = (rand - 0.5) * 0.5 * scope
            Pop(i)%bestX = Pop(i)%X
            Pop(i)%adapValue = adapFunction(dime, Pop(i)%X)
            Pop(i)%bestAdap = Pop(i)%adapValue
            if (Pop(i)%adapValue > Pop(bestPop_idx)%adapValue) then
                bestPop_idx = i
            end if
        end do
    end subroutine

    subroutine birds_fly(adapFunction)
        real*4, external :: adapFunction
        real*4 rand1(dime), rand2(dime) 
        real*4 temp(dime), tempValue, dist, sub
        integer i, j, pso_cnt, state

        pso_cnt = int(pso_ratio * num)

        ! 使用PSO规则更新粒子
        do i=1, pso_cnt
            call random_number(rand1)
            call random_number(rand2)
            ! 更新速度
            Pop(i)%V = w*Pop(i)%V + c1*rand1*(Pop(i)%bestX - Pop(i)%X) + c2*rand2*(Pop(bestPop_idx)%X - Pop(i)%X) 
            ! 更新位置
            Pop(i)%X = Pop(i)%X + Pop(i)%V
        end do

        ! 使用WSA规则更新粒子
        state = 0
        do i=pso_cnt+1, num
            if (i == num) exit
            do j=i+1, num
                temp = Pop(j)%X - Pop(i)%X
                dist = sqrt(sum(temp * temp))
                if (dist < R .and. Pop(j)%adapValue > Pop(i)%adapValue) then
                    Pop(i) = Pop(j)
                    state = 1
                end if
            end do

            if (state == 0) then
                call random_number(rand1)
                Pop(i)%X = (rand1 * 2 - 1) * scope * r
            end if

            call random_number(rand1)
            if (rand1(1) > escape) then
                call random_number(rand1)
                Pop(i)%X = (rand1 * 2 - 1) * scope * s
            end if
        end do

        tempValue = Pop(bestPop_idx)%adapValue
        do i=1, num
            ! 计算适应度
            Pop(i)%adapValue = adapFunction(dime, Pop(i)%X)
            ! 更新极值
            if (Pop(i)%adapValue > Pop(i)%bestAdap) then
                Pop(i)%bestX = Pop(i)%X
                Pop(i)%bestAdap = Pop(i)%adapValue
            end if
            if (Pop(i)%adapValue > Pop(bestPop_idx)%adapValue) then
                bestPop_idx = i
                bestIter = i
            end if
        end do

        ! 更新pso_ratio
        sub = Pop(bestPop_idx)%adapValue - tempValue
        if (sub < pso_ratio_threshold) then
            pso_ratio = pso_ratio + pso_ratio_step
        else
            pso_ratio = pso_ratio - pso_ratio_step
        end if

    end subroutine

end module



