function negLL = fun_fmin_LL_Gen(LL_,prms_info,in_prms)
% fix_prms is nan if not(prms_est) and a real value if prms_est == 1
% in_prms should have prms_est 1:
% prms_est = prms_info.prms_est;
% fix_prms(prms_est) = in_prms;
prm_vals = fun_get_full_paramset(in_prms,prms_info);

negLL = -LL_(prm_vals);