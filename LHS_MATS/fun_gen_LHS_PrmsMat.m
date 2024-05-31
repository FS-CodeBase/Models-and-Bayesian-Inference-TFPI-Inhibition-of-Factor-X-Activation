function PrmsMat = fun_gen_LHS_PrmsMat(N_samples,k_params)

rng(2023);
disp(['ParamsMat_N',num2str(N_samples),'prms',num2str(k_params)])
tic
PrmsMat = lhsdesign(N_samples,k_params);
save(['ParamsMat_N',num2str(N_samples),'prms',num2str(k_params),'.mat'],...
            'PrmsMat','N_samples','k_params');
sprintf('Elapsed time: %0.2f mins',toc/60)