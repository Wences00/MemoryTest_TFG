#!/bin/bash

# Nombre del archivo fuente
SRC="collapse_2_vs_3.F90"

# Nombre del ejecutable
EXE="collapse_2_vs_3_exec"

# Compilación con NVIDIA Fortran y OpenACC
nvfortran -acc -O2 -Minfo=accel -o $EXE $SRC

# Verificar si la compilación fue exitosa
if [ $? -ne 0 ]; then
  echo "❌ Error en la compilación."
  exit 1
fi

# Nombre del archivo de salida CSV
output="collapse_2_vs_3_results.csv"

# Encabezado del CSV
echo "m,n,k,time_collapse2,time_collapse3,max_error" > "$output"

# Encabezado para impresión en pantalla
printf "%5s %5s %5s | %18s | %18s | %15s\n" "m" "n" "k" "Tiempo collapse(2)" "Tiempo collapse(3)" "Error máx."
echo "-------------------------------------------------------------------------------------------"

# Bucle para distintas combinaciones de tamaños
for k in 100 250 500 750 1000; do
  for n in 100 250 500 750 1000; do
    for m in 100 250 500 750 1000; do

      # Ejecutar el programa y capturar salida
      output_run=$(echo "$m $n $k" | ./$EXE)

      # Extraer tiempos y error desde la salida
      t2=$(echo "$output_run" | awk '/Tiempo en 2:/ {print $(NF)}')
      t3=$(echo "$output_run" | awk '/Tiempo en 3:/ {print $(NF)}')
      error=$(echo "$output_run" | awk '/Error máximo/ {print $(NF)}')

      # Mostrar resultados en pantalla
      printf "%5d %5d %5d | %18.6f | %18.6f | %15.6e\n" "$m" "$n" "$k" "$t2" "$t3" "$error"

      # Guardar en CSV
      echo "$m,$n,$k,$t2,$t3,$error" >> "$output"

    done
  done
done