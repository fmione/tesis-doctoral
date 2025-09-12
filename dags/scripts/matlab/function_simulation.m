function [fx,f_interp] = function_simulation(C01,TH,inF,t_span,time_u0,uu0,t_ind)


% Get initial condition from the extended vector
    C1=C01(1:inF.dim_brxtor)'; 
% Get pulses for the integration interval t_span 
    i_tu=(time_u0>=t_span(1) & time_u0<=t_span(end));
    t_u=time_u0(i_tu);%
    uu=uu0(i_tu);
    
    if isempty(t_u)
        t_u=[t_span];
        uu=[t_span*0]; 
    end
    if (t_u(1)-t_span(1))>1e-3
        t_u=[t_span(1);t_u];
        uu=[0;uu];
    end
    if (t_span(end)-t_u(end))>1e-3
        t_u=[t_u;t_span(end)];
        uu=[uu;0];
    end

        t1=t_u(1);%
% Integrate for each pulse    
    for nt=1:(length(t_u)-1)
    C01=C1(end,:);    
    C01(2)=C01(2)+uu(nt)*(inF.feed_conc(1))/1e6/C01(6);%*0+TH1(19) %Add the pulse that corresponds to bioreactor nn

    [tc,C]=ode15s(@(t,x)odeModel(t,x,TH,t_ind),linspace(t_u(nt),t_u(nt+1),100),C01);%[t_u(nt) t_u(nt+1)];
    C(C<0)=0;
    t1=[t1;tc(2:end)];
    C1=[C1;C(2:end,:)];
    end
     [fx]=[t1,C1];
% Get values at sampling times     
    try 
     Cinterp=[];
     species_index=[1,2,4,5,3];%Xv,Glc,Acetate,P,DOT
    for n_species=[1,2,3,4,5]
        ts_interp0=inF.time_sample.opt.(['ns',num2str(n_species)]); %%CHECK
        ts_interp=ts_interp0(ts_interp0>=t_span(1));
        Cinterp{n_species}=[ts_interp,interp1(t1,C1(:,species_index(n_species)),ts_interp,'linear','extrap')];
    end

     [f_interp]=Cinterp;
    catch
      [f_interp]=[];  
    end


end
function f=odeModel(t,C,TH,t_ind)
% TH(TH<0)=1e-9;
C(C<0)=0;
 
X=C(1); %Biomass
S=C(2); %Glucose
O=C(3); %Oxygen (DOT)
A=C(4); %Acetate
P=C(5); %Product
V=C(6); %Volume

if O>100,O=100;end
%% Model parameters
qs_max=TH(1);
fracc_q_ox_max=TH(2);
qa_max=TH(3);
b_prod=TH(4);

Yxs_ox=TH(5);
Yap=TH(6);
Yxa=TH(7);
Yps=TH(8);
Yos=TH(9);
Yoa=TH(10);
Yxs_of=TH(11);

Ks=TH(12);
n_ox=4;

Ka=TH(13);

Kia=TH(14);
Ksai=TH(15);
Ko=TH(16);%
klal=TH(17);
kp=TH(18);


% Induction
if t<t_ind,s_ind=0;else s_ind=1;end%

%Auxiliary variables
H=13000;%
O_st=100;%

% Rates
qs=qs_max*S/(S+Ks)*Kia/(A+Kia);
q_ox_max=fracc_q_ox_max*qs_max;

% O steady state
    q_ox_ss=qs*(1/((qs/q_ox_max)^n_ox+1))^(1/n_ox);
    qac_ss=qa_max*A/(A+Ka)*Ksai/(Ksai+S);
    b_ss=Ko+(q_ox_ss*Yos+qac_ss*Yoa)*X*H/klal-O_st;
    c_ss=-O_st*Ko;
    O_ss=(-b_ss+sqrt(b_ss^2-4*c_ss))/2;



q_ox=qs*1/(1+(qs/q_ox_max)^n_ox)^(1/n_ox)*O_ss/(O_ss+Ko);
q_of=qs-q_ox;

qa_p=q_of*Yap;

qa_c=qa_max*A/(A+Ka)*Ksai/(Ksai+S)*O_ss/(O_ss+Ko);%

mu=(q_ox)*Yxs_ox+q_of*Yxs_of+qa_c*Yxa;
qp=qs*(Yps*s_ind+b_prod);%

%Balances

dX=mu*X;
dS=-qs*X;
dO=kp*(O_ss-O);%
dA=(qa_p-qa_c)*X;
dP=qp*X;
dV=0;

f=[dX dS dO dA dP  dV]';

end