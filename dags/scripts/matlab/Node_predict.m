addpath(genpath(pwd)) %Add subfolders to the path
%% Load

VBA_config=jsondecode(fileread(strcat(strain,'/VBA_config.json')));

if VBA_config.iter>0
    db=jsondecode(fileread(VBA_config.file_name{1}));
    VBA_data=method_getData(db,VBA_config);
    VBA_config.inF.time_sample_real=VBA_data.time_sample_real;
else
    VBA_config.inF.time_sample_real=VBA_config.inF.time_sample;
end

VBA_feed=jsondecode(fileread(strcat(strain,'/VBA_feed.json')));

f_fname=str2func(VBA_config.inF.fname);
g_fname=str2func(VBA_config.inG.gname);


VBA_config.inF.time_feed=VBA_feed.NEXT.time_feed;
VBA_config.inF.feed_profile=VBA_feed.NEXT.feed_profile;

for bn=1:VBA_config.inF.n_exp 
    check_time_FF=diff(VBA_config.inF.time_feed.(['n',num2str(bn)]));
    VBA_config.inF.time_feed.(['n',num2str(bn)])(check_time_FF<0)=[];
    VBA_config.inF.feed_profile.(['n',num2str(bn)])(check_time_FF<0)=[];
end
%% Run Prediction
time_call=posixtime(datetime('now'));%now;
acceleration_emu=1;
VBA_config.inF.t_opt=(time_call-VBA_config.inF.starting_time)/3600*acceleration_emu;
VBA_config.inF.t_opt=VBA_config.inF.time_iter_real(2)+(VBA_config.inF.time_analytic*60+VBA_config.time_limit+3)/60;%%%%%CHECK

if VBA_config.iter>0
time_optim=[VBA_config.inF.time_iter_real(2) VBA_config.inF.time_iter(end)]; 
else
time_optim=[VBA_config.inF.time_iter_real(1) VBA_config.inF.time_iter(end)];
end

try
    [x_prediction,x_prediction_cont]=method_predict(VBA_config,VBA_config.estimation.sample,time_optim,VBA_config.inF.feed_profile);

catch
    [x_prediction,x_prediction_cont]=method_predict(VBA_config,VBA_config.sample,time_optim,VBA_config.inF.feed_profile);
end
% 
for nn=1:VBA_config.inF.n_exp 
x_prediction.(['n',num2str(nn)]).ns5(find(diff(x_prediction.(['n',num2str(nn)]).ns5(:,1))==0))=x_prediction.(['n',num2str(nn)]).ns5(find(diff(x_prediction.(['n',num2str(nn)]).ns5(:,1))==0))+1e-6;
end

%% Save settings
if VBA_config.iter>0
    VBA_digitalTwin=jsondecode(fileread(strcat(strain,'/VBA_digitalTwin.json'))); %
end
VBA_digitalTwin.x_prediction=x_prediction;
VBA_digitalTwin.(['iter',num2str(VBA_config.iter)]).x_prediction=x_prediction;

VBA_digitalTwin.x_prediction_cont=x_prediction_cont;
VBA_digitalTwin.(['iter',num2str(VBA_config.iter)]).x_prediction_cont=x_prediction_cont;

VBA_digitalTwin_js=jsonencode(VBA_digitalTwin);
fid=fopen(strcat(strain,'/VBA_digitalTwin.json'),'w');
fprintf(fid, VBA_digitalTwin_js);
fclose('all');


