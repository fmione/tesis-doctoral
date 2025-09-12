function [tf,Xf,DOT_l,Pf] = function_shortcut(C01,TH,t_span,time_feed,feed_profile,time_induction)
if nargin<6
    time_induction=t_span(end)+1;
end

Yx=TH(2)*TH(5)+(1-TH(2))*(TH(6)*TH(7)+TH(11));
 
    
    tf0=[0;time_feed];
    ff0=[0;feed_profile];
    
    ff=ff0(tf0>=t_span(1) & tf0<=t_span(2));
    tf=tf0(tf0>=t_span(1) & tf0<=t_span(2));
    
    ff_acc=C01(2)+200/1e6/C01(6)*cumsum(ff);
    
    Xf=C01(1)+ff_acc*Yx;
   
   ss=linspace(0.01,2,20);
   aa=linspace(0.01,2,20);
   [SS,AA]=meshgrid(ss,aa);

   qo_matrix=TH(1)*TH(2)*SS./(SS+TH(12)).*TH(14)./(TH(14)+AA)*TH(9)+TH(3)*TH(15)./(SS+TH(15)).*AA./(TH(13)+AA)*TH(10);%
   qo_max=max(qo_matrix(:));

    DOT_l=(-((qo_max)*Xf*13000/TH(17)-100+TH(16))+sqrt((((qo_max)*Xf*13000/TH(17)-100+TH(16)).^2+4*100*TH(16))))/2;

    
    tf_ind=tf0>time_induction;
    ff_ind0=[0;200/1e6/C01(6)*cumsum([feed_profile].*tf_ind(2:end))];
       ff_ind=ff_ind0(tf0>=t_span(1) & tf0<=t_span(2));

    Pf=C01(5)+ff_acc*TH(4)+TH(8)*ff_ind;

    
end