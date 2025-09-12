if strain == 'strain1'
    design_file = 'Design_Kiwi_g1.json';
  else
    design_file = 'Design_Kiwi_g2.json';
end

addpath(genpath(pwd)) %Add subfolders to the path
design_experiment=jsondecode(fileread(design_file));%
file_name={strcat(strain, '/db_output.json')};

%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Settings inF 
inF.fname = 'function_bioModel'; 
inF.time_feed=design_experiment.time_feed;%0:5/60:12;
inF.time_iter=design_experiment.time_iter;%

% Expected sample times
inF.time_sample=design_experiment.time_sample;
%

inF.time_induction=design_experiment.time_induction;%8.5;%
inF.time_batchEnd=design_experiment.time_batchEnd;%3.5;%

inF.time_analytic=design_experiment.time_analytic;

inF.starting_time=posixtime(datetime('now'));%now;


inF.time_sample_real=[];
inF.time_feed_real=[];
inF.time_iter_real=inF.time_iter(1:2);

inF.feed_conc=design_experiment.feed_conc;

inF.n_exp=design_experiment.n_exp;%

inF.O2min=20;
inF.Xmin=3.5;
inF.GLCmax=0.5;
inF.O2safeMargin=0;
inF.XsafeMargin=0;


inF.O2safeMargin=0;

inF.feed_profile=design_experiment.feed_profile;%

inF.dim_brxtor=6;
inF.n_sample_O2=design_experiment.n_sample_O2;%
% inF.dim_meas=3+inF.n_sample_O2;
inF.dim_meas=4+inF.n_sample_O2;

VBA_config.species_list=design_experiment.species_list;


inF.TH_nominal=[1.1  .4    .4    400  ...
    .5, 0.3, 0.3, 4000, 1, 1, .3  ...
     0.05, 0.05, 5.394, 1, 1.0+100*0 ...
  [ones(1,inF.n_exp)*1000] ...
  [ones(1,inF.n_exp)*80]]';

inF.sigma_TH_dimensionless=[.75    .75    .75    1  ...
    .75, .75, .75, 1, .75 , .75, .75...
    .75, .75, .75, 1, .75  ...
  [ones(1,inF.n_exp)*1] ...
  [ones(1,inF.n_exp)*.75]]';

inF.sigma_TH=inF.sigma_TH_dimensionless.*inF.TH_nominal;

% inF.TH_nominal=[1.2846    0.2172    2.7155   80.8084    1.5969    0.2609    0.2442  441.6166    2.0421    0.0930    0.0114    4.2116    0.7483    2.3979    0.3361   14.1128...
%   533.0059  685.6879  770.8156  553.4526  649.6907  625.6718   75.0303   92.4120   84.6214   72.3069   72.7176   86.5449];


inF.index_th=1:length(inF.TH_nominal);inF.index_th([])=[];

inF.opt=0;

VBA_config.inF=inF;
%% Settings inG 
inG.gname = 'function_measModel';
inG.n_exp=inF.n_exp;
inG.dim_meas=inF.dim_meas;
% inG.scale=[];for nif=1:inF.n_exp,inG.scale=[inG.scale;[3    ones(1,1)*1.5*1   ones(1,inF.n_sample_O2)*100*inF.n_sample_O2/((inF.n_sample_O2)+1*0) ones(1,1)*.2*1]'];end %Repeat the scaling factor for each bioreactor
% inG.scale=[];for nif=1:inF.n_exp,inG.scale=[inG.scale;[.3    ones(1,1)*2.5*1   ones(1,inF.n_sample_O2)*100*inF.n_sample_O2/(sqrt(inF.n_sample_O2)+1*0) ones(1,1)*.2*.25]'];end %Repeat the scaling factor for each bioreactor

inG.scale=[];for nif=1:inF.n_exp,inG.scale=[inG.scale;[.3    ones(1,1)*2.5*1  ones(1,1)*.2*.25 ones(1,1)*10000 ones(1,inF.n_sample_O2)*100*(inF.n_sample_O2)/(sqrt(inF.n_sample_O2)+1*0) ]'];end %Repeat the scaling factor for each bioreactor
% inG.scale=[];for nif=1:inF.n_exp,inG.scale=[inG.scale;[1 1 1 1 ones(1,inF.n_sample_O2)*(sqrt(inF.n_sample_O2)) ]'];end %Repeat the scaling factor for each bioreactor

inG.phi=[];
inG.where_isnan=[];



inG.error_abs=[];for nif=1:inF.n_exp,inG.error_abs=[inG.error_abs;[.15    .25  .05  600 ones(1,inF.n_sample_O2)*2 ]'];end %Repeat the error for each bioreactor
inG.error_dimensionless=inG.error_abs./inG.scale;

VBA_config.inG=inG;
%%
VBA_config.iter=0;
VBA_config.time_limit=10;
VBA_config.verbose=0;
VBA_config.DisplayWin=1;
VBA_config.updateX0=1;


% xt0=[.2 1 100 0.0 0 .01 zeros(1,3+inF.n_sample_O2)]';
% xt0=[.2 1 100 0.0 0 .01 zeros(1,4+inF.n_sample_O2)]';
% 
% xt00=[];for nu=1:inF.n_exp,xt00=[xt00;xt0];end 

VBA_config.xt00=design_experiment.xt00;%xt00;%

VBA_config.opt_LB=[.0,0.1,0];
VBA_config.opt_UB=[10,.35,10];
VBA_config.opt_time_limit=10; 

for nu=1:inF.n_exp,for nsp=1:5,VBA_config.sample.(['n',num2str(nu)]).(['ns',num2str(nsp)])=[];end ,end  %%%nsp=5

VBA_config.file_name=file_name;
%% dim

dim.n_theta= length(inF.index_th);
dim.n_phi  = 0;
dim.n  =(inF.dim_brxtor+inF.dim_meas)*inF.n_exp; 
dim.p  =inF.dim_meas*inF.n_exp; 
VBA_config.dim=dim;

%% priors
priors.muX0 = VBA_config.xt00;
priors.SigmaX0 = [.25*diag(priors.muX0)].^2; 

priors.SigmaX0(inF.dim_brxtor:(inF.dim_brxtor+inF.dim_meas):end,inF.dim_brxtor:(inF.dim_brxtor+inF.dim_meas):end)=0;

priors.SigmaX0((inF.dim_brxtor-1):(inF.dim_brxtor+inF.dim_meas):end,(inF.dim_brxtor-1):(inF.dim_brxtor+inF.dim_meas):end)=(1.95/.25).^2*priors.SigmaX0((inF.dim_brxtor-1):(inF.dim_brxtor+inF.dim_meas):end,(inF.dim_brxtor-1):(inF.dim_brxtor+inF.dim_meas):end);
priors.SigmaX0((inF.dim_brxtor-3):(inF.dim_brxtor+inF.dim_meas):end,(inF.dim_brxtor-3):(inF.dim_brxtor+inF.dim_meas):end)=(0.05/.25).^2*priors.SigmaX0((inF.dim_brxtor-3):(inF.dim_brxtor+inF.dim_meas):end,(inF.dim_brxtor-3):(inF.dim_brxtor+inF.dim_meas):end);

priors.muTheta = ones(dim.n_theta,1)*0; 
priors.SigmaTheta = [diag(.5*ones(size(priors.muTheta)))].^2; 
priors.SigmaTheta(4,4)=.95^2;
priors.SigmaTheta(8,8)=.95^2;

iQy=1./(diag(inG.error_dimensionless).^2);iQy(iQy==Inf)=0;
% priors.iQy{1}=iQy;
% priors.SigmaTheta = [.5*diag(priors.muTheta)].^2; 
% priors.SigmaTheta(4,4)=(.95).^2;
% priors.SigmaTheta(8,8)=(.95).^2;
% priors.SigmaTheta = [diag(inF.sigma_TH_dimensionless)].^2; 




VBA_config.priors      = priors;
%% DOT sensor
for nif=1:inF.n_exp
VBA_dot.check_batch.(['n',num2str(nif)])=1;
end
VBA_dot.time_batch=design_experiment.time_batchEnd;
VBA_dot.DOT_threshold=0.7;
VBA_dot.forget_before=0.5;
VBA_dot.DOT_node_start=design_experiment.time_batchEnd.n1-0.5;

VBA_dot.DOT_max_batchtime=design_experiment.time_batchEnd.n1+1;

VBA_dot.DOT_feedforward_limit=25;
VBA_dot.time_last_exec=0;
%% Save settings
VBA_config_js=jsonencode(VBA_config);
fid=fopen(strcat(strain,'/VBA_config.json'),'w');
fprintf(fid, VBA_config_js);
fclose('all');

VBA_log.config.(['iter',num2str(VBA_config.iter)])=VBA_config;
VBA_log.data=[];
VBA_log_js=jsonencode(VBA_log);
fid=fopen(strcat(strain,'/VBA_log.json'),'w');
fprintf(fid, VBA_log_js);
fclose('all');

VBA_dot_js=jsonencode(VBA_dot);
fid=fopen(strcat(strain,'/VBA_dot.json'),'w');
fprintf(fid, VBA_dot_js);
fclose('all');