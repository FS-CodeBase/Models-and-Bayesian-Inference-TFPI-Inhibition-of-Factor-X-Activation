function fun_combine_fmin_blocks(lhs_info)

N         = lhs_info.N;
B         = lhs_info.B;
data_idx  = lhs_info.data_idx;
sim_dat   = lhs_info.sim_dat;
prms_info = lhs_info.prms_info;
prms_est  = prms_info.prms_est;

n_est_prms = sum(prms_est);

[~,save_str] = fun_load_LL_by_data(data_idx,sim_dat,prms_info);
PrmsMatTmp   = nan(N,numel(prms_est));

BLOCKS = fun_get_index_blocks(B,N);
LL_vecTmp = zeros(N,1);

for block_idx = 1:B
    lhs_tmp = load(['Sobol_Search/Sobol_PRMS_',save_str,sprintf('_N%dk%d_Block%dof%d',...
    [N,n_est_prms,block_idx,B]),'.mat'],'PrmsMat','LL_vec');
    PrmsMatTmp(BLOCKS(1,block_idx):BLOCKS(2,block_idx),:) = lhs_tmp.PrmsMat;
    LL_vecTmp(BLOCKS(1,block_idx):BLOCKS(2,block_idx))    = lhs_tmp.LL_vec;
end
% for block_idx = 1:B
%     delete(['Sobol_Search/Sobol_PRMS_',save_str,sprintf('_N%dk%d_Block%dof%d',...
%                 [N,n_est_prms,block_idx,B]),'.mat']);
% end
PrmsMat = PrmsMatTmp;
LL_vec  = real(LL_vecTmp);


[~,srt_idx] = sort(LL_vec,'descend');
% Keep only the top 10K parameter sets
if numel(LL_vec) > 500
    PrmsMat = PrmsMat(srt_idx(1:500),:);
    LL_vec = LL_vec(srt_idx(1:500));
else
    PrmsMat = PrmsMat(srt_idx,:);
    LL_vec = LL_vec(srt_idx);
end
LL_prev = -Inf;
fprintf('******* BEGIN Sobol Grid Search ************\n')
for itr = 1:100
    if any([any(isnan(PrmsMat)),any(isnan(LL_vec))])
        error('There are NaN values in the combined PrmsMat or LL_vec')
    end
    
    %%%%%%%%%%%%%%%%%%%%%% FOCUSED SEARCH USING MEDIANS %%%%%%%%%%%%%%%%%%%%%%
    
    % FMIN on MLE 
    [tmp_prms,LL_val] = fun_apply_fmin(lhs_info,PrmsMat(1,:),LL_vec(1));
    % If new fmincon estimate is worse, leave for-loop
    if LL_vec(1) > LL_val || abs(LL_prev-LL_val)<.05
        break
    end
    LL_prev = LL_val;
    tmp_prms = fun_get_full_paramset(tmp_prms,prms_info);
    sig_prms = std(PrmsMat(1:500,:),1,1); 

    N_2           = round(N/4);
    % SobolMat      = fun_gen_LHS_PrmsMat(N_2+1,n_est_prms);
    % SobolMat(1,:) = [];
    SobolMat = lhsdesign(N_2,n_est_prms);
    PrmsMat    = repmat(tmp_prms,N_2,1);
    LL_vec     = nan(1,N_2);
    
    % Keep estimates within bounds
    [lb,ub] = fun_get_param_bounds;
    lb = lb(prms_est); ub = ub(prms_est);

    % Search two standard deviations from mean
    PRC = 0.75;
    % UB = tmp_prms(prms_est) + 3*sig_prms(prms_est);
    % LB = tmp_prms(prms_est) - 3*sig_prms(prms_est);

    UB = tmp_prms(prms_est).*(1+PRC);
    LB = tmp_prms(prms_est).*(1-PRC);
    for pidx = 1:numel(UB)
        UB(pidx) = min([UB(pidx) ub(pidx)]);
        LB(pidx) = max([LB(pidx) lb(pidx)]);
    end
    % disp([UB;LB])
    % PrmsMat(:,prms_est) = fun_gen_norm_samples(SobolMat, tmp_prms(prms_est), sig_prms(prms_est), LB, UB);
    PrmsMat(:,prms_est) = fun_gen_Sobol_samples(SobolMat, tmp_prms(prms_est), LB, UB);
    disp([fun_get_full_paramset(mean(PrmsMat,1),prms_info);tmp_prms])

    % disp([var(PrmsMat)>eps;prms_est])
    PrmsMat = fun_get_full_paramset(PrmsMat,prms_info);
    LL_vec(any(PrmsMat<0,2))    = [];
    PrmsMat(any(PrmsMat<0,2),:) = [];

    % fun_plot_sampling_dists(PrmsMat,tmp_prms,prms_est)
    % PARAMETERS
    % k_1on [01]; k_1off [02]; k_2 [03];   k_3on [04];  k_3off [05];
    % k_4on [06]; k_4off [07]; k_5on [08]; k_5off [09];
    % k_6on [10]; k_6off [11]; k_7on [12]; k_7off [13];
    % k_8on [14]; k_8off [15]; sigma [16];
    
    fprintf('PRMS Search Part II -----------------\n')
    tic
    parfor idx = 1:size(PrmsMat,1)
        LL_         = fun_load_LL_by_data(data_idx,sim_dat,prms_info);
        LL_vec(idx) = LL_(PrmsMat(idx,:));
    end
    LL_vec(size(PrmsMat,1)+1)    = LL_val;
    PrmsMat(size(PrmsMat,1)+1,:) = tmp_prms;
    [~,srt_idx] = sort(real(LL_vec),'descend');
    histogram(LL_vec); hold on
    plot(LL_val,0,'-o','MarkerSize',10,'MarkerFaceColor','k'); hold off
    title(sprintf('MLE LL: %0.2f',LL_vec(srt_idx(1))))
    shg
    if numel(LL_vec) > 5000
        LL_vec  = LL_vec(srt_idx(1:5000));
        PrmsMat = PrmsMat(srt_idx(1:5000),:);
    else
        LL_vec  = LL_vec(srt_idx);
        PrmsMat = PrmsMat(srt_idx,:);
    end
    % fun_print_parameter_est([PrmsMat(1,:) LL_vec(1)])
    fprintf('Iter: %d | Runtime Part II: %0.2f min(s)\n',itr,toc/60);
end
fprintf('FINAL ESTIMATES\n')
fun_print_parameter_est([PrmsMat(1,:) LL_vec(1)])
prms_mle = PrmsMat(1,:);
LL_mle   = LL_vec(1);

if not(exist('Sobol_MLE/','dir')); mkdir('Sobol_MLE/'); end
save(sprintf('Sobol_MLE/Sobol_fmin_%s_N%d',save_str,N),'prms_mle','LL_mle')

if not(exist('Sobol_FMIN','dir')); mkdir('Sobol_FMIN'); end
save(['Sobol_FMIN/Sobol_FMIN_',save_str,sprintf('_N%dk%d',[N,n_est_prms]),'.mat'],'PrmsMat','LL_vec');