! archivo: main_directo.F90
program multiplicacion_directa
  implicit none
  integer, parameter :: m=1500, n=1500, k=1500
  integer :: ii
  real, allocatable :: A(:,:), B(:,:), C(:,:)
  real :: t1, t2
  call random_seed()

  ! Leer m, n, k desde entrada estándar
  ! read(*,*) m, n, k

  allocate(A(m,n), B(n,k), C(m,k))

  call cpu_time(t1)

  call random_number(A)
  call random_number(B)

  do ii = 1, 100
  C = matmul(A, B)
  enddo

  call cpu_time(t2)

  print *, "Tiempo en el main directo:", t2 - t1, "segundos"

  deallocate(A, B, C)
end program multiplicacion_directa
