function fun_use_lhs_ests_and_apply_am_alg_bydata(am_info,lhs_info)  
% AM info

if am_info.restart
    am_alg_restart(am_info);
else
    non_adapt_itrs = am_info.non_adapt_itrs;
    adapt_itrs     = am_info.adapt_itrs;
    data_idx  = am_info.data_idx;
    sim_dat   = am_info.sim_dat;
    prms_info = am_info.prms_info;
    prms_est  = prms_info.prms_est;
    sub_lhs   = lhs_info.sub_lhs;
    
    N       = lhs_info.N;
    
    % Number of parameters to be estimated
    n_est_prms = sum(prms_est);
    
    % Load Log-Likelihood by data type
    [~,save_str] = fun_load_LL_by_data(data_idx,sim_dat);
    disp('Loading LHS Parameter Samples')
    load(['LHS_MATS/LHS_PRMS_',save_str,sprintf('_N%dk%d',[N,n_est_prms]),'.mat'],'PrmsMat');
    LHS_Pop    = PrmsMat(1:sub_lhs,:);
    am_info.Mu = median(LHS_Pop,1);
    am_info.Cn = diag(var(LHS_Pop,0));
    am_info.Cn = diag(var(LHS_Pop).*prms_est); % 3
    am_alg(am_info);
end