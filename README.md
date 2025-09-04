# Comparison between MySQL and Neo4j Database

Complete documentation and code to reproduce the results presented in the Supplementary Material of the paper entitled: **"A property graph schema for automated metadata capture, reproducibility and knowledge discovery in high-throughput bioprocess development"**.

## Authors
Federico M. Mione $^a$, Martin F. Luna $^a$, Lucas Kaspersetz $^b$, Peter Neubauer $^b$, Ernesto C. Martinez $^a$ and M. Nicolas Cruz Bournazou $^b$.

*$^a$ INGAR (CONICET - UTN). Avellaneda 3657, Santa Fe, Argentina*<br>
*$^b$ Technische Universität Berlin, Institute of Biotechnology, Chair of Bioprocess
Engineering. Berlin, Germany*


## Reproducibility

Keep in mind that the simulation of the experiment is accelerated (1 minute of simulation = 1 hour of experimentation).

To reproduce the results, please follow these steps:

* Install [Git](https://git-scm.com/) and [Docker](https://www.docker.com/).

* Clone the repository and get the corresponding branch:

        git clone https://git.tu-berlin.de/bvt-htbd/public/property-graph-schema
        git checkout multi_exp

* Navigate to the directory created (*property-graph-schema*) and set up the Airflow service:

        docker-compose up -d airflow-init 

* Next, install all the remaining services:

        docker-compose up -d

* Please wait until the installation completes (this may take a couple of minutes), after which you should be able to access the Apache Airflow interface at http://localhost:8080/.
**Log in with user: airflow, and password: airflow.**

* Finally, Airflow variables should be set:

    * In the upper ribbon, navigate to **Admin** > **Variables**.
    * Click on **choose a file**, and locate the *variables.json* file within the *dags* directory.
    * Once the JSON file is uploaded, click on **Import variables**.
    
    **IMPORTANT**: The **variable host_path must be changed** to the actual absolute local path where the */dags* folder is located.


## Run DAG
To execute the simulation (*Multi_Emulator_DAG*), the corresponding toggle button must be activated, followed by pressing the play button for the DAG.

## Acknowledgements

We gratefully acknowledge the financial support of the German Federal Ministry of Education and Research (01DD20002A – KIWI biolab).

## License

This project is under an MIT license. See the [LICENSE](./LICENSE) file for more details.
