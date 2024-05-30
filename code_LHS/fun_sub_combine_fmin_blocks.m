function fun_sub_combine_fmin_blocks(data_idx,LHS_N,LHS_B)
MA_N = nan;
AM_N = nan;

if data_idx <= 3 % For submission as one job (laziness)
    lhs_info = fun_get_model_and_param_details(data_idx,LHS_N,LHS_B,MA_N,AM_N);
    
    % COMBINE BLOCKS
    %%%%%%%%%%%%
    fun_combine_fmin_blocks(lhs_info)
    run_time_am = ['Runtime of AM Algorithm: ',num2str(toc/60),'(m)'];
    disp(run_time_am);
else
    return
end
