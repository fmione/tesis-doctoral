function [VBA_data,TX,TF]=method_getData(db,VBA_config,check_all)
if nargin<3 
    check_all=0;
end

species_list=VBA_config.species_list;
brxtor_name=fieldnames(db);
for bn=1:VBA_config.inF.n_exp
    for nsp=1:numel(species_list)
        try
        index_bn=fieldnames(db.(brxtor_name{bn}).measurements_aggregated.(species_list{nsp}).measurement_time); 
        Species_holder=zeros(numel(index_bn),2);
        for ni=1:numel(index_bn)
        Species_holder(ni,:)=[db.(brxtor_name{bn}).measurements_aggregated.(species_list{nsp}).measurement_time.(index_bn{ni}),...
            db.(brxtor_name{bn}).measurements_aggregated.(species_list{nsp}).(species_list{nsp}).(index_bn{ni})];
        end

        catch
            if strcmp(species_list{2},'Glucose')
                 Species_holder=[.1,NaN];%Species_holder=[.1,NaN];    
            else
                 Species_holder=[.1,NaN];  %Species_holder=[.1,NaN];    
            end
        end

        % Corrections
        if strcmp(species_list{nsp},'OD600')
            Species_holder(:,2)=Species_holder(:,2)/2.7027; %OD to Biomas
        elseif strcmp(species_list{nsp},'DOT')
            Species_holder(Species_holder(:,2)>100,2)=100;% Max DOT 100%;   
        end
        Species_holder(Species_holder(:,2)<0,2)=0; % No negative values

        TX{bn,nsp}=Species_holder;
    end
    
% Feeding
try
index_bn=fieldnames(db.(brxtor_name{bn}).measurements_aggregated.Cumulated_feed_volume_glucose.measurement_time); 
Cumulated_feed_volume_glucose=zeros(numel(index_bn),2);
for ni=1:numel(index_bn)
Cumulated_feed_volume_glucose(ni,:)=[db.(brxtor_name{bn}).measurements_aggregated.Cumulated_feed_volume_glucose.measurement_time.(index_bn{ni}), ...
    db.(brxtor_name{bn}).measurements_aggregated.Cumulated_feed_volume_glucose.Cumulated_feed_volume_glucose.(index_bn{ni})];
end 
TF{bn}=[Cumulated_feed_volume_glucose(:,1),diff([0;Cumulated_feed_volume_glucose(:,2)])];%%%%%%%%%%%%%%%%%%%%%*1e3*1e0

catch
cum_auxiliar=struct2cell(db.(brxtor_name{bn}).setpoints.Feed_glc_cum_setpoints);
time_auxiliar=struct2cell(db.(brxtor_name{bn}).setpoints.cultivation_age);
Cumulated_feed_volume_glucose=[];
for nb=1:numel(cum_auxiliar)
if isempty(cum_auxiliar{nb}) 
else
        Cumulated_feed_volume_glucose=[Cumulated_feed_volume_glucose;time_auxiliar{nb},cum_auxiliar{nb}];
end
end
TF{bn}=[Cumulated_feed_volume_glucose(:,1),diff([0;Cumulated_feed_volume_glucose(:,2)])];
end


end


%% Extract data for the iteration interval
if check_all==0
time_iter=VBA_config.inF.time_iter_real;
time_sample_iter=[time_iter(1) ,time_iter(2)]*3600;  %%% to seconds

Y=[];TY=[];
for bn=1:size(TX,1)
    for ns=1:size(TX,2)
        XX=TX{bn,ns};
        i_tdata=XX(:,1)<=time_sample_iter(2);
        tx_sample.(['n',num2str(bn)]).(['ns',num2str(ns)])=[XX(i_tdata,1)/3600,XX(i_tdata,2)];

        [uni,i_uni]=unique(tx_sample.(['n',num2str(bn)]).(['ns',num2str(ns)])(:,1));
        tx_sample.(['n',num2str(bn)]).(['ns',num2str(ns)])=tx_sample.(['n',num2str(bn)]).(['ns',num2str(ns)])(i_uni,:);
        tx_sample_reshape.(['n',num2str(bn)]).(['ns',num2str(ns)])=tx_sample.(['n',num2str(bn)]).(['ns',num2str(ns)]);
        
        if ns==5 % DOT 
        XO=XX(XX(:,1)>time_sample_iter(1) & XX(:,1)<time_sample_iter(end),:);%
        [t_XOu,i_tXOu]=unique(XO(:,1));
        XOu=XO(i_tXOu,2);
        
        tO=linspace(time_sample_iter(1),time_sample_iter(end),VBA_config.inF.n_sample_O2+2)';
        XXo=interp1(t_XOu,XOu,tO,'linear','extrap');
        
        Y=[Y;XXo(2:end-1)];
        TY=[TY;tO(2:end-1)/3600];  

        
        time_sample_data.(['n',num2str(bn)]).(['ns',num2str(ns)])=tO(2:end-1)/3600;
        x_sample.(['n',num2str(bn)]).(['ns',num2str(ns)])=XXo(2:end-1);
        
        tx_sample_reshape.(['n',num2str(bn)]).(['ns',num2str(ns)])=[time_sample_data.(['n',num2str(bn)]).(['ns',num2str(ns)]),x_sample.(['n',num2str(bn)]).(['ns',num2str(ns)])];
        else
        X=XX(XX(:,1)>time_sample_iter(1) & XX(:,1)<time_sample_iter(end),:);

        if isempty(X),     X=[NaN,NaN];end %
        
        if ns==1
        try Y=[Y;mean(rmoutliers(X(end-2:end,2)))];catch Y=[Y;X(end,2)];end % Biomass
        elseif ns==2
            try Y=[Y;mean(rmoutliers(X(end-2:end,2)))];catch Y=[Y;X(end,2)];end %%% Glucose
        else
        Y=[Y;X(end,2)];   
        end
        
        TY=[TY;X(end,1)/3600];

        time_sample_data.(['n',num2str(bn)]).(['ns',num2str(ns)])=X(end,1)/3600;
        
        end

    end
    
    FF=TF{bn};
    
    tf_data=3600*VBA_config.inF.time_feed.(['n',num2str(bn)]);    
    ff_data=VBA_config.inF.feed_profile.(['n',num2str(bn)]);
    
    ff_data(tf_data<time_sample_iter(end))=[];
    tf_data(tf_data<time_sample_iter(end))=[];

    ff_data=[FF(FF(:,1)<time_sample_iter(end),2);ff_data(tf_data>=time_sample_iter(end))]; 
    tf_data=[FF(FF(:,1)<time_sample_iter(end),1);tf_data(tf_data>=time_sample_iter(end))];

    time_feed_data.(['n',num2str(bn)])=tf_data/3600;
    feed_profile_data.(['n',num2str(bn)])=ff_data;
    

end


VBA_data.time_sample_real=time_sample_data;
VBA_data.time_feed_real=time_feed_data;
VBA_data.feed_profile_real=feed_profile_data;
VBA_data.x_exp=Y;
VBA_data.y_exp=Y./VBA_config.inG.scale;

VBA_data.sample=tx_sample;
VBA_data.sample_reshape=tx_sample_reshape;
VBA_data.where_isnan=isnan(Y);

else
   VBA_data=[]; 
end
end