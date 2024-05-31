function [PRMS,Cmat1,Cmat2,LL_vec] = am_alg(am_info)
% FUNCTION: AM_alg
% % Author: Fabian Santiago
% % E-mail: FabianSantiago707@gmail.com
% 
% DESCRIPTION: 
% INPUTS:
% % LL_: log-likelihood function LL_(x)
% % Prms0: initial parameter values
% % Vn: Initial covariance matrix
% % nonad_iters: number of iterations for Metropolis Algorithm
% % ad_iters: number of adaptive metropolis (AM) iterations
% 
% OUTPUT:
% % PRMS: Parameter estimates by iterations
% % Cmat1: Intial covariance
% % Cmat2: Covariance during AM 
% % LL_Vec: log-likelihood values per iteration

prms_info      = am_info.prms_info;
prms_est       = prms_info.prms_est;
non_adapt_itrs = am_info.non_adapt_itrs;
adapt_itrs     = am_info.adapt_itrs;
data_idx       = am_info.data_idx;
sim_dat        = am_info.sim_dat;
nprms_est      = sum(prms_est);

% Non Adapt and Adapt Print at
mod_non_adapt = 100;
mod_adapt     = 100;
% mod_non_adapt = 1000;
% mod_adapt     = 5000;

Vn    = am_info.Cn; % 3
Prms0 = am_info.Mu;
n_tot = numel(Prms0);
n_est = sum(prms_est);

% Print starting parameters and estimated parameters binary
fun_print_parameter_est_bin(Prms0);
fun_print_parameter_est(Prms0);

% Assures only prms_est will be generated.
ZeroMat = ones(n_tot);
ZeroMat(not(prms_est),:) = 0;
ZeroMat(:,not(prms_est)) = 0; 

[LL_,dat_str] = fun_load_LL_by_data(data_idx,sim_dat,prms_info);

% Store iteration chain
PRMS = [Prms0;zeros(adapt_itrs+non_adapt_itrs-1,n_tot)];

% Previous parameter values
PrmsPre = Prms0;

% True parameters
% PrmsTrue = Parameter_set;
LL_vec = zeros(1,non_adapt_itrs+adapt_itrs);

% Previous log-likelihood
LLpre = LL_(PrmsPre);
LL_vec(1) = LLpre; % Initial log-likelihood 

% For Stability
sp = (2.38)^2/(n_est); 

[lb,ub] = fun_get_param_bounds;

Vn = sp*Vn;%+EPS*Ip; % For stability

% Save folder
f_id = am_info.f_id;
if(not(exist(f_id,'dir'))),mkdir(f_id);end

% Step 1: NON-ADAPTIVE METROPOLIS STEP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
for itr = 2:(non_adapt_itrs)
    [PrmsTmp,LLtmp] = rnd_prm_sample_ma(LL_,PrmsPre,prms_info,Vn,lb,ub);

    if rand() < min([1 exp(LLtmp-LLpre)])
        PRMS(itr,:) = PrmsTmp; 
        LLpre   = LLtmp;
        PrmsPre = PrmsTmp;
        LL_vec(itr) = LLtmp;
    else
        PRMS(itr,:) = PrmsPre; 
        LL_vec(itr) = LLpre; 
    end
    if mod(itr,mod_non_adapt)==0
        current_dur  = toc/(60*60);
        expected_dur = (current_dur/itr)*non_adapt_itrs;
        disp('[Part 1 IP] MA Alg Est:---------------------------------------------------')
            fprintf('MA with [%s] iteration: %d | runtime: %0.2f hrs | E(MA runtime): %0.2f hrs | Complete: %0.3f%%\n',...
                        dat_str,itr,current_dur,expected_dur,current_dur/expected_dur*100);
        if itr > 5*10^4
            fprintf('Itr %d:Updated Metropolis Algorithm Covariance Matrix\n',itr);
            Vn = sp*diag(var(PRMS)).*ZeroMat;
        end
    end
end

% Compute covariance from non-adaptive step
Cmat1 = cov(PRMS(1:non_adapt_itrs,:));
Cmat2 = Cmat1;
Vn = (sp*Cmat1).*ZeroMat;

disp('[I] MA Alg Est:----------------------------------------------------')
fun_print_parameter_est([PRMS(non_adapt_itrs,:) LL_vec(non_adapt_itrs)]);
fun_print_parameter_est(PRMS(non_adapt_itrs,1:end-1));

% Step 2: ADAPTIVE METROPOLIS STEP 1/3
curr_itr = itr+1;
for itr = curr_itr:(curr_itr+mod_adapt)
    [PrmsTmp,LLtmp] = rnd_prm_sample_am_one(LL_,PrmsPre,prms_info,Vn,lb,ub);
    
    if rand() < min([1 exp(LLtmp-LLpre)])
        PRMS(itr,:) = PrmsTmp; 
        LLpre   = LLtmp;
        PrmsPre = PrmsTmp;
        LL_vec(itr) = LLtmp;
%         accept = accept + 1;    
    else
        PRMS(itr,:) = PrmsPre;
        LL_vec(itr) = LLpre;
    end

    % Update covariance every 1000 iterations
    if mod(itr-non_adapt_itrs,1000)==0
        Vn = (sp*cov(PRMS(non_adapt_itrs:itr,:))).*ZeroMat;
    end
	
    if mod(itr-non_adapt_itrs,mod_adapt)==0
	    current_dur  = toc/(60*60*24);
	    expected_dur = (current_dur/(itr-non_adapt_itrs))*adapt_itrs;
        disp('[Part 2 1/3 IP] AM Alg Est:---------------------------------------------------')
	    fprintf('AM with [%s] iteration: %d | runtime: %0.3f days | E(AM runtime): %0.3f days | Complete: %0.3f%%\n',...
			dat_str,itr,current_dur,expected_dur,current_dur/expected_dur*100);
        fun_print_parameter_est([PRMS(itr,:) LL_vec(itr)]);
        fun_print_parameter_est(PRMS(itr,1:end-1));
        switch dat_str
            case 'Exp1ExpData'
                save([f_id,'/AM_ParamEsts_Dataset1'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
            case 'Exp2ExpData'
                save([f_id,'/AM_ParamEsts_Dataset2'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
            case 'ExpAllExpData'
                save([f_id,'/AM_ParamEsts_Dataset1and2'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
        end
    end
end
disp('[1/3 end] AM Alg Est:---------------------------------------------------')

% Step 2: ADAPTIVE METROPOLIS STEP 2/3
curr_itr = itr+1;
for itr = curr_itr:(curr_itr+mod_adapt)
    [PrmsTmp,LLtmp] = rnd_prm_sample_am_two(LL_,PrmsPre,prms_info,Vn,lb,ub);
    
    if rand() < min([1 exp(LLtmp-LLpre)])
        PRMS(itr,:) = PrmsTmp; 
        LLpre   = LLtmp;
        PrmsPre = PrmsTmp;
        LL_vec(itr) = LLtmp;    
    else
        PRMS(itr,:) = PrmsPre;
        LL_vec(itr) = LLpre;
    end

    % Update covariance every 1000 iterations
    if mod(itr-non_adapt_itrs,1000)==0
        Vn = (sp*cov(PRMS(non_adapt_itrs:itr,:))).*ZeroMat;
    end
	
    if mod(itr-non_adapt_itrs,mod_adapt)==0
	    current_dur  = toc/(60*60*24);
	    expected_dur = (current_dur/(itr-non_adapt_itrs))*adapt_itrs;
        disp('[Part 2 2/3 IP] AM Alg Est:---------------------------------------------------')
	    fprintf('AM with [%s] iteration: %d | runtime: %0.3f days | E(AM runtime): %0.3f days | Complete: %0.3f%%\n',...
			dat_str,itr,current_dur,expected_dur,current_dur/expected_dur*100);
        fun_print_parameter_est([PRMS(itr,:) LL_vec(itr)]);
        fun_print_parameter_est(PRMS(itr,1:end-1));
        switch dat_str
            case 'Exp1ExpData'
                save([f_id,'/AM_ParamEsts_Dataset1'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
            case 'Exp2ExpData'
                save([f_id,'/AM_ParamEsts_Dataset2'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
            case 'ExpAllExpData'
                save([f_id,'/AM_ParamEsts_Dataset1and2'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
        end
    end
end

disp('[2/3 end] AM Alg Est:---------------------------------------------------')

% Step 2: ADAPTIVE METROPOLIS STEP 3/3
curr_itr = itr+1;
for itr = curr_itr:(non_adapt_itrs+adapt_itrs)
    [PrmsTmp,LLtmp] = rnd_prm_sample_am_three(LL_,PrmsPre,prms_info,Vn,lb,ub);
    
    if rand() < min([1 exp(LLtmp-LLpre)])
        PRMS(itr,:) = PrmsTmp; 
        LLpre   = LLtmp;
        PrmsPre = PrmsTmp;
        LL_vec(itr) = LLtmp;
%         accept = accept + 1;    
    else
        PRMS(itr,:) = PrmsPre;
        LL_vec(itr) = LLpre;
    end

    % Update covariance every 1000 iterations
    if mod(itr-non_adapt_itrs,1000)==0
        Vn = (sp*cov(PRMS(non_adapt_itrs:itr,:))).*ZeroMat;
    end
	
    if mod(itr-non_adapt_itrs,mod_adapt)==0
	    current_dur  = toc/(60*60*24);
	    expected_dur = (current_dur/(itr-non_adapt_itrs))*adapt_itrs;
        disp('[Part 2 3/3 IP] AM Alg Est:---------------------------------------------------')
	    fprintf('AM with [%s] iteration: %d | runtime: %0.3f days | E(AM runtime): %0.3f days | Complete: %0.3f%%\n',...
			dat_str,itr,current_dur,expected_dur,current_dur/expected_dur*100);
        fun_print_parameter_est([PRMS(itr,:) LL_vec(itr)]);
        fun_print_parameter_est(PRMS(itr,1:end-1));
        switch dat_str
            case 'Exp1ExpData'
                save([f_id,'/AM_ParamEsts_Dataset1'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
            case 'Exp2ExpData'
                save([f_id,'/AM_ParamEsts_Dataset2'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
            case 'ExpAllExpData'
                save([f_id,'/AM_ParamEsts_Dataset1and2'],...
                'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
        end
    end
end
disp('[3/3 end] AM Alg Est:---------------------------------------------------')
Cmat2 = Vn;

switch dat_str
    case 'Exp1ExpData'
        save([f_id,'/AM_ParamEsts_Dataset1'],...
        'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
    case 'Exp2ExpData'
        save([f_id,'/AM_ParamEsts_Dataset2'],...
        'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
    case 'ExpAllExpData'
        save([f_id,'/AM_ParamEsts_Dataset1and2'],...
        'PRMS','Cmat1','Cmat2','LL_vec','am_info','itr','-v7.3');
end