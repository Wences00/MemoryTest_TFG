#!/bin/bash

# Nombre del archivo fuente y ejecutable
SRC="capacidad_gpu.f90"
EXE="capacidad_gpu_exec"

# Compilar con NVIDIA Fortran y OpenACC
nvfortran -acc -O2 -Minfo=accel -o $EXE $SRC

# Verificar si la compilación fue exitosa
if [ $? -ne 0 ]; then
  echo "❌ Error en la compilación."
  exit 1
fi

# Nombre del archivo CSV de resultados
output="capacidad_gpu_ext.csv"

# Escribir encabezado en el CSV
echo "m,n,k,time_ext" > "$output"

# Encabezado en pantalla
printf "%5s %5s %5s | %15s\n" "m" "n" "k" "Tiempo ext (s)"
echo "--------------------------------------------"

# Bucle de ejecución con distintas dimensiones
for k in 100 250 500 750 1000 1500 2000 3000 5000; do
  for n in 100 250 500 750 1000 1500 2000 3000 5000; do
    for m in 100 250 500 750 1000 1500 2000 3000 5000; do

      # Ejecutar el programa, pasar dimensiones por stdin
      output_run=$(echo "$m $n $k" | ./$EXE)

      # Extraer el tiempo de ejecución (última línea, último campo)
      t_ext=$(echo "$output_run" | awk '/externa/ {print $(NF)}')

      # Imprimir en pantalla
      printf "%5d %5d %5d | %15.6f\n" "$m" "$n" "$k" "$t_ext"

      # Guardar en archivo CSV
      echo "$m,$n,$k,$t_ext" >> "$output"

    done
  done
done