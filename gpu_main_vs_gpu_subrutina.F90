program gpu_main_vs_gpu_subrutina
  implicit none
  integer :: m , n , k 
  real(8), allocatable :: A(:,:), B(:,:), C_m(:,:), C_s(:,:)
  real(8), allocatable :: C_diff(:,:)
  integer :: ii, jj, kk
  real(8) :: t_start, t_end
  real(8) :: max_error
  real(8) :: suma


  ! Leer dimensiones
  read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C_m(m,k), C_s(m,k))

  call random_seed()
  call random_number(A)
  call random_number(B)

  !================ GPU main ===================

  call cpu_time(t_start)

  !$acc data copyin(A,B) copyout(C_m)
 

  call cpu_time(t_end)
  print *, 'Tiempo en main: ', t_end - t_start

  !================ GPU subrutina ===================

  call cpu_time(t_start)
   
  !$acc data copyin(A,B) copyout(C_s)
  !$acc parallel loop collapse(2)
  do ii = 1, m
    do jj = 1, k
      call producto_escalar(ii, jj, A, B, C_s, n)
    end do
  end do
  !$acc end data

  call cpu_time(t_end)
  print *, 'Tiempo en subrutina: ', t_end - t_start

  !================ Validación ===================

  max_error = 0.0d0
  do ii = 1, m
    do jj = 1, k
      max_error = max(max_error, abs(C_m(ii,jj) - C_s(ii,jj)))
    end do
  end do

  print *, 'Error máximo entre CPU y GPU: ', max_error

  !================ Cálculo de diferencia y escritura ===================
 
  allocate(C_diff(m,k))

  do ii = 1, m
    do jj = 1, k
      C_diff(ii,jj) = abs(C_m(ii,jj) - C_s(ii,jj))
    end do
  end do

  !================ Escritura de archivos ===================

  open(unit=10, file="A_matrix_gpu.txt", status="unknown", action="write")
    do ii = 1, m
  write(10,'(100F10.2)') (A(ii,jj), jj=1,n)
  end do
  close(10)

  open(unit=10, file="B_matrix_gpu.txt", status="unknown", action="write")
  do ii = 1, n
    write(10,'(100F10.2)') (B(ii,jj), jj=1,k)
  end do
  close(10)

  open(unit=10, file="C_matrix_gpu.txt", status="unknown", action="write")
  do ii = 1, m
    write(10,'(100F10.2)') (C_m(ii,jj), jj=1,k)
  end do
  close(10)

  open(unit=10, file="C_diff.txt", status="unknown", action="write")
    do ii = 1, m
  write(10,'(100F10.5)') (C_diff(ii,jj), jj=1,k)
  end do
  close(10)

  !================ Liberar memoria ===================
  deallocate(A, B, C_m, C_s)

   !================ Subrutina ===================

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

end program gpu_main_vs_gpu_subrutina