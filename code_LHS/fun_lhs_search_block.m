function fun_lhs_search_block(lhs_info,block_idx) 
        
prms_info = lhs_info.prms_info;
prms_est  = prms_info.prms_est;
% sub_lhs   = lhs_info.sub_lhs;
N         = lhs_info.N;
B         = lhs_info.B; % Number of processors
data_idx  = lhs_info.data_idx;
sim_dat   = lhs_info.sim_dat;

[~,save_str] = fun_load_LL_by_data(data_idx,sim_dat,prms_info);

% Number of parameters to be estimated
n_est_prms = sum(prms_est);

BLOCKS = fun_get_index_blocks(B,N);
B_num  = BLOCKS(2,1);
LL_vec = zeros(B_num,1);
start_time = datetime('now');

PRMS = load(['LHS_MATS/LHS_PRMS_',save_str,...
                sprintf('_N%dk%d_Block%dof%d',...
                    [N,n_est_prms,block_idx,B]),'.mat'],'PrmsMat');

parfor idx = 1:B_num
    tic
    % Load Likelihood Function
    LL_ = fun_load_LL_by_data(data_idx,sim_dat,prms_info);
    LL_vec(idx) = LL_(PRMS.PrmsMat(idx,:));
    if mod(idx,5000) == 0
	    curr_dur = fun_time_difference(start_time,datetime('now'));
        fprintf('Complete i = %d -- Duration: %0.2f mins\n',idx,curr_dur);
    end
end
[~,srt_idx] = sort(LL_vec);
LL_vec  = LL_vec(srt_idx);
PrmsMat = PRMS.PrmsMat(srt_idx,:);
end_time    = datetime('now');
par_runtime = fun_time_difference(start_time,end_time);

fprintf('%s: Maximum LL for block %d is %0.2f\n',save_str,block_idx,max(LL_vec));
fprintf('DATA %d LHS BLOCK PROCESSING TIME: %0.2f min(s)\n',data_idx,par_runtime)

% Save block
save(['LHS_MATS/LHS_PRMS_',save_str,sprintf('_N%dk%d_Block%dof%d',...
            [N,n_est_prms,block_idx,B]),'.mat'],'LL_vec','PrmsMat');
