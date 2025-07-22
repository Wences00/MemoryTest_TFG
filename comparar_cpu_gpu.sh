#!/bin/bash

# Compilar 
gfortran -O2 -o cpu_exec matriz_cpu.F90
nvfortran -mp=gpu -O2 -o gpu_exec matriz_gpu.F90

# Archivo de resultados
output="resultados_gpu_vs_cpu.csv"

# Encabezado del CSV
echo "m,n,k,time_cpu,time_gpu" > "$output"

# Encabezado de terminal
printf "%5s %5s %5s | %15s | %15s\n" "m" "n" "k" "Tiempo CPU (s)" "Tiempo GPU (s)"
echo "---------------------------------------------------------------"

# Bucle de ejecución
for k in 1000 2000 3000 4000 5000 ; do
  for n in 1000 2000 3000 4000 5000 ; do
    for m in 1000 2000 3000 4000 5000 ; do

      # Ejecutar CPU
      t_cpu=$( (echo "$m $n $k" | ./cpu_exec) 2>&1 | awk '/Tiempo en CPU/ {print $(NF)}' )

      # Ejecutar GPU
      t_gpu=$( (echo "$m $n $k" | ./gpu_exec) 2>&1 | awk '/Tiempo en GPU/ {print $(NF)}' )

      # Mostrar en terminal
      printf "%5d %5d %5d | %15.6f | %15.6f\n" "$m" "$n" "$k" "$t_cpu" "$t_gpu"

      # Guardar en CSV
      echo "$m,$n,$k,$t_cpu,$t_gpu" >> "$output"

    done
  done
done