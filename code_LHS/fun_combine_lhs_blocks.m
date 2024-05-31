function fun_combine_lhs_blocks(lhs_info)

N         = lhs_info.N;
B         = lhs_info.B;
data_idx  = lhs_info.data_idx;
sim_dat   = lhs_info.sim_dat;
prms_info = lhs_info.prms_info;
prms_est  = prms_info.prms_est;

n_est_prms = sum(prms_est);

[~,save_str] = fun_load_LL_by_data(data_idx,sim_dat,prms_info);
PrmsMatTmp = [];
LL_vecTmp  = [];

for block_idx = 1:B
    lhs_tmp = load(['LHS_MATS/LHS_PRMS_',save_str,sprintf('_N%dk%d_Block%dof%d',...
    [N,n_est_prms,block_idx,B]),'.mat'],'PrmsMat','LL_vec');
    PrmsMatTmp = [PrmsMatTmp;lhs_tmp.PrmsMat];
    LL_vecTmp  = [LL_vecTmp,lhs_tmp.LL_vec];
end

PrmsMat = PrmsMatTmp;
LL_vec  = real(LL_vecTmp);
[~,srt_idx] = sort(real(LL_vec),'descend');
% Keep only the top 10K parameter sets
if numel(LL_vec) > 500
    PrmsMat = PrmsMat(srt_idx(1:500),:);
    LL_vec  = LL_vec(srt_idx(1:500));
else
    PrmsMat = PrmsMat(srt_idx,:);
    LL_vec  = LL_vec(srt_idx);
end

fprintf('LHS Pre-exploration of parameter space:\n')
fun_print_parameter_est([PrmsMat(1,:) LL_vec(1)])

save(['LHS_MATS/LHS_PRMS_',save_str,sprintf('_N%dk%d',[N,n_est_prms]),'.mat'],'PrmsMat','LL_vec');