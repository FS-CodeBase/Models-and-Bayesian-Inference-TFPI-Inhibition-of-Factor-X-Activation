function LL_data1 = fun_LL_exp1_data(params_vec,sig,prms_info,y_idx,...
                            times_vec1,inData1,init_cond_mat1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT 1) Baugh 1998 fig 2A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_dat1  = size(init_cond_mat1,1);
sig_vec = ones(n_dat1,1)*sig;
exp_type = 1;
model_inputs_1 = [repmat(params_vec,n_dat1,1), init_cond_mat1, sig_vec];

% Log-Likelihood for Dataset 1
LL_data1 = fun_LL_per_data(model_inputs_1,prms_info,y_idx,times_vec1,inData1,exp_type);
