
import sqlalchemy
import time
import os
from dotenv import load_dotenv
from neo4j import GraphDatabase


load_dotenv()


# -- mysql connection
def get_connection_url():
    host = os.environ.get("MYSQL_HOST")
    port = os.environ.get("MYSQL_PORT")
    user = os.environ.get("MYSQL_USER")
    password = os.environ.get("MYSQL_PASSWORD")
    database = os.environ.get("MYSQL_DATABASE")

    return f'mysql+mysqlconnector://{user}:{password}@{host}:{port}/{database}'


db_url = get_connection_url()
engine = sqlalchemy.create_engine(db_url, echo=False)

# -- neo4j connection
host = os.environ.get("NEO4J_HOST")
port = os.environ.get("NEO4J_PORT")
user = os.environ.get("NEO4J_USER")
password = os.environ.get("NEO4J_PASSWORD")

def get_driver():
    return GraphDatabase.driver(uri=f"bolt://{host}:{port}", auth=(user, password))

#  ---------------------- Query 1 -------------------------------
def mysql_query_min_DOT():

    conn = engine.connect()

    inittime = time.time()
    print("Starting MySQL query for min DOT...")

    sql_query = """
        SELECT r.run_id, MIN(m.measured_value) FROM measurements_experiments m 
        INNER JOIN measuring_setup ms ON m.measuring_setup_id = ms.measuring_setup_id
        INNER JOIN variable_types v ON ms.variable_type_id = v.variable_type_id
        INNER JOIN experiments e ON m.experiment_id = e.experiment_id
        INNER JOIN bioreactors b ON e.bioreactor_id = b.bioreactor_id
        INNER JOIN runs r ON b.run_id = r.run_id
        WHERE v.canonical_name = "DOT"
        GROUP BY r.run_id    
        """
    
    conn.execute(sqlalchemy.text(sql_query))
    print("MySQL query for min DOT completed.")

    finaltime = time.time()
    elapsedtime = finaltime - inittime
    conn.close()

    print(f"Elapsed time: {elapsedtime:.2f} seconds")


def neo4j_query_min_DOT():

    driver = get_driver()
    inittime = time.time()
    print("Starting Neo4j query for min DOT...")

    cypher_query = """
        MATCH (e:Experiment)-[]->(:Bioreactor)<-[]-(m:Measurement) 
        WHERE m.type="DOT" RETURN e.run_id, MIN(m.value)
        """
    
    driver.execute_query(cypher_query)
    print("Neo4j query for min DOT completed.")

    finaltime = time.time()
    elapsedtime = finaltime - inittime
    driver.close()

    print(f"Elapsed time: {elapsedtime:.2f} seconds")


#  ---------------------- Query 2 -------------------------------
def mysql_query_count_less_85_DOT():

    conn = engine.connect()

    inittime = time.time()
    print("Starting MySQL query...")

    sql_query = """
        SELECT e.experiment_id,  SUM(CASE WHEN m.measured_value < 85 THEN 1 ELSE 0 END) AS count_value
        FROM measurements_experiments m 
        INNER JOIN measuring_setup ms ON m.measuring_setup_id = ms.measuring_setup_id
        INNER JOIN variable_types v ON ms.variable_type_id = v.variable_type_id
        INNER JOIN experiments e ON m.experiment_id = e.experiment_id
        WHERE v.canonical_name = "DOT"
        GROUP BY e.experiment_id
        ORDER BY e.experiment_id ASC;  
        """
    
    conn.execute(sqlalchemy.text(sql_query))
    print("MySQL query completed.")

    finaltime = time.time()
    elapsedtime = finaltime - inittime
    conn.close()

    print(f"Elapsed time: {elapsedtime:.2f} seconds")


def neo4j_query_count_less_85_DOT():

    driver = get_driver()
    inittime = time.time()
    print("Starting Neo4j query...")

    cypher_query = """
        MATCH (b:Bioreactor)<-[]-(m:Measurement) 
        WHERE m.type="DOT" 
        WITH b, SUM(CASE WHEN m.value < 85 THEN 1 ELSE 0 END) AS count_value
        RETURN b.exp_id, count_value ORDER BY b.exp_id ASC
        """
    
    driver.execute_query(cypher_query)
    print("Neo4j query completed.")

    finaltime = time.time()
    elapsedtime = finaltime - inittime
    driver.close()

    print(f"Elapsed time: {elapsedtime:.2f} seconds")


#  ---------------------- Query 2 -------------------------------
def mysql_query_max_od600_const_DOT():

    conn = engine.connect()

    inittime = time.time()
    print("Starting MySQL query...")

    sql_query = """
        SELECT e.experiment_id, MAX(m_1.measured_value) AS maxOD
        FROM experiments e
        INNER JOIN measurements_experiments m_1 ON e.experiment_id = m_1.experiment_id
        INNER JOIN measuring_setup ms_1 ON m_1.measuring_setup_id = ms_1.measuring_setup_id
        INNER JOIN variable_types v_1 ON ms_1.variable_type_id = v_1.variable_type_id
        WHERE v_1.canonical_name = 'OD600'
            AND NOT EXISTS (
                SELECT 1
                FROM measurements_experiments m_2
                INNER JOIN measuring_setup ms_2 ON m_2.measuring_setup_id = ms_2.measuring_setup_id
                INNER JOIN variable_types v_2 ON ms_2.variable_type_id = v_2.variable_type_id
                WHERE 
                    v_2.canonical_name = 'DOT'
                    AND m_2.experiment_id = e.experiment_id
                    AND m_2.measured_value < 90
            )
        GROUP BY e.experiment_id
        ORDER BY maxOD DESC
        LIMIT 1;
        """
    
    conn.execute(sqlalchemy.text(sql_query))
    print("MySQL query completed.")

    finaltime = time.time()
    elapsedtime = finaltime - inittime
    conn.close()

    print(f"Elapsed time: {elapsedtime:.2f} seconds")


def neo4j_query_max_od600_const_DOT():

    driver = get_driver()
    inittime = time.time()
    print("Starting Neo4j query...")

    cypher_query = """
        MATCH (b:Bioreactor)<--(m1:Measurement{type:"OD600"})
        WITH b, MAX(m1.value) AS maxOD
        WHERE NOT EXISTS {
            MATCH (b)<--(m2:Measurement{type:"DOT"})
            WHERE m2.value < 90
        }
        RETURN b.exp_id, maxOD
        ORDER BY maxOD DESC
        LIMIT 1;
        """
    
    driver.execute_query(cypher_query)
    print("Neo4j query completed.")

    finaltime = time.time()
    elapsedtime = finaltime - inittime
    driver.close()

    print(f"Elapsed time: {elapsedtime:.2f} seconds")


mysql_query_min_DOT()
neo4j_query_min_DOT()
mysql_query_count_less_85_DOT()
neo4j_query_count_less_85_DOT()
mysql_query_max_od600_const_DOT()
neo4j_query_max_od600_const_DOT()
