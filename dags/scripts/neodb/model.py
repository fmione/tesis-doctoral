from neomodel import config, StructuredNode, StructuredRel, FloatProperty, DateTimeProperty, StringProperty, IntegerProperty, JSONProperty, BooleanProperty, RelationshipTo
from neomodel.sync_.cardinality import One, OneOrMore, ZeroOrOne, ZeroOrMore
import os


host = os.environ.get("NEO4J_HOST")
port = os.environ.get("NEO4J_PORT")
user = os.environ.get("NEO4J_USER")
password = os.environ.get("NEO4J_PASSWORD")

# config.DATABASE_URL = f'bolt://{user}:{password}@{host}:{port}'
config.DATABASE_URL = f'bolt://neo4j:12345678@host.docker.internal:7687'
config.AUTO_INSTALL_LABELS = True

# -- enums
TIME_UNITS = {"h": "h", "m": "m", "s": "s"}
MEASUREMENT_TYPES = {"DOT": "DOT", "OD600": "OD600", "Biomass": "Biomass", "Acetate": "Acetate", "Glucose": "Glucose", "Volume": "Volume", "Fluo_RFP": "Fluo_RFP"}
WORKFLOW_NODE_STATUS = {"success": "success", "failed": "failed", "running": "running", "skipped": "skipped"}
WORKFLOW_NODE_TRIGGER_RULES = {"all_success": "all_success", "one_success": "one_success", "all_failed": "all_failed", "one_failed": "one_failed", 
                               "none_failed": "none_failed", "all_done": "all_done", "all_skipped": "all_skipped", "none_skipped": "none_skipped"}

# -- relationships with properties
class ExperimentPerson(StructuredRel):
    rol = StringProperty(required=True)

class ExperimentWorkflowNode(StructuredRel):
    iterations = IntegerProperty()
    time_bw_samples = IntegerProperty()
    time_first_sample = IntegerProperty()
    time_to_process_sample = IntegerProperty()
    time_bw_check_db = IntegerProperty()
    time_start_checking_db = IntegerProperty()
    time_unit = StringProperty(choices=TIME_UNITS)

class WorkflowNodeComputationalMethod(StructuredRel):
    hyperparameters = JSONProperty()

class WorkflowNodeFeedingSetpoint(StructuredRel):
    iteration = IntegerProperty()

class WorkflowNodeMeasurement(StructuredRel):
    iteration = IntegerProperty()

class WorkflowNodeModelState(StructuredRel):
    iteration = IntegerProperty()

class WorkflowNodeModelParameter(StructuredRel):
    iteration = IntegerProperty()

# -- nodes
class Experiment(StructuredNode):
    run_id = IntegerProperty(unique_index=True, required=True)   
    start_time = DateTimeProperty(required=True)
    horizon = FloatProperty(required=True) 
    horizon_unit = StringProperty(choices=TIME_UNITS, required=True) 

    objective = RelationshipTo('Objective', 'DESIGNED_FOR', cardinality=One)
    person = RelationshipTo('Person', 'RESPONSIBLE', model=ExperimentPerson, cardinality=OneOrMore)
    feeding_config = RelationshipTo('FeedingConfig', 'HAS', cardinality=ZeroOrOne)
    induction_config = RelationshipTo('InductionConfig', 'HAS', cardinality=ZeroOrOne)
    bioreactor = RelationshipTo('Bioreactor', 'INCLUDES', cardinality=OneOrMore)
    workflow_node = RelationshipTo('WorkflowNode', 'HAS_COMPUTATIONAL_WORKFLOW', model=ExperimentWorkflowNode, cardinality=One)

class Objective(StructuredNode):
    name = StringProperty(unique_index=True, required=True)
    description = StringProperty(required=True)

class Person(StructuredNode):
    name = StringProperty(unique_index=True, required=True)

class FeedingConfig(StructuredNode):
    feeding_start = FloatProperty()
    feeding_start_unit = StringProperty(choices=TIME_UNITS)
    feeding_stop = FloatProperty()
    feeding_stop_unit = StringProperty(choices=TIME_UNITS)
    feeding_frequency = FloatProperty()
    feeding_frequency_unit = StringProperty(choices=TIME_UNITS)
    minimal_feed_volume = FloatProperty()
    minimal_feed_volume_unit = StringProperty()
    maximal_feed_volume = FloatProperty()
    maximal_feed_volume_unit = StringProperty()
    increment_cumulative_feed_volume = FloatProperty()
    increment_feed_volume_unit = StringProperty()
    glc_feed_concentration = FloatProperty()
    glc_feed_concentration_unit = StringProperty()
    exponential_lower_bound = IntegerProperty()  
    exponential_upper_bound = IntegerProperty() 
    bounds_unit = StringProperty()

class InductionConfig(StructuredNode):
    induction_start = FloatProperty()
    induction_start_unit = StringProperty(choices=TIME_UNITS)
    induction_value = FloatProperty()
    induction_unit = StringProperty()
    induction_stock_solution = FloatProperty()
    induction_stock_solution_unit = StringProperty()

class Bioreactor(StructuredNode):
    exp_id = IntegerProperty(unique_index=True, required=True)    
    position = StringProperty(required=True)
    stirring_speed = FloatProperty()
    stirring_speed_unit = StringProperty()
    aeration = FloatProperty()
    aeration_type = StringProperty()    
    aeration_unit = StringProperty()

    strain = RelationshipTo('Strain', 'USES', cardinality=ZeroOrOne)
    plasmid = RelationshipTo('Plasmid', 'USES', cardinality=ZeroOrOne)

class Strain(StructuredNode):
    name = StringProperty(unique_index=True, required=True)
    supplier = StringProperty()
    acquisition_date =DateTimeProperty()
    doi = StringProperty()

class Plasmid(StructuredNode):
    name = StringProperty(unique_index=True, required=True)
    supplier = StringProperty()
    acquisition_date =DateTimeProperty()

class WorkflowNode(StructuredNode):
    task_id = StringProperty(required=True)
    trigger_rule = StringProperty(choices=WORKFLOW_NODE_TRIGGER_RULES, required=True)
    status = StringProperty(choices=WORKFLOW_NODE_STATUS, required=True)
    init_time = DateTimeProperty(required=True)
    end_time = DateTimeProperty(default=None)

    workflow_node = RelationshipTo('WorkflowNode', 'DEPENDENCY', cardinality=ZeroOrMore)
    computational_method = RelationshipTo('ComputationalMethod', 'EXECUTES', model=WorkflowNodeComputationalMethod, cardinality=ZeroOrOne)
    computational_environment = RelationshipTo('ComputationalEnvironment', 'EXECUTED_IN', cardinality=ZeroOrOne)
    feeding_setpoint = RelationshipTo('FeedingSetpoint', 'CALCULATES', model=WorkflowNodeFeedingSetpoint, cardinality=ZeroOrMore)
    measurement = RelationshipTo('Measurement', 'GETS', model=WorkflowNodeMeasurement, cardinality=ZeroOrMore)
    model_state = RelationshipTo('ModelState', 'PREDICTS', model=WorkflowNodeModelState, cardinality=ZeroOrMore)
    model_parameter = RelationshipTo('ModelParameter', 'ESTIMATES', model=WorkflowNodeModelParameter, cardinality=ZeroOrMore)

class ComputationalMethod(StructuredNode):
    name = StringProperty(unique_index=True, required=True)
    package = StringProperty()
    language = StringProperty()
    url = StringProperty()

class ComputationalEnvironment(StructuredNode):
    cpu = StringProperty(required=True)
    ram = StringProperty(required=True)
    operating_system = StringProperty(required=True)
    gpu = StringProperty()
    docker_container = BooleanProperty()
    docker_image = StringProperty()
    hpc = BooleanProperty()
    requirements = StringProperty()

class FeedingSetpoint(StructuredNode):
    time = IntegerProperty(required=True)
    time_unit = StringProperty(choices=TIME_UNITS, required=True)
    value = FloatProperty(required=True)
    value_unit = StringProperty(required=True)

    bioreactor = RelationshipTo('Bioreactor', 'FEEDS', cardinality=One)

class Measurement(StructuredNode):
    type = StringProperty(choices=MEASUREMENT_TYPES, required=True)
    time = IntegerProperty(required=True)
    time_unit = StringProperty(choices=TIME_UNITS, required=True)
    value = FloatProperty(required=True)
    value_unit = StringProperty(required=True)

    bioreactor = RelationshipTo('Bioreactor', 'SAMPLE_FROM', cardinality=One)
    device = RelationshipTo('Device', 'TAKEN_FROM', cardinality=ZeroOrOne)
    protocol_task = RelationshipTo('ProtocolTask', 'TAKEN_FOLLOWING', cardinality=ZeroOrOne)

class Device(StructuredNode):
    name = StringProperty(unique_index=True, required=True)
    model = StringProperty(required=True)
    type = StringProperty(required=True)
    manufacturer = StringProperty()
    driver = StringProperty()

class ProtocolTask(StructuredNode):
    name = StringProperty(unique_index=True, required=True)
    description = StringProperty(required=True)
    doi = StringProperty()
    steps = StringProperty()

class ModelState(StructuredNode):
    type = StringProperty(choices=MEASUREMENT_TYPES, required=True)
    time = IntegerProperty(required=True)
    time_unit = StringProperty(choices=TIME_UNITS, required=True)
    value = FloatProperty(required=True)
    value_unit = StringProperty(required=True)

    bioreactor = RelationshipTo('Bioreactor', 'PREDICTION_FOR', cardinality=One)
    model = RelationshipTo('Model', 'PART_OF', cardinality=One)

class ModelParameter(StructuredNode):
    name = StringProperty(required=True)
    unit = StringProperty()
    value = FloatProperty()
    mean = FloatProperty()
    variance = FloatProperty()

    model = RelationshipTo('Model', 'PART_OF', cardinality=One)

class Model(StructuredNode):
    name = StringProperty(unique_index=True, required=True)
    description = StringProperty(required=True)
    doi = StringProperty()

