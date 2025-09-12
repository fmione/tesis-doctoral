function [ff_min,c_dot]=function_objective(fuu,options,fuu0,x_prediction,optimize_feed)%C0,TH,tu,uu0,
if nargin<3
    fuu0=fuu*0;
    optimize_feed=[1 1 1 1 1 1];
end

inG=options.inG;
inF=options.inF;
inF.opt=1;
f_fname=str2func(inF.fname);

n_exp=inF.n_exp;
n_dim=options.inF.dim_brxtor;

time_induction=inF.time_induction;
time_batchEnd=inF.time_batchEnd;

TH00=options.priors.muTheta;
C00=options.priors.muX0;


parfor nn=1:n_exp

inFO=inF;

index_th=inFO.index_th;
TH_nominal=inFO.TH_nominal;



TH1=TH_nominal;
sigma_TH1=inF.sigma_TH;
for nth=1:numel(index_th)
    th_min=TH1(index_th(nth))-1*sigma_TH1(index_th(nth));
    th_max=TH1(index_th(nth))+1*sigma_TH1(index_th(nth));
    TH1(index_th(nth))=(tanh(TH00(nth)*2)+1)*(th_max-th_min)/2+th_min;
end
TH=TH1(1:18);TH(17)=TH1(16+nn);TH(18)=TH1(16+n_exp+nn);

index_brxt=['n',num2str(nn)];    
time_u=options.inF.time_feed.(index_brxt);
inFO.time_profile.opt=time_u;
inFO.time_sample.opt=inF.time_sample.(index_brxt);

uu=inFO.feed_profile.(index_brxt);

inFO.feed_profile.opt=uu;

t_ind=inFO.time_induction.(['n',num2str(nn)]);

C0=C00((1:n_dim)+(options.dim.n/n_exp)*(nn-1));
x0=options.xt00((1:n_dim)+(options.dim.n/n_exp)*(nn-1));


if options.iter==0
    time_optim=[0  inFO.time_iter(end) ]; 
else
    time_optim=[inFO.time_iter_real(end)  inFO.time_iter(end) ]; 
end
[fx] = function_simulation(C0,TH,inFO,time_optim,time_u,uu,t_ind);  

C0b=interp1(fx(:,1),fx(:,2:end),inFO.t_opt);

%%%%%%
uu_previous=inFO.feed_profile.(index_brxt);

fu_previous=fuu0((1:3)+(nn-1)*3);

u0_previous=fu_previous(1)*exp(fu_previous(2)*(time_u-time_batchEnd.(['n',num2str(nn)])))+fu_previous(3);

u0_previous(time_u<time_batchEnd.(['n',num2str(nn)]))=0;
u0_previous(time_u>time_induction.(['n',num2str(nn)]))=fu_previous(1)*exp(fu_previous(2)*(time_induction.(['n',num2str(nn)])-time_batchEnd.(['n',num2str(nn)])))+fu_previous(3);

uu_previous(time_u>inFO.t_opt)=u0_previous(time_u>inFO.t_opt);
uu_previous=round(uu_previous*2)/2;
uu_previous(uu_previous<5)=5;
%%%%%%
fu=fuu((1:3)+(nn-1)*3);

u0=fu(1)*exp(fu(2)*(time_u-time_batchEnd.(['n',num2str(nn)])))+fu(3);

u0(time_u<time_batchEnd.(['n',num2str(nn)]))=0;
u0(time_u>time_induction.(['n',num2str(nn)]))=fu(1)*exp(fu(2)*(time_induction.(['n',num2str(nn)])-time_batchEnd.(['n',num2str(nn)])))+fu(3);

uu(time_u>inFO.t_opt)=u0(time_u>inFO.t_opt);
uu=round(uu*2)/2;
uu(uu<5)=5;

if optimize_feed(nn)==0,uu=uu*0+5;end

inFO.feed_profile.opt=uu;

time_optim=[inFO.t_opt  inFO.time_iter(end) ]; %CHECK CHECK CHECK


[fx,dF_dX] = function_simulation(C0b',TH,inFO,time_optim,time_u,uu,t_ind);
tf=dF_dX{1}(:,1);Xf=dF_dX{1}(:,2);Pf=dF_dX{4}(:,2);DOT_l=dF_dX{5}(:,2);

SafeMarginO2=inFO.O2safeMargin;
SafeMarginX=inFO.XsafeMargin;

if round(min(DOT_l))<(inFO.O2min+SafeMarginO2) && optimize_feed(nn)==1
    constraint_f1(nn)=0.5*(inFO.O2min+SafeMarginO2-round(min(DOT_l)))/(inFO.O2min+SafeMarginO2)+0.5;%constraint_f(nn)+
else
    constraint_f1(nn)=0;
end

if max(abs(uu_previous(time_u>time_optim(1))-uu(time_u>time_optim(1)))./uu_previous(time_u>time_optim(1)))>.35 && optimize_feed(nn)==1 && options.iter>0
    constraint_f2(nn)=0.5*max(abs(uu_previous(time_u>time_optim(1))-uu(time_u>time_optim(1)))./uu_previous(time_u>time_optim(1)))+0.5;
else
    constraint_f2(nn)=0;
end


try
Xf_old=x_prediction.(['n',num2str(nn)]).ns1;
X_all=[Xf_old(Xf_old(:,1)<tf(1),:);tf,Xf];

catch
X_all=[tf,Xf];

end

f{nn}=interp1(X_all(:,1),X_all(:,2),linspace(X_all(1,1),X_all(end,1),30));

end

ff=[];
cc=[];
scale_factor=[1,5,100*25,.1];

        for n3=1:(n_exp-1)
             fn1=[];
             for n1=1  

                  f_int=f{n3};
                  fn1=[fn1;f_int];

             end  
             
            for n4=((n3+1):n_exp)
                fn2=[];
             for n1=1  

                    f_int=f{n4};

                  fn2=[fn2;f_int];
             end
             
             if optimize_feed(n3)==0 && optimize_feed(n4)==0       
             else
                ff=[ff;(abs(sum(fn1-fn2))/100)*(1-100*0.5*(constraint_f1(n3)+constraint_f1(n4))-.10*.5*(constraint_f2(n3)+constraint_f2(n4)))];             
             end
            
            end
            
        end

[constraint_f1',constraint_f2']

-min(ff)
ff_min=-min(ff);
c_dot=constraint_f1;
end
