function fun_sub_lhs_and_am_all_data(data_idx,LHS_N,LHS_B,MA_N,AM_N)

[lhs_info,am_info] = fun_get_model_and_param_details(data_idx,LHS_N,LHS_B,MA_N,AM_N);
fprintf('In: fun_sub_lhs_and_am_all_data\n')
fun_print_parameter_est_bin(am_info.prms_info.prms_est);

% RUN AM Alg
%%%%%%%%%%%%
fun_use_lhs_ests_and_apply_am_alg_bydata(am_info,lhs_info)
run_time_am = ['Runtime of MA+AM Algorithms: ',num2str(toc/(60*60*24)),'(days)'];
disp(run_time_am);
