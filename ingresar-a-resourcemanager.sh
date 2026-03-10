#!/bin/bash

# 1. Definir el nombre del contenedor
CONTAINER_NAME="resourcemanager"

echo "Buscando ID del contenedor '$CONTAINER_NAME' localmente..."

# 2. Obtención del ID
# Usamos docker ps con un filtro de nombre exacto
CONTAINER_ID=$(docker ps -q -f "name=$CONTAINER_NAME" | head -n1)

# 3. Validación
if [ -z "$CONTAINER_ID" ]; then
    echo "Error: No se encontró un contenedor con el nombre '$CONTAINER_NAME'"
    exit 1
fi

echo "ID encontrado: $CONTAINER_ID. Entrando a la sesión interactiva..."

# 4. Ejecución del comando
# -i (interactivo) y -t (TTY) son lo único que necesitas localmente
docker exec -it "$CONTAINER_ID" /bin/bash
