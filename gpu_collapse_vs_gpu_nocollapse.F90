program gpu_collapse_vs_gpu_nocollapse
  implicit none
  integer :: m, n, k
  real(8), allocatable :: A(:,:), B(:,:), C_collapse(:,:), C_nocollapse(:,:)
  real(8) :: t_start, t_end
  integer :: ii, jj
  real(8) :: error_max

  ! Leer dimensiones
  read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C_collapse(m,k), C_nocollapse(m,k))

  call random_seed()
  call random_number(A)
  call random_number(B)

  !================ GPU sin collapse ===================
  call cpu_time(t_start)
  !$acc data copyin(A,B) copyout(C_nocollapse)
  !$acc parallel loop
  do ii = 1, m
    do jj = 1, k
      call producto_escalar(ii, jj, A, B, C_nocollapse, n)
    end do
  end do
  !$acc end data
  call cpu_time(t_end)
  print *, 'Tiempo sin collapse: ', t_end - t_start

  !================ GPU con collapse(2) ===================
  call cpu_time(t_start)
  !$acc data copyin(A,B) copyout(C_collapse)
  !$acc parallel loop collapse(2)
  do ii = 1, m
    do jj = 1, k
      call producto_escalar(ii, jj, A, B, C_collapse, n)
    end do
  end do
  !$acc end data
  call cpu_time(t_end)
  print *, 'Tiempo con collapse(2): ', t_end - t_start

  !================ Validación ===================
  error_max = maxval(abs(C_collapse - C_nocollapse))
  print *, 'Error máximo entre collapse(2) y no collapse: ', error_max

contains

  subroutine producto_escalar(ii, jj, A, B, C, n)
    integer, intent(in) :: ii, jj, n
    real(8), intent(in) :: A(:,:), B(:,:)
    real(8), intent(inout) :: C(:,:)
    integer :: kk
    real(8) :: suma

    suma = 0.0d0
    do kk = 1, n
      suma = suma + A(ii,kk) * B(kk,jj)
    end do
    C(ii,jj) = suma

  end subroutine producto_escalar
  !$acc routine(producto_escalar) seq

end program gpu_collapse_vs_gpu_nocollapse