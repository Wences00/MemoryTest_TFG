program capacidad_gpu
  implicit none
  integer :: m, n, k
  real(8), allocatable :: A(:,:), B(:,:), C_ext(:,:)
  real(8) :: t_start, t_end
  integer :: ii, jj

  ! Leer dimensiones
  read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C_ext(m,k))

  call random_seed()
  call random_number(A)
  call random_number(B)

  !================ GPU computat ion (paralelización externa) ===================
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
end program capacidad_gpu