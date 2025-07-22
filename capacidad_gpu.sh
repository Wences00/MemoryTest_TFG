#!/bin/bash

# Nombre del ejecutable y archivo fuente
EXE="capacidad_gpu"
SRC="capacidad_gpu.F90"
CSV="resultados_capacidad_gpu.csv"

# Compilar el código
echo "Compilando..."
nvfortran -acc -Minfo=accel "$SRC" -o "$EXE"

# Verificar si compiló correctamente
if [[ $? -ne 0 ]]; then
    echo "❌ Error en la compilación."
    exit 1
fi

# Fijar m y k
m=256
k=256

# Encabezado del CSV
echo "m,n,k,tiempo_s" > "$CSV"

# Probar múltiplos de 8192 (n = 8192 * i)
for i in {1..1000}; do
    n=$((8192 * i))
    echo "▶️ Ejecutando con n = $n (m=$m, k=$k)"
    
    # Ejecutar el programa y capturar el tiempo
    tiempo=$(echo "$m $n $k" | ./"$EXE" | grep "Tiempo" | awk '{print $5}')
    
    # Escribir en el CSV
    echo "$m,$n,$k,$tiempo" >> "$CSV"
done

echo "✅ Pruebas completadas. Resultados en: $CSV"