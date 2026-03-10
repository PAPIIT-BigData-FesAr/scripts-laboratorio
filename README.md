# Scripts del clúster del laboratorio de macrodatos del CIMA FES Aragón
El siguiente repositorio contiene scripts para la automatización de tareas repetitivas referentes al clúster del laboratorio de macrodatos.
***
### Actualizar imágenes
```./actualizar-imagenes.sh [Servidor|ServidorBigData|Distribuida|Monolitica]```
### Ingresar a ResourceManager
```./ingresar-a-resourcemanager.sh```
### Copiar archivos de local a HDFS
```./copiar-a-hdfs.sh <ruta-local-origen> <ruta-hdfs-destino>```
### Copiar archivos de HDFS a local
```./copiar-a-local.sh <ruta-hdfs-origen> [ruta-local-destino]```
### Levantar y detener clúster
```./interruptor-cluster.sh {up|down}```
