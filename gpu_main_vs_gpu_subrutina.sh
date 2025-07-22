#!/bin/bash

# Nombre del archivo fuente
SRC="gpu_main_vs_gpu_subrutina.F90"

# Nombre del ejecutable
EXE="gpu_main_vs_gpu_subrutina_exec"

# Compilación con NVIDIA Fortran y soporte OpenACC
nvfortran -acc -O2 -Minfo=accel -o $EXE $SRC

# Verificar si la compilación fue exitosa
if [ $? -ne 0 ]; then
  echo "❌ Error en la compilación."
  exit 1
fi

# Nombre del archivo de salida CSV
output="gpu_main_vs_gpu_subrutina_results.csv"

# Encabezado del CSV
echo "m,n,k,time_main,time_subroutine,max_error" > "$output"

# Encabezado para impresión por pantalla
printf "%5s %5s %5s | %15s | %15s | %15s\n" "m" "n" "k" "Tiempo main (s)" "Tiempo subrut. (s)" "Error máx."
echo "-------------------------------------------------------------------------------"

# Bucle para distintas combinaciones de tamaños
for k in 100 250 500 750 1000 1500 2000 3000 5000; do
  for n in 100 250 500 750 1000 1500 2000 3000 5000; do
    for m in 100 250 500 750 1000 1500 2000 3000 5000; do

      # Ejecutar el programa y capturar salida
      output_run=$(echo "$m $n $k" | ./$EXE)

      # Extraer tiempos y error desde la salida
      t_main=$(echo "$output_run" | awk '/main:/ {print $(NF)}')
      t_sub=$(echo "$output_run" | awk '/subrutina:/ {print $(NF)}')
      error=$(echo "$output_run" | awk '/Error/ {print $(NF)}')

      # Mostrar por pantalla
      printf "%5d %5d %5d | %15.6f | %15.6f | %15.6e\n" "$m" "$n" "$k" "$t_main" "$t_sub" "$error"

      # Guardar resultados en CSV
      echo "$m,$n,$k,$t_main,$t_sub,$error" >> "$output"

    done
  done
done