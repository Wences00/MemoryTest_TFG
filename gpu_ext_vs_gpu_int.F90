program gpu_ext_vs_gpu_int
  implicit none
  integer :: m, n, k
  real(8), allocatable :: A(:,:), B(:,:), C_int(:,:), C_ext(:,:), C_diff(:,:)
  real(8) :: t_start, t_end, max_error
  integer :: ii, jj

  ! Leer dimensiones
  read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C_int(m,k), C_ext(m,k), C_diff(m,k))

  call random_seed()
  call random_number(A)
  call random_number(B)

  !================ GPU externa ===================
  call cpu_time(t_start)
  !$acc data copyin(A,B) copyout(C_ext)
  !$acc parallel loop collapse(2)
  do ii = 1, m
    do jj = 1, k
      call producto_escalar(ii, jj, A, B, C_ext, n)
    end do
  end do
  !$acc end data
  call cpu_time(t_end)
  print *, 'Tiempo en paralelización externa: ', t_end - t_start

  !================ GPU interna ===================
  call cpu_time(t_start)
  call producto_matriz_gpu(A, B, C_int, m, n, k)
  call cpu_time(t_end)
  print *, 'Tiempo en paralelización interna: ', t_end - t_start


  !================ Validación ===================
  max_error = maxval(abs(C_int - C_ext))
  print *, 'Error máximo entre int y ext: ', max_error
  !================ Subrutina ===================
contains

  subroutine producto_matriz_gpu(A, B, C, m, n, k)
    integer, intent(in) :: m, n, k
    real(8), intent(in)  :: A(m,n), B(n,k)
    real(8), intent(out) :: C(m,k)
    integer :: ii, jj, kk
    real(8) :: suma

    !$acc parallel
    !$acc loop gang
    do ii = 1, m
    !$acc loop vector
    do jj = 1, k
        suma = 0.0d0
        do kk = 1, n
        suma = suma + A(ii,kk) * B(kk,jj)
        end do
        C(ii,jj) = suma
    end do
    end do
    !$acc end parallel
  end subroutine producto_matriz_gpu

     !================ Subrutina ===================

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
end program gpu_ext_vs_gpu_int