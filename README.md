# Tesis Doctoral - Ing. Federico Mione

Código y documentación completa para reproducir los resultados y las conclusiones de la tesis doctoral denominada **"Un enfoque basado en grafos de conocimiento y grafos acíclicos dirigidos para la automatización y la reproducibilidad de flujos de trabajo computacionales en plataformas robóticas de experimentación intensiva"**.


*Tesista*: Federico M. Mione $^a$ <br>
*Director*: Ernesto C. Martínez $^{a,b}$ <br>
*Co-Director*: M. Nicolas Cruz Bournazou $^b$ <br>

$^a$ *INGAR (CONICET - UTN). Avellaneda 3657, Santa Fe, Argentina*<br>
$^b$ *Technische Universität Berlin, Institute of Biotechnology, Chair of Bioprocess
Engineering. Berlin, Germany*

## Resumen

El objetivo central de esta tesis es demostrar que la reproducibilidad, inicialmente en su dimensión computacional relacionada al control de la experimentación, es alcanzable mediante el diseño de una infraestructura que combine la captura automatizada de datos y metadatos por medio de un orquestador de tareas, junto con un modelo de datos para almacenar el conocimiento de forma estructurada. Bajo esta premisa, se propuso y validó una arquitectura que integra Apache Airflow para la orquestación, Neo4j como base de datos orientada a grafos y PG-Schema como modelo formal para la representación de entidades y relaciones enriquecidas semánticamente.


## Vista de componentes

<img src="docs/figures/Overview.png" width=100% style="max-width: 600px !important">

## Reproducibilidad - Caso de estudio 2

Esta rama del repositorio se encuentra dedicada al Caso de estudio 2. Para acceder al Caso de estudio 1, dirigirse a la rama *case1*.

### Listado de pasos

Al tratarse de 400 simulaciones experimentales, la duración de la ejecución para este caso de estudio será de aproximadamente 5 horas.

Para reproducir los resultados, siga los siguientes pasos:

* Instalar [Git](https://git-scm.com/) y [Docker](https://www.docker.com/).

* Clonar el repositorio y ubicarse en la rama correspondiente al caso de estudio 2:

        git clone https://github.com/fmione/tesis-doctoral
        git checkout case2

* Navegar al directorio creado (*tesis-doctoral*) y desplegar el servicio inicial de Airflow con el siguiente comando:

        cd tesis-doctoral
        docker-compose up -d airflow-init 

* Luego, instalar los servicios restantes:

        docker-compose up -d

* Por favor, esperar hasta que la instalación finalice (puede demorar algunos minutos). Posteriormente, acceder a la plataforma Airflow mediante su interfaz web en la dirección http://localhost:8080/.
**Iniciar sesión con el usuario: airflow, y la contraseña: airflow.**

* Finalmente, se deben configurar algunas variables de Airflow:

    * En el panel seleccionar **Admin** > **Variables**.
    * Hacer click en **choose a file**, y seleccionar el archivo *variables.json* ubicado en el directorio *dags*.
    * Una vez que el archivo JSON se ha cargado, presionar el botón **Import variables**.
    
    **IMPORTANTE**: La **variable host_path debe ser cambiada** por la ruta absoluta disponible de forma local donde se ubica la carpeta */dags*.


## Ejecución de DAGs
Existen un único DAG para la simulación: *MultiEmulator_2.0_DAG*. Para ejecutarlo, se debe activar el boton (*toggle*) correspondiente al DAG y luego presionar el botón play.

## Herramienta de monitoreo
Para visualizar la simulación (ya sea online u offline), se puede acceder a una herramienta con ploteos en la ruta: http://localhost:8501/. Aquí se debe seleccionar el RUN ID perteneciente al experimento a visualizar, en este caso, alguno del rango 1-400.

## Licencia
Este proyecto se encuentra bajo una Licencia MIT. Visualzar el archivo [LICENSE](./LICENSE) para más detalles.

