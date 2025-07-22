program gpu_vs_cpu_par_interna
  implicit none
  integer :: m, n, k
  real(8), allocatable :: A(:,:), B(:,:), C_gpu(:,:), C_cpu(:,:), C_diff(:,:)
  real(8) :: t_start, t_end, max_error
  integer :: ii, jj, kk

  ! Leer dimensiones
  read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C_gpu(m,k), C_cpu(m,k), C_diff(m,k))

  call random_seed()
  call random_number(A)
  call random_number(B)

  !================ GPU computation (paralelización interna) ===================
  call cpu_time(t_start)
  call producto_matriz_gpu(A, B, C_gpu, m, n, k)
  call cpu_time(t_end)
  print *, 'Tiempo en GPU: ', t_end - t_start

  !================ CPU computation (secuencial) ===================
  call cpu_time(t_start)
  do ii = 1, m
    do jj = 1, k
      C_cpu(ii,jj) = 0.0d0
      do kk = 1, n
        C_cpu(ii,jj) = C_cpu(ii,jj) + A(ii,kk) * B(kk,jj)
      end do
    end do
  end do
  call cpu_time(t_end)
  print *, 'Tiempo en CPU: ', t_end - t_start

  !================ Validación ===================
  max_error = maxval(abs(C_gpu - C_cpu))
  print *, 'Error máximo entre CPU y GPU: ', max_error
  !================ Subrutina ===================
contains

  subroutine producto_matriz_gpu(A, B, C, m, n, k)
    integer, intent(in) :: m, n, k
    real(8), intent(in)  :: A(m,n), B(n,k)
    real(8), intent(out) :: C(m,k)
    integer :: ii, jj, kk
    real(8) :: suma

    !$acc data copyin(A,B) copyout(C)
    !$acc parallel loop collapse(2) private(kk,suma)
    do ii = 1, m
      do jj = 1, k
        suma = 0.0d0
        do kk = 1, n
          suma = suma + A(ii,kk) * B(kk,jj)
        end do
        C(ii,jj) = suma
      end do
    end do
    !$acc end data
  end subroutine producto_matriz_gpu

end program gpu_vs_cpu_par_interna