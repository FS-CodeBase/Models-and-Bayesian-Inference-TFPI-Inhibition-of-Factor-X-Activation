function res = covar(Cn,eIp,n,barXp,barXn,Xn,sd)
% Function COV updates covariance with 
res = (n-1)/n*Cn+sd/n*(n*((barXp')*barXp)-(n+1)*((barXn')*barXn)+((Xn')*Xn)+eIp);