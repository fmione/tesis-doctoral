# %% Import
import time
import numpy as np
import pandas as pd
import math
import json
import matplotlib.pyplot as plt


from scipy.integrate import solve_ivp
from scipy.optimize import shgo,dual_annealing,minimize
from scipy.optimize import approx_fprime
# %%
def function_simulation(ts0,Xo0,u0,THs,D0={}):
    TH1=THs[0:16]

    TH1=np.append(TH1,THs[16+int(u0[1])])
    TH1=np.append(TH1,THs[16+int(u0[1])+int(u0[2])]) 
    
    ts_start=ts0[0]
    ts_end=ts0[-1]
    
    time_pulse_all=np.array(D0['time_pulse'])
    Feed_pulse_all=np.array(D0['Feed_pulse'])
    
    t_u=time_pulse_all[(time_pulse_all>=ts_start) & (time_pulse_all<=ts_end)]
    uu=Feed_pulse_all[(time_pulse_all>=ts_start) & (time_pulse_all<=ts_end)]

    if len(t_u)==0:
        t_u=np.array([ts_start,ts_end])
        uu=np.array([0,0])
    else:
        if ts_start<t_u[0]:
            t_u=np.append(ts_start,t_u)
            uu=np.append(0,uu)
        if ts_end>t_u[-1]:
            t_u=np.append(t_u,ts_end)
            uu=np.append(uu,0)

    Xo1=Xo0.copy()
    
    tt=np.array(ts_start)
    yy=np.array([Xo1])
    yy=yy.transpose()
    
    ni=0
    
    
    for i in uu[:-1]:
        ts1=np.linspace(t_u[ni],t_u[ni+1],5+1)
        Xo1[1]=Xo1[1]+uu[ni]*1e-6*u0[0]/0.01
        t,y=intM(ts1,Xo1,u0,TH1)
        Xo1=y[:,-1].copy()

        
        tt=np.append(tt,t[1:])
        yy=np.append(yy,y[:,1:],axis=1)
        ni=ni+1

    
       
    y_pd=pd.DataFrame(yy)
    return tt,yy.transpose()

# %%    
def odeFB(t,Xo,THo,u):

    X=Xo.copy()
    TH=THo.copy()
    
    X[X<0]=0
    
    Xv=X[0]
    S=X[1]
    A=X[2]
    DOT=X[3]
    P=X[4]
    V=X[5]
    if DOT>100:
        DOT=DOT*0+100
    
        
    qs_max=TH[0]
    fracc_q_ox_max=TH[1]
    qa_max=TH[2]
    b_prod=TH[3]
    
    
    Ys_ox=TH[4]
    Ya_p=TH[5]
    Ya_c=TH[6]
    Yp=TH[7]
    Yo_ox=TH[8]
    Yo_a=TH[9]
    Yxs_of=TH[10]
    
    Ks=TH[11]
    n_ox=4
    
    Ka=TH[12]
    Ksi=TH[13]
    Kai=TH[14]
    Ko=TH[15]
    
    kla=TH[16]
    k_sensor=TH[17]
    
    DO_star=100
    H=13000#
    
    qs=qs_max*S/(S+Ks)*Ksi/(Ksi+A)#*(1-P/70)
    q_ox_max=fracc_q_ox_max*qs_max
    
    q_ox_ss=qs*(1/((qs/q_ox_max)**n_ox+1))**(1/n_ox)
    qac_ss=qa_max*A/(A+Ka)*Kai/(Kai+S)
    b_ss=Ko+(q_ox_ss*Yo_ox+qac_ss*Yo_a)*Xv*H/kla-DO_star
    c_ss=-DO_star*Ko
    DOT_ss=(-b_ss+(b_ss*b_ss-4*c_ss)**.5)/2


    # qm=qm_max*qs_max*S/(S+1e-6)*DOT_ss/(DOT_ss+Ko)
    
    q_ox=qs*(1/((qs/q_ox_max)**n_ox+1))**(1/n_ox)*DOT_ss/(DOT_ss+Ko)
    q_of=qs-q_ox
    
    qac=qa_max*A/(A+Ka)*Kai/(Kai+S)*DOT_ss/(DOT_ss+Ko)
    
    qap=q_of*Ya_p
    
    mu=q_ox*Ys_ox+qac*Ya_c+Yxs_of*q_of
    
    if t>=u[3]:
        s_prod=u[4]
    else:
        s_prod=0
    q_prod=(Yp*s_prod+b_prod)*mu
    
 


    
    dXv=(mu)*Xv
    dS=-(qs)*Xv
    dA=qap*Xv-qac*Xv
    dDOT=k_sensor*(DOT_ss-DOT)
    dP=q_prod*Xv
    dV=0
    
    dX=np.array([dXv,dS,dA,dDOT,dP,dV])
    return dX
# %%     
def intM(ts0,Xo0,u0,TH0):    

    tspan=np.array([ts0[0],ts0[-1]])
    Xo1=Xo0.tolist().copy()



    sol=solve_ivp(lambda t,y: odeFB(t,y,TH0,u0) ,tspan,Xo1,method="BDF", rtol=1e-3, atol=1e-3,t_eval=ts0)
    y_interm=sol.y
    y_interm[y_interm<0]=0
    y_return=y_interm.copy()

    return sol.t,y_return