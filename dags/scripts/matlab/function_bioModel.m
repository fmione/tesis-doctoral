 function [fx,dF_dX,dF_dTheta] = function_bioModel(C0,TH,ut,inF)

% Get time
t_span=inF.time_iter_real;
ts=inF.time_sample_real;

% Get Parameters
index_th=inF.index_th;
TH_nominal=inF.TH_nominal;

TH1=TH_nominal;
sigma_TH1=inF.sigma_TH;
for nth=1:numel(index_th)
    th_min=TH1(index_th(nth))-1*sigma_TH1(index_th(nth));
    th_max=TH1(index_th(nth))+1*sigma_TH1(index_th(nth));
    TH1(index_th(nth))=(tanh(TH(nth)*2)+1)*(th_max-th_min)/2+th_min;
end

% Get dimensions
n_exp=inF.n_exp;

n_dim=inF.dim_brxtor;
n_meas=inF.dim_meas;

 parfor nn=1:n_exp % For each biorector
    
    time_u=inF.time_feed.(['n',num2str(nn)]);
    uu=inF.feed_profile.(['n',num2str(nn)]);
    
    t_ind=inF.time_induction.(['n',num2str(nn)]);

% Get initial conditions
C00=C0((1:n_dim)+(n_meas+n_dim)*(nn-1)); %From the complete state vector, just take bioreactor nn


% Simulate bioreactor
THbr=TH1(1:18);THbr(17)=TH1(16+nn);THbr(18)=TH1(16+n_exp+nn);% Extract the parameters for bioreactor nn
[ft] =  function_simulation(C00,THbr,inF,t_span,time_u,uu,t_ind);

% Interpolate for sampling times and create extended vector
species_index=[1,2,4,5,3];%Xv,Glc,Acetate,P,DOT
Cinterp=[];
for n_species=[1,2,3,4,5]
    Cinterp=[Cinterp;interp1(ft(:,1),ft(:,1+species_index(n_species)),ts.(['n',num2str(nn)]).(['ns',num2str(n_species)]),'pchip')];
end
CCn{nn}=[(ft(end,2:end))';Cinterp]; 

end

CC=zeros(n_exp*(n_meas+n_dim),1);
for ncc=1:numel(CCn)
    CC((1:(n_meas+n_dim))+(ncc-1)*(n_meas+n_dim),1)=CCn{ncc};%Stack the results to get the complete state vector
end
CC(CC<0)=0; 

[fx]=CC;
[dF_dX]=[];
[dF_dTheta]=[];
 end


 