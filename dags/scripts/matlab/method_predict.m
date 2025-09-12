function [f,f_cont]=method_predict(options,data,time_optim,feed_opt)

inF=options.inF;
inF.opt=1;

n_exp=inF.n_exp;
n_dim=options.inF.dim_brxtor;

TH00=options.priors.muTheta;

C00=options.priors.muX0;

x_data=data;

for nn=1:n_exp
inFO=inF;
C0=C00((1:n_dim)+(options.dim.n/n_exp)*(nn-1));%

index_th=inFO.index_th;
TH_nominal=inFO.TH_nominal;
sigma_TH1=inFO.sigma_TH;

TH1=TH_nominal;

for nth=1:numel(index_th)
    th_min=TH_nominal(index_th(nth))-1*sigma_TH1(index_th(nth));
    th_max=TH_nominal(index_th(nth))+1*sigma_TH1(index_th(nth));
    TH1(index_th(nth))=(tanh(TH00(nth)*2)+1)*(th_max-th_min)/2+th_min;
end
TH=TH1(1:18);TH(17)=TH1(16+nn+1*0);TH(18)=TH1(16+n_exp+nn);

index_brxt=['n',num2str(nn)];    

uu=feed_opt.(index_brxt);
time_u=options.inF.time_feed.(index_brxt);
t_ind=inFO.time_induction.(['n',num2str(nn)]);

inFO.time_sample.opt=inFO.time_sample.(index_brxt);

[fx,dF_dX] =  function_simulation(C0,TH,inFO,time_optim,time_u,uu,t_ind);

for nsp=1:5
    if size(x_data.(index_brxt).(['ns',num2str(nsp)]),2)==1
        x_data_past=x_data.(index_brxt).(['ns',num2str(nsp)])';
    else
        x_data_past=x_data.(index_brxt).(['ns',num2str(nsp)]);
    end    
    x_predict.(index_brxt).(['ns',num2str(nsp)])=[x_data_past;dF_dX{nsp}];
end

x_predict_cont.(index_brxt)=fx;
end
f=x_predict;
f_cont=x_predict_cont;
end