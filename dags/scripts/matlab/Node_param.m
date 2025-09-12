addpath(genpath(pwd)) %Add subfolders to the path
addpath(genpath("/home/matlab/Documents/MATLAB/Add-Ons/VBA-toolbox"))


%% Load

VBA_config=jsondecode(fileread(strcat(strain,'/VBA_config.json'))); 
VBA_digitalTwin=jsondecode(fileread(strcat(strain,'/VBA_digitalTwin.json'))); 

f_fname=str2func(VBA_config.inF.fname);
g_fname=str2func(VBA_config.inG.gname);

%% Iters

VBA_config.inF.time_iter_real=VBA_config.inF.time_iter([0,1]+VBA_config.iter);

if VBA_config.iter>1
VBA_config.updateX0=0;
end

%% Get data
db=jsondecode(fileread(VBA_config.file_name{1}));
%%
%Re scale
VBA_data0=method_getData(db,VBA_config);isYout=VBA_data0.where_isnan;

VBA_data0=method_fixData(VBA_data0,VBA_config,VBA_digitalTwin);

X_data=VBA_data0.x_exp(1:VBA_config.inF.dim_meas:end);
Glc_data=VBA_data0.x_exp(2:VBA_config.inF.dim_meas:end);
Ac_data=VBA_data0.x_exp(3:VBA_config.inF.dim_meas:end);
P_data=VBA_data0.x_exp(4:VBA_config.inF.dim_meas:end);

inG=VBA_config.inG;inF=VBA_config.inF;
inG.scale=[];for nif=1:inF.n_exp,inG.scale=[inG.scale;[max(X_data)+.1  max(Glc_data)+.1 max(Ac_data)+.1 max(P_data)+.1 ones(1,inF.n_sample_O2)*100*(inF.n_sample_O2)/(sqrt(inF.n_sample_O2)+1*0)+.1 ]'];end

inG.error_dimensionless=VBA_config.inG.error_abs./inG.scale;

iQy{1}=1./(diag(inG.error_dimensionless).^2);iQy{1}(iQy{1}==Inf)=0;%
VBA_config.priors.iQy=iQy;

inG.phi=[];
VBA_config.inG=inG;

%% Read data
VBA_data=method_getData(db,VBA_config);

isYout=VBA_data.where_isnan;

% VBA_config.inF.starting_time=VBA_data.starting_time;
VBA_data=method_fixData(VBA_data,VBA_config,VBA_digitalTwin);
VBA_config.inG.where_isnan=VBA_data.where_isnan;

VBA_config.inF.time_sample_real=VBA_data.time_sample_real;
VBA_config.inF.time_feed=VBA_data.time_feed_real;
VBA_config.inF.feed_profile=VBA_data.feed_profile_real;


y_exp=VBA_data.y_exp;
VBA_config.sample=VBA_data.sample;
VBA_config.isYout=isYout;

%% Parameter estimation
% 
batch_time_min=2;% RESET AFTER FIRST ITER
if (batch_time_min >= VBA_config.inF.time_iter_real(1)) && (batch_time_min <= VBA_config.inF.time_iter_real(2)) %RESET Variance after induction
VBA_config.priors.SigmaTheta = [diag(.5*ones(size(VBA_config.priors.muTheta)))].^2; 
VBA_config.priors.SigmaTheta(4,4)=.95^2;
VBA_config.priors.SigmaTheta(8,8)=.95^2;
end
%%%%%%%

batch_time_min=min(cell2mat((struct2cell(VBA_config.inF.time_batchEnd)))); % RESET AFTER BATCH
if (batch_time_min >= VBA_config.inF.time_iter_real(1)) && (batch_time_min <= VBA_config.inF.time_iter_real(2)) %RESET Variance after induction
VBA_config.priors.SigmaTheta = [diag(.5*ones(size(VBA_config.priors.muTheta)))].^2; 
VBA_config.priors.SigmaTheta(4,4)=.95^2;
VBA_config.priors.SigmaTheta(8,8)=.95^2;
end
%%%%%%%

if (VBA_config.inF.time_induction.n1 >= VBA_config.inF.time_iter_real(1)) && (VBA_config.inF.time_induction.n1 <= VBA_config.inF.time_iter_real(2)) %RESET Variance after induction
VBA_config.priors.SigmaTheta = [diag(.5*ones(size(VBA_config.priors.muTheta)))].^2; 
VBA_config.priors.SigmaTheta(4,4)=0.95^2;
VBA_config.priors.SigmaTheta(8,8)=0.95^2;
end
%%%%%%%

[posterior,out] = VBA_NLStateSpaceModel(y_exp,[],f_fname,g_fname,VBA_config.dim,VBA_config);

priors.muX0 = posterior.muX(:,end);
priors.SigmaX0 =posterior.SigmaX.current{end};
priors.muTheta = posterior.muTheta;
priors.SigmaTheta = posterior.SigmaTheta;
VBA_config.priors = priors;

%%
if VBA_config.iter>1
    VBA_estimation_old=VBA_config.estimation.sample;
    VBA_estimation_old_std=VBA_config.estimation.sample_std;
end

error_reg={[];[];[];[];[];};
for nn=1:VBA_config.inF.n_exp
VBA_config.estimation.current.(['n',num2str(nn)]) = priors.muX0([1:VBA_config.inF.dim_brxtor]+(nn-1)*(VBA_config.inF.dim_brxtor+VBA_config.inF.dim_meas));
VBA_config.estimation.x_regressed.(['n',num2str(nn)]) = priors.muX0([(VBA_config.inF.dim_brxtor+1):(VBA_config.inF.dim_brxtor+VBA_config.inF.dim_meas)]+(nn-1)*(VBA_config.inF.dim_brxtor+VBA_config.inF.dim_meas));

SD_muX0=sqrt(diag(priors.SigmaX0));
VBA_config.estimation.x_regressed_std.(['n',num2str(nn)]) =SD_muX0([(VBA_config.inF.dim_brxtor+1):(VBA_config.inF.dim_brxtor+VBA_config.inF.dim_meas)]+(nn-1)*(VBA_config.inF.dim_brxtor+VBA_config.inF.dim_meas));

for ns=1:5

if ns==5
    new_estimations=VBA_config.estimation.x_regressed.(['n',num2str(nn)])(ns:VBA_config.inF.dim_meas);
    new_measurements=VBA_data.x_exp([ns:VBA_config.inF.dim_meas]+(nn-1)*(VBA_config.inF.dim_meas));
    
    new_estimations_std=VBA_config.estimation.x_regressed_std.(['n',num2str(nn)])(ns:VBA_config.inF.dim_meas);
else
    new_estimations=VBA_config.estimation.x_regressed.(['n',num2str(nn)])(ns);
    new_measurements=VBA_data.x_exp(ns+(nn-1)*(VBA_config.inF.dim_meas));
    
    new_estimations_std=VBA_config.estimation.x_regressed_std.(['n',num2str(nn)])(ns);

end

error_reg{ns}=[error_reg{ns};abs(new_measurements-new_estimations)];

%
if VBA_config.iter>1
try
VBA_config.estimation.sample.(['n',num2str(nn)]).(['ns',num2str(ns)])=[VBA_estimation_old.(['n',num2str(nn)]).(['ns',num2str(ns)]);VBA_data.time_sample_real.(['n',num2str(nn)]).(['ns',num2str(ns)]),new_estimations];

VBA_config.estimation.sample_std.(['n',num2str(nn)]).(['ns',num2str(ns)])=[VBA_estimation_old_std.(['n',num2str(nn)]).(['ns',num2str(ns)]);VBA_data.time_sample_real.(['n',num2str(nn)]).(['ns',num2str(ns)]),new_estimations_std];
catch
VBA_config.estimation.sample.(['n',num2str(nn)]).(['ns',num2str(ns)])=[VBA_estimation_old.(['n',num2str(nn)]).(['ns',num2str(ns)])';VBA_data.time_sample_real.(['n',num2str(nn)]).(['ns',num2str(ns)]),new_estimations];

VBA_config.estimation.sample_std.(['n',num2str(nn)]).(['ns',num2str(ns)])=[VBA_estimation_old_std.(['n',num2str(nn)]).(['ns',num2str(ns)])';VBA_data.time_sample_real.(['n',num2str(nn)]).(['ns',num2str(ns)]),new_estimations_std];
end

else
VBA_config.estimation.sample.(['n',num2str(nn)]).(['ns',num2str(ns)])=[VBA_data.time_sample_real.(['n',num2str(nn)]).(['ns',num2str(ns)]),new_estimations];

VBA_config.estimation.sample_std.(['n',num2str(nn)]).(['ns',num2str(ns)])=[VBA_data.time_sample_real.(['n',num2str(nn)]).(['ns',num2str(ns)]),new_estimations_std];

end

end

end

priors.SigmaX0=priors.SigmaX0*0;
nsp_index=[1,2,5,3,4];

for ns=1:5
SD_ns=mean(error_reg{nsp_index(ns)});
for nn=1:VBA_config.inF.n_exp
    priors.SigmaX0(ns+(nn-1)*(VBA_config.inF.dim_brxtor+VBA_config.inF.dim_meas),ns+(nn-1)*(VBA_config.inF.dim_brxtor+VBA_config.inF.dim_meas))=(SD_ns)^2; 
end
end
VBA_config.priors = priors;

%% Save settings

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



