#!/bin/bash

# Configuración de rutas
STACK_NAME="hadoop"
COMPOSE_PATH="/home/papiit/hadoop-config/Servidor/docker-compose.yml"
DIR_BASE="/home/papiit/hadoop-config/Servidor"
ACCION=$1

# Validar argumento de acción
if [[ "$ACCION" != "up" && "$ACCION" != "down" ]]; then
    echo "Uso: $0 {up|down}"
    exit 1
fi

# Cambiar al directorio donde está el compose para evitar errores de contexto
cd "$DIR_BASE" || { echo "Error: No se pudo acceder a $DIR_BASE"; exit 1; }

if [ "$ACCION" == "up" ]; then
    echo "--- Levantando clúster PAPIIT: $STACK_NAME ---"
    
    # Desplegar usando la ruta absoluta del archivo
    docker stack deploy -c "$COMPOSE_PATH" "$STACK_NAME"
    
    echo "Verificando servicios..."
    docker stack services "$STACK_NAME"

elif [ "$ACCION" == "down" ]; then
    echo "--- Eliminando clúster PAPIIT: $STACK_NAME ---"
    
    # 1. Orden de eliminación del stack
    docker stack rm "$STACK_NAME"
    
    # 2. Bucle de espera para asegurar que los servicios mueran
    echo "Limpiando servicios de Swarm..."
    while [ $(docker service ls --filter label=com.docker.stack.namespace=$STACK_NAME -q | wc -l) -gt 0 ]; do
        sleep 1
        echo -n "."
    done
    echo -e "\nServicios eliminados."

    # 3. Limpieza de contenedores persistentes (como alumnos-spark)
    # Filtramos por el namespace del stack para ser quirúrgicos
    CONTENEDORES_RESIDUALES=$(docker ps -a -q --filter "label=com.docker.stack.namespace=$STACK_NAME")
    if [ ! -z "$CONTENEDORES_RESIDUALES" ]; then
        echo "Forzando la eliminación de contenedores rebeldes..."
        docker rm -f $CONTENEDORES_RESIDUALES
    fi

    # 4. Limpieza de redes huérfanas
    docker network prune -f
    
    echo "✅ Clúster $STACK_NAME detenido completamente."
fi
