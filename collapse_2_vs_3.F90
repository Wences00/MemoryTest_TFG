program collapse_2_vs_3
  implicit none
  integer :: m , n , k 
  real(8), allocatable :: A(:,:), B(:,:), C_2(:,:), C_3(:,:)
  real(8), allocatable :: C_diff(:,:)
  integer :: ii, jj, kk
  real(8) :: t_start, t_end
  real(8) :: max_error
  real(8) :: suma


  ! Leer dimensiones
  read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C_2(m,k), C_3(m,k))

  call random_seed()
  call random_number(A)
  call random_number(B)

  !================ 2 computation ===================

  call cpu_time(t_start)

  !$acc data copyin(A,B) copyout(C_2)
  !$acc parallel loop collapse(2) private(kk)
  do ii = 1, m
    do jj = 1, k
      suma = 0.0d0
      do kk = 1, n
        suma = suma + A(ii,kk) * B(kk,jj)
      end do
      C_2(ii,jj) = suma
    end do
  end do
  !$acc end data

  call cpu_time(t_end)
  print *, 'Tiempo en 2: ', t_end - t_start

  !================ 3 computation ===================

  call cpu_time(t_start)
   
  !$acc data copyin(A,B) copyout(C_3)
  !$acc parallel loop collapse(3) reduction(+:suma)
  do ii = 1, m
  do jj = 1, k
      do kk = 1, n
      suma = suma + A(ii,kk) * B(kk,jj)
      end do
      C_3(ii,jj) = suma
      suma = 0.0d0
  end do
  end do
  !$acc end data

  call cpu_time(t_end)
  print *, 'Tiempo en 3: ', t_end - t_start

  !================ Validación ===================

  max_error = 0.0d0
  do ii = 1, m
    do jj = 1, k
      max_error = max(max_error, abs(C_2(ii,jj) - C_3(ii,jj)))
    end do
  end do

  print *, 'Error máximo entre 2 y 3: ', max_error

  !================ Cálculo de diferencia y escritura ===================
 
  allocate(C_diff(m,k))

  do ii = 1, m
    do jj = 1, k
      C_diff(ii,jj) = abs(C_2(ii,jj) - C_3(ii,jj))
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
    write(10,'(100F10.2)') (C_2(ii,jj), jj=1,k)
  end do
  close(10)

  open(unit=10, file="C_diff.txt", status="unknown", action="write")
    do ii = 1, m
  write(10,'(100F10.5)') (C_diff(ii,jj), jj=1,k)
  end do
  close(10)

  !================ Liberar memoria ===================
  deallocate(A, B, C_2, C_3)

end program collapse_2_vs_3