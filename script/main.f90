program main
    use ACPW
    use WRF
    implicit none

    real*4 start_time,finish_time
    integer i
    character(100) echo

    open(66, file=result_file, status='new')
    write(66,*) 'start'
    close(66)

    write(echo,*) 'echo start'
    call system(echo)

    call cpu_time(start_time)
    call random_seed()

    call init_fields()
    call init_pop(adapFunction)

    do i=1,iter
        call birds_fly(adapFunction)
    end do

    write(echo,*) 'echo CNOP-P:', Pop(bestPop_idx)%X
    call system(echo)
    write(echo,*) 'echo AdapValue:', Pop(bestPop_idx)%adapValue
    call system(echo)
    write(echo,*) 'echo find CNOP-P at iteration ', bestIter
    call system(echo)

    open(66, file=result_file, status='old', position='append')
    write(66,*) 'CNOP-P:', Pop(bestPop_idx)%X, ', AdapValue:', Pop(bestPop_idx)%adapValue
    close(66)

    call cpu_time(finish_time)
    write(echo,*) 'echo end'
    call system(echo)
    write(echo,*) 'echo CPU Time =', finish_time-start_time
    call system(echo)
end