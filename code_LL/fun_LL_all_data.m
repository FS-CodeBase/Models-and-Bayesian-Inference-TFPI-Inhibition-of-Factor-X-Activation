function LL_tot = fun_LL_all_data(params_vec,sig,prms_info,y_idx,...
                            times_vec1,inData1,init_cond_mat1,...
                                times_vec2,inData2,init_cond_mat2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT 1) Baugh 1998 fig 2A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_dat1  = size(init_cond_mat1,1);
sig_vec = ones(n_dat1,1)*sig;
% exp_type = 1;
model_inputs_1 = [repmat(params_vec,n_dat1,1), init_cond_mat1, sig_vec];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPERIMENT 2) Baugh 1998 fig 2A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_dat2  = size(init_cond_mat2,1);
sig_vec = ones(n_dat2,1)*sig;
% exp_type = 2;
model_inputs_2 = [repmat(params_vec,n_dat2,1), init_cond_mat2, sig_vec];

%%%%%%%%%%%%%%%%%%%%%%%%%%
%  TOTAL Log-Likelihood  %
%%%%%%%%%%%%%%%%%%%%%%%%%%
inData = [inData1;inData2];
model_inputs = [model_inputs_1;model_inputs_2];

LL_vec = zeros(1,size(inData,1));
parfor data_idx = 1:(size(inData,1))
    if data_idx < 9
        % Experiment 1 (8 data sets)
        LL_vec(data_idx) = fun_LL(model_inputs(data_idx,:),...
                                prms_info,...
                                      y_idx,...
                                          times_vec1, ...
                                              inData(data_idx,:),...
                                                  1);
    else
        % Experiment 2
        LL_vec(data_idx) = fun_LL(model_inputs(data_idx,:),...
                                prms_info,...
                                      y_idx,...
                                          times_vec2, ...
                                              inData(data_idx,:),...
                                                  2);
    end
end
LL_tot = sum(LL_vec);
