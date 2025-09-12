addpath(genpath(pwd)) %Add subfolders to the path
%% Load
n_check=0;
while n_check==0
    try
    VBA_config=jsondecode(fileread(strcat(strain,'/VBA_config.json'))); %VBA settings and results
    VBA_digitalTwin=jsondecode(fileread(strcat(strain,'/VBA_digitalTwin.json'))); %VBA settings and results
    n_check=1;
    catch
    end
end

f_fname=str2func(VBA_config.inF.fname);
g_fname=str2func(VBA_config.inG.gname);
%%
% VBA_config.iter=VBA_config.iter+1;
try
VBA_config.inF.time_iter_real=VBA_config.inF.time_iter([0,1]+VBA_config.iter);
catch
end
%% Get data
db=jsondecode(fileread(VBA_config.file_name{1}));
VBA_data=method_getData(db,VBA_config);
VBA_data=method_fixData(VBA_data,VBA_config,VBA_digitalTwin);
VBA_config.inF.time_sample_real=VBA_data.time_sample_real;
VBA_config.inF.time_feed=VBA_data.time_feed_real;
VBA_config.inF.feed_profile=VBA_data.feed_profile_real;
y_exp=VBA_data.y_exp;

VBA_config.sample=VBA_data.sample;

%% Parameter estimation bypass
muX0=[];
for nn=1:VBA_config.inF.n_exp
X0_aux_all =VBA_data.x_exp;
dim_meas=VBA_config.inF.dim_meas;
X0_aux=X0_aux_all((1:dim_meas)+(nn-1)*dim_meas);

X0iter=[];
for ns=1:5
    [dtw_t,i_dtw]=unique(VBA_digitalTwin.x_prediction.(['n',num2str(nn)]).(['ns',num2str(ns)])(:,1));
    dtw=VBA_digitalTwin.x_prediction.(['n',num2str(nn)]).(['ns',num2str(ns)])(i_dtw,:);
    X0iter=[X0iter;interp1(dtw(:,1),dtw(:,2),VBA_config.inF.time_iter_real(2),'linear','extrap')];  
end
species_index=[1,2,5,3,4];
muX0=[muX0;[X0iter(species_index);0.01;X0_aux]];

end
priors.muX0=muX0;

priors.SigmaX0 =VBA_config.priors.SigmaX0*2;
priors.muTheta =VBA_config.priors.muTheta;
priors.SigmaTheta = VBA_config.priors.SigmaTheta;
VBA_config.priors = priors;

%% Save settings
n_check=0;
while n_check==0
    try
    VBA_config_js=jsonencode(VBA_config);
    fid=fopen(strcat(strain,'/VBA_config.json'),'w');
    fprintf(fid, VBA_config_js);
    fclose('all');

    VBA_log=jsondecode(fileread(strcat(strain,'/VBA_log.json')));
    VBA_log.config.(['iter',num2str(VBA_config.iter)])=VBA_config;
    VBA_log.data.(['iter',num2str(VBA_config.iter)])=VBA_data;
    VBA_log_js=jsonencode(VBA_log);
    fid=fopen(strcat(strain,'/VBA_log.json'),'w');
    fprintf(fid, VBA_log_js);
    fclose('all');
    n_check=1;
    catch
    end
end
