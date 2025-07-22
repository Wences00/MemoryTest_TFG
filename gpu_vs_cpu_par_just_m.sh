#!/bin/bash

# Archivo fuente
SRC="gpu_vs_cpu_par_just_m.F90"

# Ejecutable
EXE="gpu_vs_cpu_par_just_m_exec"

# Compilar con NVIDIA Fortran (OpenACC)
nvfortran -acc -O2 -Minfo=accel -o $EXE $SRC

# Verificar si compiló correctamente
if [ $? -ne 0 ]; then
  echo "❌ Error en la compilación."
  exit 1
fi

# Archivo CSV de resultados
output="gpu_vs_cpu_par_just_m.csv"

# Encabezado del CSV
echo "m,n,k,time_cpu,time_gpu,max_error" > "$output"

# Encabezado en pantalla
printf "%5s %5s %5s | %15s | %15s | %15s\n" "m" "n" "k" "Tiempo CPU (s)" "Tiempo GPU (s)" "Error máx."
echo "-------------------------------------------------------------------------------"

# Bucle de ejecución
for k in 100 250 500 750 1000 1500 2000 3000 5000; do
  for n in 100 250 500 750 1000 1500 2000 3000 5000; do
    for m in 100 250 500 750 1000 1500 2000 3000 5000; do

      # Ejecutar el programa con entrada estándar
      output_run=$(echo "$m $n $k" | ./$EXE)

      # Extraer tiempos y error
      t_gpu=$(echo "$output_run" | awk '/GPU/ {print $(NF)}')
      t_cpu=$(echo "$output_run" | awk '/CPU/ {print $(NF)}')
      error=$(echo "$output_run" | awk '/Error/ {print $(NF)}')

      # Mostrar en pantalla
      printf "%5d %5d %5d | %15.6f | %15.6f | %15.6e\n" "$m" "$n" "$k" "$t_cpu" "$t_gpu" "$error"

      # Guardar en CSV
      echo "$m,$n,$k,$t_cpu,$t_gpu,$error" >> "$output"

    done
  done
done