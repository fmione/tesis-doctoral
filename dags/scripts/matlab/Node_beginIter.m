
addpath(genpath(pwd)) %Add subfolders to the path

%% Load
VBA_config=jsondecode(fileread(strcat(strain,'/VBA_config.json'))); %VBA settings and results
%%
VBA_config.iter=VBA_config.iter+1;
%%
VBA_config_js=jsonencode(VBA_config);
fid=fopen(strcat(strain,'/VBA_config.json'),'w');
fprintf(fid, VBA_config_js);
fclose('all');