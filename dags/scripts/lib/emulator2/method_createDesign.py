import numpy as np
import pandas as pd
import json
import time

# %% Get data
EMULATOR_config={}
EMULATOR_config['Species_list']=['Xv','Glucose','Acetate','DOT','Fluo_RFP','Volume']
       
DF_design= pd.read_excel('Design_Kiwi.xlsx', sheet_name=0)
DF_pulses = pd.read_excel('Design_Kiwi.xlsx', sheet_name=1)
DF_samples = pd.read_excel('Design_Kiwi.xlsx', sheet_name=2)
DF_parameters = pd.read_excel('Design_Kiwi.xlsx', sheet_name=3)
DF_exec_time=pd.read_excel('Design_Kiwi.xlsx', sheet_name=4)
DF_general_config=pd.read_excel('Design_Kiwi.xlsx', sheet_name=5)

Exp_list0=DF_design['Exp'].unique().tolist()
Exp_list=[str(il) for il in Exp_list0]

EMULATOR_config['Brxtor_list']=Exp_list

for i1 in Exp_list:
    EMULATOR_config[i1]={}
    EMULATOR_config[i1]['IC']={}
    for i2 in EMULATOR_config['Species_list']:
        EMULATOR_config[i1]['IC'][i2]=float(DF_design.loc[DF_design['Exp']==int(i1)][i2])

for i1 in Exp_list:
    EMULATOR_config[i1]['Pulse_profile']={'time_pulse':DF_pulses[int(i1)][1:].tolist(),'Feed_pulse':np.zeros(len(DF_pulses[int(i1)][1:].tolist())).tolist()}
    EMULATOR_config[i1]['time_sample']={}
    for i2 in EMULATOR_config['Species_list']:
        EMULATOR_config[i1]['time_sample'][i2]= DF_samples.iloc[2:,np.array(DF_samples.iloc[0,:]==int(i1)) & np.array(DF_samples.iloc[1,:]==i2)].values.flatten().tolist()  
    sampling_rate_DOT=float(DF_general_config['DOT_sampling_rate'])/60
    EMULATOR_config[i1]['time_sample']['DOT']=np.arange(0,float(DF_design.loc[DF_design['Exp']==int(i1)]['Duration'])+sampling_rate_DOT,sampling_rate_DOT).tolist()
                                               
    EMULATOR_config[i1]['Glucose_feed']=float(DF_design.loc[DF_design['Exp']==int(i1)]['Glucose_feed'])
    EMULATOR_config[i1]['Induction_time']=float(DF_design.loc[DF_design['Exp']==int(i1)]['Induction_time'])



EMULATOR_config['Params']=DF_parameters['Value'].values.tolist()
EMULATOR_config['number_br']=len(Exp_list)

EMULATOR_config['time_execution']=DF_exec_time['Execution_time'].values.tolist()

EMULATOR_config['Noise_concentration']=float(DF_general_config['Emulator_noise_concentration'].values)/100
EMULATOR_config['Noise_time']=float(DF_general_config['Emulator_noise_time'].values)/100




with open('EMULATOR_config.json', "w") as outfile:
    json.dump(EMULATOR_config, outfile) 
