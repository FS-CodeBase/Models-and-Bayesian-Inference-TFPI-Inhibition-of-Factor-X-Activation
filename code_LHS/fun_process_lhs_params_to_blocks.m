function fun_process_lhs_params_to_blocks(data_idx,LHS_N,LHS_B)
MA_N = nan;
AM_N = nan;
lhs_info = fun_get_model_and_param_details(data_idx,LHS_N,LHS_B,MA_N,AM_N);

% PROCESS LHS MATRIX AND SAVE BLOCKS
prms_info = lhs_info.prms_info;
prms_est  = prms_info.prms_est;
% sub_lhs   = lhs_info.sub_lhs;
N         = lhs_info.N;
B         = lhs_info.B; % Number of processors
data_idx  = lhs_info.data_idx;
sim_dat   = lhs_info.sim_dat;

lhs_size = N; 

[~,save_str] = fun_load_LL_by_data(data_idx,sim_dat,prms_info);

% Number of parameters to be estimated
n_est_prms = sum(prms_est);

% Initialize parameters matrix (set known values)
PrmsMatTmp = fun_get_full_paramset(zeros(lhs_size,16),prms_info);

% Load LHS matrix
disp('Creating LHS Parameter Samples')
LHS.PrmsMat = lhsdesign(N,n_est_prms);
KM          = fun_get_KM;
KDprms_keep = fun_get_KDprmskeep;
[lb,ub] = fun_get_param_bounds;

% Do not shift any pre-set parameter values
prm_sum       = sum(PrmsMatTmp,1);
lb(prm_sum>0) = 0;
ub(prm_sum>0) = 1;

% Sample and shift parameters
PrmsMatTmp(:,prms_est) = LHS.PrmsMat;

% PARAMETERS
% k_1on [01]; k_1off [02]; k_2 [03];   k_3on [04];  k_3off [05];
% k_4on [06]; k_4off [07]; k_5on [08]; k_5off [09];
% k_6on [10]; k_6off [11]; k_7on [12]; k_7off [13];
% k_8on [14]; k_8off [15];

% Make k_2 (k_cat) to be in the range [0,K_M] or [0,ub]
% (MUST BE DONE FIRST, k1on and k1off depend in this)
if prms_est(3) && not(KDprms_keep(2))
    UB = min(ub(3),KM);
    LB = max(lb(3),0);
    % Step 1: Sample k2 (kcat)
    PrmsMatTmp(:,3) = PrmsMatTmp(:,3)*(UB-LB)+LB;
    ub(3) = 1; lb(3) = 0; % Temporary. To preserve PrmsMatTmp.*(ub-lb)+lb
end

% Make k_1on be in the range [k_2/KM,1]
% Only do this if KM is known (k1off = k1on*KM-kcat)
if prms_est(1) && not(prms_est(2))
    UB = min(ub(1),1);
    LB = max(lb(1),PrmsMatTmp(:,3)/KM);
    % Step 2: Sample k1on
    PrmsMatTmp(:,1)  = PrmsMatTmp(:,1).*(UB-LB) + LB;
    ub(1) = 1; lb(1) = 0; % Temporary. To preserve PrmsMatTmp.*(ub-lb)+lb
end

% Make k_1off be in the range [lb,238-k2] (IF being estimated)
if prms_est(2)
    UB = KM-PrmsMatTmp(:,3);
    LB = lb(2);
    % Step 2: Sample k1off
    PrmsMatTmp(:,2)  = PrmsMatTmp(:,2).*(UB-LB) + LB;
    ub(2) = 1; lb(2) = 0; % Temporary. To preserve PrmsMatTmp.*(ub-lb)+lb
end

% Do not shift parameters that are not being estimated
lb(~prms_est) = 0;
ub(~prms_est) = 1;

% Replace parameters with sampled parameters
PrmsMatFin = fun_get_full_paramset(PrmsMatTmp.*(ub-lb)+lb,prms_info); % ub(?) = 1 and lb(?) = 0 ;-) 

BLOCKS  = fun_get_index_blocks(B,N);
lhs_dir = 'LHS_MATS/';
if not(exist(lhs_dir,'dir')); mkdir(lhs_dir); end
for idx = 1:B
    PrmsMat = PrmsMatFin(BLOCKS(1,idx):BLOCKS(2,idx),:);
    save(['LHS_MATS/LHS_PRMS_',save_str,sprintf('_N%dk%d_Block%dof%d',...
            [N,n_est_prms,idx,B]),'.mat'],'PrmsMat');
end
