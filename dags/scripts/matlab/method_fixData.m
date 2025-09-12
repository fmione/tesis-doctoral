function VBA_data_fixed=method_fixData(VBA_data,VBA_config,VBA_digitalTwin)
VBA_data_fixed=VBA_data;

time_iter=VBA_config.inF.time_iter_real;
x_DATA=VBA_data.x_exp;
t_DATA=[];

x_DTW=[];
t_DTW=[];

for nb=1:VBA_config.inF.n_exp

    for ns=1:5
    
    t_DTW_all=VBA_digitalTwin.x_prediction.(['n',num2str(nb)]).(['ns',num2str(ns)])(:,1);
    x_DTW_all=VBA_digitalTwin.x_prediction.(['n',num2str(nb)]).(['ns',num2str(ns)])(:,2);
    
    t_DTW_iter=t_DTW_all(t_DTW_all>time_iter(1) & t_DTW_all<=time_iter(2));
    x_DTW_iter=x_DTW_all(t_DTW_all>time_iter(1) & t_DTW_all<=time_iter(2));
    
    if ns==5 
    x_DTW_iter=interp1(t_DTW_iter,x_DTW_iter,VBA_data.time_sample_real.(['n',num2str(nb)]).(['ns',num2str(ns)]),'linear','extrap');
    t_DTW_iter=VBA_data.time_sample_real.(['n',num2str(nb)]).(['ns',num2str(ns)]);
    end   
    t_DTW=[t_DTW;t_DTW_iter];
    x_DTW=[x_DTW;x_DTW_iter];
    
    if isnan(VBA_data.time_sample_real.(['n',num2str(nb)]).(['ns',num2str(ns)]))
    VBA_data.time_sample_real.(['n',num2str(nb)]).(['ns',num2str(ns)])=t_DTW_iter;
    end
    t_DATA=[t_DATA;VBA_data.time_sample_real.(['n',num2str(nb)]).(['ns',num2str(ns)])];

    end
end
find_isnan=isnan(x_DATA);
t_DATA(isnan(x_DATA))=x_DTW(find_isnan);
x_DATA(isnan(x_DATA))=x_DTW(find_isnan);

VBA_data_fixed.time_sample_real= VBA_data.time_sample_real;
VBA_data_fixed.x_exp=x_DATA;
VBA_data_fixed.y_exp=x_DATA./VBA_config.inG.scale;
VBA_data_fixed.where_isnan=find_isnan;
end
