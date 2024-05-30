function [PrmsTmp,LLtmp] = rnd_prm_sample(LL_,mu_vec,prms_info,Cn,lb,ub)
% Re-sample values while parameters exceed lower bownd or upper bound
% This can be made faster somehow. abs( ) bc no parameters are assumed to
% be negative
% KM = fun_get_KM;
if prms_info.itr < prms_info.non_adapt_itrs
PrmsTmpMat = fun_get_full_paramset(abs(mvnrnd(mu_vec,Cn,100)),prms_info);
PrmsTmpMat = PrmsTmpMat(not(any(PrmsTmpMat<lb,2)),:);
PrmsTmpMat = PrmsTmpMat(not(any(PrmsTmpMat>ub,2)),:);
% PrmsTmpMat = PrmsTmpMat(any(PrmsTmpMat(:,3)<KM*PrmsTmpMat(:,1),2),:);
count = 1;
while isempty(PrmsTmpMat)
    PrmsTmpMat = [PrmsTmpMat;fun_get_full_paramset(abs(mvnrnd(mu_vec,Cn,100)),prms_info)];
    PrmsTmpMat = PrmsTmpMat(not(any(PrmsTmpMat<lb,2)),:);
    PrmsTmpMat = PrmsTmpMat(not(any(PrmsTmpMat>ub,2)),:);
    % fprintf('Num Prms: %d\n',size(PrmsTmpMat,1))
    % PrmsTmpMat = PrmsTmpMat(any(KM*PrmsTmpMat(:,1)>PrmsTmpMat(:,3),2),:);

%   disp('IN WHILE')
    if count > 10^6
        error('Had a problem generating samples! Code exited')
    end
    count = count + 1;
end
% PrmsTmp  = PrmsTmpMat(randperm(size(PrmsTmpMat,1),1),:);
PrmsTmp  = PrmsTmpMat(1,:);
LLtmp    = LL_(PrmsTmp);
end
if
