#!/bin/bash

# 1. Parámetros
ARCHIVO_LOCAL=$1
RUTA_HDFS=$2
CONTAINER_NAME="resourcemanager"
DIR_CONTENEDOR="/opt/bd/datos/" # Nueva ruta por defecto
NOMBRE=$(basename "$ARCHIVO_LOCAL")

# 2. Validaciones iniciales de argumentos
if [ -z "$ARCHIVO_LOCAL" ] || [ -z "$RUTA_HDFS" ]; then
    echo "Uso: $0 <archivo_local> <ruta_hdfs>"
    exit 1
fi

if [ ! -f "$ARCHIVO_LOCAL" ]; then
    echo "Error: El archivo local '$ARCHIVO_LOCAL' no existe."
    exit 1
fi

# 3. Obtención del ID del contenedor
CONTAINER_ID=$(docker ps -q -f "name=$CONTAINER_NAME" | head -n1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No se encontró el contenedor '$CONTAINER_NAME'"
    exit 1
fi

# 4. Asegurar que el directorio existe en el contenedor
echo "Verificando directorio $DIR_CONTENEDOR en el contenedor..."
docker exec "$CONTAINER_ID" mkdir -p "$DIR_CONTENEDOR"

# 5. Comprobar si el archivo ya existe en el contenedor para evitar duplicados
# Usamos 'test -f' dentro del contenedor
if docker exec "$CONTAINER_ID" test -f "$DIR_CONTENEDOR$NOMBRE"; then
    echo "Aviso: El archivo '$NOMBRE' ya existe en el contenedor. Saltando copia local."
else
    echo "Copiando '$NOMBRE' al contenedor..."
    docker cp "$ARCHIVO_LOCAL" "$CONTAINER_ID:$DIR_CONTENEDOR"
fi

# 6. Subir a HDFS
# Nota: hdfs dfs -put -f sobreescribirá en HDFS si ya existe, 
# si prefieres saltarlo también en HDFS, podemos añadir otra validación.
echo "Subiendo a HDFS en '$RUTA_HDFS'..."
docker exec "$CONTAINER_ID" hdfs dfs -put -f "$DIR_CONTENEDOR$NOMBRE" "$RUTA_HDFS"

if [ $? -eq 0 ]; then
    echo "Proceso completado con éxito."
else
    echo "Error al subir a HDFS."
    exit 1
fi
