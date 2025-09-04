import numpy as np
import pandas as pd
import json
import time

import method_emulator
# %% 

def run_emu():
    with open('EMULATOR_state.json') as json_file:   
        EMULATOR_state = json.load(json_file)
    with open('EMULATOR_design.json') as json_file:   
        EMULATOR_design = json.load(json_file)
    with open('EMULATOR_config.json') as json_file:   
        EMULATOR_config = json.load(json_file)
    
    
            
    time_final_absolute=time.time()
    if len(EMULATOR_config['time_execution'])==0:
        time_initial_absolute=EMULATOR_state['time_absolute']
        time_start_absolute=EMULATOR_design['time_start_absolute']
        time_initial=EMULATOR_config['acceleration']*(time_initial_absolute-time_start_absolute)/3600
        time_final=EMULATOR_config['acceleration']*(time_final_absolute-time_start_absolute)/3600
    else:
        time_initial=float(EMULATOR_config['time_execution'][EMULATOR_state['iter']])
        time_final=float(EMULATOR_config['time_execution'][EMULATOR_state['iter']+1])
    
    print(time_final)
    
    EMULATOR_state['time_absolute']=time_final_absolute
    EMULATOR_state['time']=time_final
    EMULATOR_state['iter']=EMULATOR_state['iter']+1    
    
    #READ FEEDING PROFILE from db_output
    EMULATOR_design=method_emulator.read('db_emulator.json',EMULATOR_design,EMULATOR_config)    
    
    # #METHOD SIMULATION 
    # if time_final>8: #####################################################################################################################################################################
    #     EMULATOR_config['Params'][16]=250
        
        
    NEW_EMULATOR_state=method_emulator.simulate(time_initial,time_final,EMULATOR_state,EMULATOR_design,EMULATOR_config)
        
    
    #METHOD OBSERVATION
    NEW_EMULATOR_state=method_emulator.sample(time_initial,time_final,NEW_EMULATOR_state,EMULATOR_design,EMULATOR_config)
    
    #WRITE
    WR=method_emulator.write('db_emulator.json',time_initial,time_final,NEW_EMULATOR_state,EMULATOR_design,EMULATOR_config)
    
    with open('EMULATOR_state.json', "w") as outfile:
        json.dump(NEW_EMULATOR_state, outfile)                              

