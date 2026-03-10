#!/bin/bash

# 1. Parámetros
# Uso: ./hdfs-a-local.sh /ruta/en/hdfs /ruta/local/destino
RUTA_HDFS=$1
DESTINO_LOCAL=${2:-"."} # Si no se da destino, usa la carpeta actual
CONTAINER_NAME="resourcemanager"
DIR_CONTENEDOR="/opt/bd/datos/"
NOMBRE=$(basename "$RUTA_HDFS")

# 2. Validaciones iniciales
if [ -z "$RUTA_HDFS" ]; then
    echo "Uso: $0 <ruta_hdfs> [ruta_local_destino]"
    exit 1
fi

# 3. Obtención del ID del contenedor
CONTAINER_ID=$(docker ps -q -f "name=$CONTAINER_NAME" | head -n1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No se encontró el contenedor '$CONTAINER_NAME'"
    exit 1
fi

echo "--- Iniciando descarga desde HDFS ---"

# 4. Asegurar que el directorio temporal existe en el contenedor
docker exec "$CONTAINER_ID" mkdir -p "$DIR_CONTENEDOR"

# 5. Paso A: Extraer de HDFS al contenedor
# Usamos -get para obtener el archivo
echo "Extrayendo '$NOMBRE' de HDFS al contenedor..."
docker exec "$CONTAINER_ID" hdfs dfs -get -f "$RUTA_HDFS" "$DIR_CONTENEDOR"

if [ $? -ne 0 ]; then
    echo "❌ Error: No se pudo obtener el archivo de HDFS. Verifica la ruta."
    exit 1
fi

# 6. Paso B: Copiar del contenedor a la máquina local
echo "Copiando '$NOMBRE' del contenedor a la ruta local '$DESTINO_LOCAL'..."

# Verificamos si el destino local es un directorio para mantener el nombre
if [ -d "$DESTINO_LOCAL" ]; then
    DESTINO_FINAL="$DESTINO_LOCAL/$NOMBRE"
else
    DESTINO_FINAL="$DESTINO_LOCAL"
fi

docker cp "$CONTAINER_ID:$DIR_CONTENEDOR$NOMBRE" "$DESTINO_FINAL"

if [ $? -eq 0 ]; then
    echo "✅ Éxito: Archivo descargado en '$DESTINO_FINAL'"
else
    echo "❌ Error al copiar el archivo al host local."
    exit 1
fi
