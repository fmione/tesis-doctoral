 function [gx,dg1,dg2] = measM(C0,PHI,uv,inG)
% Extract only the sampling times from the extended vector
 
 n_exp=inG.n_exp;
 dim_meas=inG.dim_meas;
 
 for nn=1:n_exp %for each bioreactor
 C00((1:dim_meas)+(nn-1)*(dim_meas),1)=C0((7:(dim_meas+6))+(nn-1)*(dim_meas+6));
 end

 gx=C00./inG.scale; % Scale the results

 dg1=[];
 dg2=[];
 end