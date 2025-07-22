program matriz_gpu_acc
  implicit none
  integer :: m , n , k 
  real(8), allocatable :: A(:,:), B(:,:), C(:,:)
  integer :: ii, jj
  real(8) :: t_start, t_end

  ! Leer m, n, k desde entrada estándar
  read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C(m,k))

  call random_seed()
  call random_number(A)
  call random_number(B)

  call cpu_time(t_start)

  !$acc data copyin(A,B) copyout(C)
  !$acc parallel loop collapse(2)
  do ii = 1, m
    do jj = 1, k
      call producto_escalar(ii, jj, A, B, C)
    end do
  end do
  !$acc end data

  call cpu_time(t_end)

  open(unit=10, file="A_matrix_gpu.txt", status="unknown", action="write")
  write(10,'(100F10.2)') A(m,n)
  close(10)

  open(unit=10, file="B_matrix_gpu.txt", status="unknown", action="write")
  write(10,'(100F10.2)') B(n,k)
  close(10)

  open(unit=10, file="C_matrix_gpu.txt", status="unknown", action="write")
  write(10,'(100F10.2)') C(m,k)
  close(10)

  deallocate(A,B,C)

  print *, 'Tiempo en GPU: ', t_end - t_start

!-------------------------------------------------------
contains
  subroutine producto_escalar(ii, jj, A, B, C)
    implicit none
    integer, intent(in) :: ii, jj
    real(8), intent(in) :: A(:,:), B(:,:)
    real(8), intent(inout) :: C(:,:)
    
        C(ii,jj) = sum(A(ii,:) * B(:,jj))

  end subroutine producto_escalar

!$acc routine(producto_escalar) seq

end program matriz_gpu_acc
