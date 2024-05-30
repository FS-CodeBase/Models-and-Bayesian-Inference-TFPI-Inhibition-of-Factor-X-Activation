function LL_data2 = fun_LL_exp2_data(params_vec,sig,prms_info,y_idx,...
                                times_vec2,inData2,init_cond_mat2)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % EXPERIMENT 2) Baugh 1998 fig 2A
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_dat2  = size(init_cond_mat2,1);
sig_vec = ones(n_dat2,1)*sig;
exp_type = 2;
model_inputs_2 = [repmat(params_vec,n_dat2,1), init_cond_mat2, sig_vec];

% Log-likelihood for Dataset 2
LL_data2 = fun_LL_per_data(model_inputs_2,prms_info,y_idx,times_vec2,inData2,exp_type);
