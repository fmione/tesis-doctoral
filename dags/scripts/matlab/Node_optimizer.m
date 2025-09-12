addpath(genpath(pwd)) %Add subfolders to the path
%% Load
    VBA_config=jsondecode(fileread(strcat(strain,'/VBA_config.json'))); 
    if VBA_config.iter>0
        VBA_feed=jsondecode(fileread(strcat(strain,'/VBA_feed.json'))); 
        VBA_digitalTwin=jsondecode(fileread(strcat(strain,'/VBA_digitalTwin.json')));    
        Current_feed=VBA_feed.NEXT.current_opt_param';
        Optimize_feed=VBA_feed.NEXT.optimize_feed;
        
        VBA_log=jsondecode(fileread(strcat(strain,'/VBA_log.json')));

    else
        Optimize_feed=ones(1,VBA_config.inF.n_exp);
        Current_feed=repmat((VBA_config.opt_LB+VBA_config.opt_UB)'/2,1,VBA_config.inF.n_exp);
        try
            Current_feed=repmat([.4,.15,5],1,VBA_config.inF.n_exp);Current_feed(1:3:end)=linspace(0,2.5,VBA_config.inF.n_exp);
        catch
        end
    end

f_fname=str2func(VBA_config.inF.fname);
g_fname=str2func(VBA_config.inG.gname);
%% Run Optimizer

if VBA_config.iter>0
    VBA_config.inF.time_feed=VBA_feed.NEXT.time_feed;
    VBA_config.inF.feed_profile=VBA_feed.NEXT.feed_profile;
end

VBA_config.inF.t_opt=VBA_config.inF.time_iter_real(2)+(VBA_config.inF.time_analytic*60+(VBA_config.time_limit+3)+sum(VBA_config.opt_time_limit))/60; %%%%%

% if VBA_config.inF.time_induction.n1 > VBA_config.inF.time_iter_real(1)

    if VBA_config.iter>0
        x_data=VBA_log.data.(['iter',num2str(VBA_config.iter)]).sample;
        feed_opt=method_optimizer(VBA_config,Current_feed,VBA_digitalTwin.x_prediction,x_data,Optimize_feed,VBA_config.opt_LB,VBA_config.opt_UB,VBA_config.opt_time_limit);
    else
        feed_opt=method_optimizer(VBA_config,Current_feed,[],[],Optimize_feed,VBA_config.opt_LB,VBA_config.opt_UB,VBA_config.opt_time_limit);
    end
% else
%         feed_opt.cum_feed=VBA_feed.NEXT.cum_feed_profile;
%         feed_opt.pulse=VBA_feed.NEXT.feed_profile;
%         feed_opt.current_opt_param=VBA_feed.NEXT.current_opt_param;
% end
%% Save settings

if VBA_config.iter>0
    VBA_feed=jsondecode(fileread(strcat(strain,'/VBA_feed.json'))); %
    VBA_config.inF.feed_profile=VBA_feed.NEXT.feed_profile;
    
end

VBA_feed.NEXT.cum_feed_profile=feed_opt.cum_feed;
VBA_feed.NEXT.time_feed=VBA_config.inF.time_feed;
VBA_feed.NEXT.feed_profile=feed_opt.pulse;
VBA_feed.NEXT.current_opt_param=feed_opt.current_opt_param;
VBA_feed.NEXT.optimize_feed=Optimize_feed;


VBA_feed.(['iter',num2str(VBA_config.iter)]).cum_feed_profile=feed_opt.cum_feed;
VBA_feed.(['iter',num2str(VBA_config.iter)]).time_feed=VBA_config.inF.time_feed;
VBA_feed.(['iter',num2str(VBA_config.iter)]).feed_profile=feed_opt.pulse;
VBA_feed.(['iter',num2str(VBA_config.iter)]).current_opt_param=feed_opt.current_opt_param;
VBA_feed.(['iter',num2str(VBA_config.iter)]).optimize_feed=Optimize_feed;

VBA_feed_js=jsonencode(VBA_feed);
fid=fopen(strcat(strain,'/VBA_feed.json'),'w');
fprintf(fid, VBA_feed_js);
fclose('all');


