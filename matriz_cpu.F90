! archivo: matriz_cpu
program matriz_cpu
  implicit none
  integer :: m, n, k
  real(8), allocatable :: A(:,:), B(:,:), C(:,:)
  integer :: ii, jj
  real :: t1, t2

  ! Leer m, n, k desde entrada estándar
  read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C(m,k))

  call random_seed()
  call random_number(A)
  call random_number(B)

  call cpu_time(t1)

  do ii = 1, m
    do jj = 1, k
      call producto_escalar(ii, jj, A, B, C)
    end do
  end do

  call cpu_time(t2)

  open(unit=10, file="A_matrix_cpu.txt", status="unknown", action="write")
  write(10,'(100F10.2)') A(m,n)
  close(10)

  open(unit=10, file="B_matrix_cpu.txt", status="unknown", action="write")
  write(10,'(100F10.2)') B(n,k)
  close(10)

  open(unit=10, file="C_matrix_cpu.txt", status="unknown", action="write")
  write(10,'(100F10.2)') C(m,k)
  close(10)

  deallocate(A,B,C)

  print *, "Tiempo en CPU:", t2 - t1

contains

  subroutine producto_escalar(ii, jj, A, B, C)
    implicit none
    integer, intent(in) :: ii, jj
    real(8), intent(in) :: A(:,:), B(:,:)
    real(8), intent(inout) :: C(:,:)
    
        C(ii,jj) = sum(A(ii,:) * B(:,jj))

  end subroutine producto_escalar

end program 