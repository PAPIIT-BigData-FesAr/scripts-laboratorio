#!/bin/bash

# 1. Configuración
# Si no pasas un argumento, por defecto usará 'dev' (o lo que prefieras)
ENVIROMENT=${1:-"Servidor"} 

echo "--- Iniciando proceso de limpieza y construcción local ($ENVIROMENT) ---"

# 2. Limpieza de Docker
echo "Limpiando volúmenes de Docker..."
docker volume prune -f

# 3. Gestión del repositorio
echo "Actualizando repositorio hadoop-config..."
rm -rf hadoop-config
git clone https://github.com/EdgarMorales07/hadoop-config

# 4. Construcción de imágenes
# Usamos un bloque para manejar errores: si un cd falla, el script se detiene
set -e 

cd hadoop-config/"$ENVIROMENT"

echo "Construyendo: Base..."
cd Base && docker build -t hadoop-base-image . && cd ..

echo "Construyendo: NameNode..."
cd NameNode && docker build -t namenode-image . && cd ..

echo "Construyendo: ResourceManager..."
cd ResourceManager && docker build -t resourcemanager-image . && cd ..

echo "Construyendo: DataNode-NodeManager..."
cd DataNode-NodeManager && docker build -t dnnm-image . && cd ..

echo "Construyendo: JupyterHub..."
cd JupyterHub && docker build -t jupyterhub . && cd ..

echo "Construyendo: AlumnosJupyterHub..."
cd AlumnosJupyterHub && docker build -t alumno-spark . && cd ..

echo "--- Proceso finalizado con éxito ---"
