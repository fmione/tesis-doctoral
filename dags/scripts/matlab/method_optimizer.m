function [uu_opt]=method_optimizer(options,f_uoo,x_prediction,x_data,optimize_feed,LBoo,UBoo,Time_lim)
n_exp=options.inF.n_exp;
if options.iter>0
for nn=1:6
    DOT_check=x_data.(['n',num2str(nn)]).ns5;
    min_DOT=min(DOT_check(DOT_check(:,1)<options.inF.t_opt(1),2));
    if min_DOT<(options.inF.O2min+options.inF.O2safeMargin)
        optimize_feed(nn)=0;
    end
end
else
end

LBo=repmat(LBoo',1,n_exp);
UBo=repmat(UBoo',1,n_exp);    

options1= optimoptions('ga','MaxTime',60*0.5*Time_lim(1));
UT_opt0=ga(@(f_ut) function_objective2(f_ut,options,f_uoo,x_prediction,optimize_feed),length(f_uoo),[],[],[],[],LBo,UBo,[],options1);

options2=psoptimset('TimeLimit',60*0.25*Time_lim(1));
UT_opt=patternsearch(@(f_ut) function_objective(f_ut,options,f_uoo,x_prediction,optimize_feed),UT_opt0,[],[],[],[],LBo,UBo,[],options2);

UT_opt2=patternsearch(@(f_ut) function_objective(f_ut,options,f_uoo,x_prediction,optimize_feed),f_uoo,[],[],[],[],LBo,UBo,[],options2);
if function_objective(UT_opt2,options,f_uoo,x_prediction,optimize_feed)<=function_objective(UT_opt,options,f_uoo,x_prediction,optimize_feed)
UT_opt=UT_opt2;
end

for nn=1:n_exp
   if optimize_feed(nn)==0 
        UT_opt([1:3]+3*(nn-1))=LBoo;
   end
end

try
[check1,check2]=function_objective(UT_opt,options,f_uoo,x_prediction,optimize_feed);
for no=1:n_exp    
    if check2(no)>0
       UT_opt([1:3]+3*(no-1))=LBoo;
    end
end
catch
end

%%%%
uu_opt.current_opt_param=UT_opt;
for ne=1:n_exp
    index_brxt=['n',num2str(ne)];  
    uu_opt.pulse.(index_brxt)=options.inF.feed_profile.(index_brxt);

    t_u=options.inF.time_feed.(index_brxt);
    
    fu=UT_opt((1:3)+(ne-1)*3);
    
    uf=fu(1)*exp(fu(2)*(t_u-options.inF.time_batchEnd.(['n',num2str(ne)])))+fu(3); 
    
    
    uf(t_u<options.inF.time_batchEnd.(['n',num2str(ne)]))=0;
    uf(t_u>options.inF.time_induction.(['n',num2str(ne)]))=fu(1)*exp(fu(2)*(options.inF.time_induction.(['n',num2str(ne)])-options.inF.time_batchEnd.(['n',num2str(ne)])))+fu(3);
    uf=round(uf*2)/2; %
    uf(uf<5)=5;
    
    uf(t_u<options.inF.t_opt)=[];
    uu_opt.pulse.(index_brxt)=[uu_opt.pulse.(index_brxt)(t_u<=options.inF.t_opt);uf];
    

    uu_opt.cum_feed.(index_brxt)=cumsum(uu_opt.pulse.(index_brxt));

end

end