import numpy as np
import pandas as pd
import json
import time



# %% 
def start_emu():
    with open('db_emulator_template.json') as json_file:   
            db_emulator = json.load(json_file)
    with open('db_emulator.json', "w") as outfile:
        json.dump(db_emulator, outfile) 
    with open('EMULATOR_config.json') as json_file:   
            EMULATOR_config = json.load(json_file)
    
    brxtor_list=EMULATOR_config['Brxtor_list']
    species_list=EMULATOR_config['Species_list']
    
    EMULATOR_state={'time_absolute':time.time(),'time':0,'iter':0}
    for i1 in brxtor_list:
        EMULATOR_state[i1]={'All':{},'Sample':{},'Current':{}}
        for i2 in species_list:
            EMULATOR_state[i1]['All'][i2]={'time':[0],'Value':[EMULATOR_config[i1]['IC'][i2]]}
            EMULATOR_state[i1]['Sample'][i2]={'time':[],'Value':[]}
            EMULATOR_state[i1]['Current'][i2]=EMULATOR_config[i1]['IC'][i2]
    
    EMULATOR_design={'time_start_absolute':EMULATOR_state['time_absolute']}
    for i1 in brxtor_list:
        EMULATOR_design[i1]={}
        EMULATOR_design[i1]['Pulses']={'time_pulse':EMULATOR_config[i1]['Pulse_profile']['time_pulse'],'Feed_pulse':EMULATOR_config[i1]['Pulse_profile']['Feed_pulse']}
        
        
        EMULATOR_design[i1]['time_sample']={}
        for i2 in EMULATOR_config['Species_list']:
            EMULATOR_design[i1]['time_sample'][i2]=EMULATOR_config[i1]['time_sample'][i2]
            
        EMULATOR_design[i1]['Glucose_feed']=EMULATOR_config[i1]['Glucose_feed']
        EMULATOR_design[i1]['Induction_time']=EMULATOR_config[i1]['Induction_time']
        EMULATOR_design[i1]['Inductor_conc']=EMULATOR_config[i1]['Inductor_conc']
    
    
    with open('EMULATOR_state.json', "w") as outfile:
        json.dump(EMULATOR_state, outfile) 
        
    with open('EMULATOR_design.json', "w") as outfile:
        json.dump(EMULATOR_design, outfile) 
