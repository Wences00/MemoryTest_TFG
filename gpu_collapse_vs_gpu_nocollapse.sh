#!/bin/bash

# Nombre del archivo fuente y ejecutable
SRC="gpu_collapse_vs_gpu_nocollapse.F90"
EXE="gpu_collapse_vs_gpu_nocollapse_exec"

# Compilación
nvfortran -acc -O2 -Minfo=accel -o $EXE $SRC

# Verificar éxito de compilación
if [ $? -ne 0 ]; then
  echo "❌ Error en la compilación."
  exit 1
fi

# Archivo CSV de resultados
OUTPUT="collapse_vs_nocollapse_results_20multiplos.csv"
echo "m,n,k,time_nocollapse,time_collapse2,error_max" > "$OUTPUT"

# Encabezado para impresión por pantalla
printf "%5s %5s %5s | %15s | %15s | %15s\n" "m" "n" "k" "Tiempo sin collapse" "Tiempo con collapse(2)" "Error máx."
echo "-------------------------------------------------------------------------------"

# Recorrer diferentes tamaños
for m in 100 250 500 750 1000 1500 2000 2500 3000 3500; do
  for n in 8192 16384 24576 32768 40960 49152 57344 65536 73728 81920 90112 98304 106496 114688 122880 131072 139264 147456 155648 163840; do
    for k in 100 250 500 750 1000 1500 2000 2500 3000 3500; do

      # Ejecutar el programa con entrada m n k
      result=$(echo "$m $n $k" | ./$EXE)

      # Extraer resultados usando awk
      t_nocollapse=$(echo "$result" | awk '/sin collapse:/ {print $(NF)}')
      t_collapse2=$(echo "$result" | awk '/collapse\(2\):/ {print $(NF)}')
      error_max=$(echo "$result" | awk '/Error máximo/ {print $(NF)}')

      # Mostrar en pantalla
      printf "%5d %5d %5d | %15.6f | %15.6f | %15.6e\n" "$m" "$n" "$k" "$t_nocollapse" "$t_collapse2" "$error_max"

      # Guardar en CSV
      echo "$m,$n,$k,$t_nocollapse,$t_collapse2,$error_max" >> "$OUTPUT"

    done
  done
done