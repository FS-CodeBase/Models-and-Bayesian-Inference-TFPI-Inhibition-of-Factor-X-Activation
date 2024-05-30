function [out_prms,LL_val] = fun_apply_fmin(model_info,lhs_est,LL_val)
data_idx  = model_info.data_idx;
sim_dat   = model_info.sim_dat;
prms_info = model_info.prms_info;
prms_est  = prms_info.prms_est;

fprintf('\n\n FMIN START:\n')
% fun_print_parameter_est_bin(prms_est);
fprintf('Initial LL: %0.3f\n',LL_val)

% Load Likelihood for FMINCON
LL_      = fun_load_LL_by_data(data_idx,sim_dat,prms_info);
% out_prms = lhs_est;
% out_prms(prms_est) = nan; % Replace estimated params with NaN 
% init_prm_ests      = lhs_est(prms_est);
% fminLL             = @(in_prms) fun_fmin_LL(LL_,prms_info,in_prms,out_prms);
% [prms_mle,LL_val]  = fun_fmincon(fminLL,init_prm_ests,prms_info);

fminLL             = @(in_prms) fun_fmin_LL_Gen(LL_,prms_info,in_prms);
[prms_mle,LL_val]  = fun_fmincon(fminLL,lhs_est,prms_info);
% out_prms(prms_est) = prms_mle;
out_prms           = fun_get_full_paramset(prms_mle,prms_info);

fprintf('FMIN LL: %0.3f\n',LL_val)
fprintf('AM START PARAMS\n\n\n')
fun_print_parameter_est([out_prms LL_val])