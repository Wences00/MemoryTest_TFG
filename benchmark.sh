#!/bin/bash

# Compilar los programas
gfortran -O2 -o directo main_directo.F90
gfortran -O2 -o subrutina main_subrutina.F90

# Archivo CSV de salida
output="resultados_matlab.csv"

# Encabezado CSV
echo "m,n,k,time_directo,time_subrutina" > "$output"

# Imprime encabezado bonito en la terminal
printf "%5s %5s %5s | %15s | %15s\n" "m" "n" "k" "Tiempo directo (s)" "Tiempo subrutina (s)"
echo "-------------------------------------------------------------"

for k in 50 100 150 200 250 300 350 400 450 500; do
  for n in 50 100 150 200 250 300 350 400 450 500; do
    for m in 50 100 150 200 250 300 350 400 450 500; do
      # Obtener tiempo directo
      t1=$( (echo "$m $n $k" | ./directo) 2>&1 | awk '/Tiempo en el main directo:/ {print $(NF-1)}' )

      # Obtener tiempo subrutina
      t2=$( (echo "$m $n $k" | ./subrutina) 2>&1 | awk '/Tiempo con subrutina:/ {print $(NF-1)}' )

      # Imprimir en terminal con printf
      printf "%5d %5d %5d | %15.6f | %15.6f\n" "$m" "$n" "$k" "$t1" "$t2"

      # Guardar en CSV
      echo "$m,$n,$k,$t1,$t2" >> "$output"
    done
  done
done