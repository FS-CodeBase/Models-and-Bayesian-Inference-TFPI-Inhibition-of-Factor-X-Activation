function [PrmsTmp,LLtmp] = rnd_prm_sample_am_one(LL_,mu_vec,prms_info,Cn,lb,ub)
% Re-sample values while parameters exceed lower bownd or upper bound
% This can be made faster somehow. abs( ) bc no parameters are assumed to
% be negative
KM = fun_get_KM;
PrmsTmpMat = fun_get_full_paramset(abs(mvnrnd(mu_vec,Cn,50)),prms_info);
PrmsTmpMat = PrmsTmpMat(not(any(PrmsTmpMat<lb,2)),:);
PrmsTmpMat = PrmsTmpMat(not(any(PrmsTmpMat>ub,2)),:);
PrmsTmpMat = PrmsTmpMat(any(PrmsTmpMat(:,3)<KM*PrmsTmpMat(:,1),2),:);
count = 1;
while isempty(PrmsTmpMat)
    PrmsTmpMat = [PrmsTmpMat;fun_get_full_paramset(abs(mvnrnd(mu_vec,Cn,50)),prms_info)];
    PrmsTmpMat = PrmsTmpMat(not(any(PrmsTmpMat<lb,2)),:);
    PrmsTmpMat = PrmsTmpMat(not(any(PrmsTmpMat>ub,2)),:);
    PrmsTmpMat = PrmsTmpMat(any(KM*PrmsTmpMat(:,1)>PrmsTmpMat(:,3),2),:);

    if count > 10^6
        warning('Had a problem generating samples AM P1! Count: %d',count)
    end
    count = count + 1;
end
% PrmsTmp  = PrmsTmpMat(randperm(size(PrmsTmpMat,1),1),:);
PrmsTmp  = PrmsTmpMat(1,:);
LLtmp    = LL_(PrmsTmp);
