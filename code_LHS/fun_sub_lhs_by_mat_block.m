function fun_sub_lhs_by_mat_block(data_idx,block_idx,LHS_N,LHS_B)
MA_N = nan;
AM_N = nan;
lhs_info = fun_get_model_and_param_details(data_idx,LHS_N,LHS_B,MA_N,AM_N);

% RUN LHS By Block
%%%%%%%%%%%%
fun_lhs_search_block(lhs_info,block_idx)
run_time_am = ['Runtime of LHS Algorithm: ',num2str(toc/60),'(m)'];
disp(run_time_am)
