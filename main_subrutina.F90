! archivo: main_subrutina.F90
program multiplicacion_con_subrutina
  implicit none
  integer :: m, n, k, ii
  real :: t1, t2

  ! Leer m, n, k desde entrada estándar
  read(*,*) m, n, k

  call cpu_time(t1)
  call multiplicar_matrices(m, n, k)
  call cpu_time(t2)

  print *, "Tiempo con subrutina:", t2 - t1, "segundos"

contains

  subroutine multiplicar_matrices(m, n, k)
    implicit none
    integer, intent(in) :: m, n, k
    real, allocatable :: A(:,:), B(:,:), C(:,:)

    allocate(A(m,n), B(n,k), C(m,k))

    call random_seed()
    call random_number(A)
    call random_number(B)

    do ii = 1, 100
    C = matmul(A, B)
    enddo

    deallocate(A, B, C)
  end subroutine

  subroutine producto_escalar(ii, jj, A, B, C)
    implicit none
    integer, intent(in) :: ii, jj
    real(8), intent(in) :: A(:,:), B(:,:)
    real(8), intent(inout) :: C(:,:)
    integer :: p
    real(8) :: suma

      suma = 0.0_8
      do p = 1, size(A,2)    
        suma = suma + A(ii,p) * B(p,jj)
      end do
      C(ii,jj) = suma

  end subroutine producto_escalar


end program multiplicacion_con_subrutina