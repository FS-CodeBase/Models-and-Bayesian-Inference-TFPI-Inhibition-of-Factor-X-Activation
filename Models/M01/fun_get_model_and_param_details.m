function [lhs_info,am_info] = fun_get_model_and_param_details(data_idx,LHS_N,LHS_B,MA_N,AM_N)
% Both IB and DB
LHS_SUB  = 100; % Number of LHS subsamples to use fmincon on
% LHS_B = 6;
prms_est = true(1,16); % For fun_get_param_bounds

% PARAMETERS
% k_1on [01]; k_1off [02]; k_2 [03];   k_3on [04];  k_3off [05];
% k_4on [06]; k_4off [07]; k_5on [08]; k_5off [09];
% k_6on [10]; k_6off [11]; k_7on [12]; k_7off [13];
% k_8on [14]; k_8off [15]; sigma [16];

% Do not estimate
prms_est(2) = false;   % k_1off [02]; KM knowm
prms_est(7) = false;   % k_4off [07]; KD4 known
prms_est(5) = false;   % k_3off [05];
prms_est(8:9) = false; % k_5on  [08]; k_5off [09];
 
%%%%%% ZERO OUT REACTIONS
prms_rem = false(1,16);
prms_rem(8:9) = true; % Reaction 5 equals zero

%%%%%% SET RATES EQUAL
% R1=[1,2]; R3=[4,5]; R8=[14,15];
% Example: R3 <- R1 is [R3;R1]'
prms_equ = []; % Set to [] if none

%%%%%% NONE ESTIMATED PARAMETERS %%%%%
% PARAMETERS SET TO ZERO
prms_est(prms_rem) = false;

% PARAMETERS SET TO ANOTHER REACTION RATES
if not(isempty(prms_equ))
	prms_est(prms_equ(:,1)) = false;
end

prms_info.prms_est = prms_est; % boolean vector 1 by 16
prms_info.prms_rem = prms_rem; % boolean vector 1 by 16
prms_info.prms_equ = prms_equ; % n rows by 2 matrix

% data_idx = 3; % data_idx = 1 (Experiment 1), 2 (Exp 2), 3 (Exp 1 & 2)
sim_dat  = false; % true (simulate data), false (experimental data) 

tic
lhs_info.prms_info = prms_info;
lhs_info.sub_lhs   = LHS_SUB;
lhs_info.N         = LHS_N;
lhs_info.B         = LHS_B;
lhs_info.data_idx  = data_idx;
lhs_info.sim_dat   = sim_dat;
lhs_info.f_id      = 'FMIN_Ests'; % Can be changed dynamically

% Set Adaptive Metropolis parameters
am_info.restart = false;
am_info.prms_info = prms_info;
am_info.data_idx  = data_idx;
am_info.sim_dat   = sim_dat;
am_info.non_adapt_itrs = MA_N;
am_info.adapt_itrs     = AM_N; 
am_info.mcsmps         = 1;
am_info.f_id           = 'AM_Ests_M01'; 
