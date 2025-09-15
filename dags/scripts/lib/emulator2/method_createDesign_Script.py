
import numpy as np
import pandas as pd
import json
import time

# %% Config Panel
t_duration=16.1


species_list=['Xv', 'Glucose', 'Acetate', 'DOT', 'Fluo_RFP', 'Volume'] #Model species used in the model

species_IC=[0.18, 4, 0, 100, 150, .01] #Initial states for the species listed above
glucose_IC=[3, 3, 3.5, 3.5, 4, 4, 4.5, 4.5] * 3 #Initial states for the species listed above


time_pulses=np.arange(4 + 5/60, t_duration, 10/60) #Time in hours
time_samples_columns={'col1':np.arange(.33,t_duration,1).tolist()+[t_duration],'col2':np.arange(.66,t_duration,1).tolist()+[t_duration],'col3':np.arange(.99,t_duration,1).tolist()+[t_duration]} #Time in hours
sampling_rate_DOT=2/60 #Time in hours

Noise_concentration=5 # in %
Noise_time=1 # in %

mbr_list=np.arange(19419,19443,1) #names of the bioreactors
# mbr_list=np.arange(21340,21364,1) #names of the bioreactors
Glucose_feed=[200]*len(mbr_list) # in g/l
Induction_time=[10]*len(mbr_list) #Time in hours
Inductor_conc=[1]*len(mbr_list) # 0 to 1 for now

time_execution=[]#np.arange(0,t_duration+1,1).tolist()# # leave empty for Real Time, otherwise use time in hours

acceleration=54000# =1 for real time, otherwise it multiplies time by this factor

# %% Create config
EMULATOR_config={}
# %%Parameters

EMULATOR_config['Params']=[1.56, 0.429, 0.2851, 150, .475, 0.2620, 0.257, 4278, 1.09, 1.084, 0.3078, 0.04767, 0.041, 5.14, 1.3177, 0.912]+[750]*len(mbr_list)+[90]*len(mbr_list)

# %% Fill config

Exp_list=[str(il) for il in mbr_list]
EMULATOR_config['Species_list']=species_list
EMULATOR_config['Brxtor_list']=Exp_list

n1=0
for i1 in Exp_list:
    EMULATOR_config[i1]={}
    EMULATOR_config[i1]['IC']={}
    nn=0
    for i2 in EMULATOR_config['Species_list']:
        EMULATOR_config[i1]['IC'][i2]=species_IC[nn]+0
        nn=nn+1
    EMULATOR_config[i1]['IC']['Glucose']=glucose_IC[n1]+0
    n1=n1+1
    
n2=0
for i1 in Exp_list:
    EMULATOR_config[i1]['Glucose_feed']=float(Glucose_feed[n2])
    EMULATOR_config[i1]['Induction_time']=float(Induction_time[n2])
    EMULATOR_config[i1]['Inductor_conc']=float(Inductor_conc[n2])
    
    EMULATOR_config[i1]['Pulse_profile']={'time_pulse':time_pulses.tolist(),'Feed_pulse':np.zeros(len(time_pulses.tolist())).tolist()}
    EMULATOR_config[i1]['time_sample']={}
    for i2 in EMULATOR_config['Species_list']:
        if n2<8:
            EMULATOR_config[i1]['time_sample'][i2]= time_samples_columns['col1'] 
        elif n2<16:
            EMULATOR_config[i1]['time_sample'][i2]= time_samples_columns['col2'] 
        else:
            EMULATOR_config[i1]['time_sample'][i2]= time_samples_columns['col3'] 
    n2=n2+1
    
    
    EMULATOR_config[i1]['time_sample']['DOT']=np.arange(0,t_duration+sampling_rate_DOT,sampling_rate_DOT).tolist()
                                               




EMULATOR_config['number_br']=len(mbr_list)

EMULATOR_config['time_execution']=time_execution

EMULATOR_config['Noise_concentration']=Noise_concentration/100
EMULATOR_config['Noise_time']=Noise_time/100

EMULATOR_config['acceleration']=acceleration


# %% Save design
with open('EMULATOR_config.json', "w") as outfile:
    json.dump(EMULATOR_config, outfile) 
