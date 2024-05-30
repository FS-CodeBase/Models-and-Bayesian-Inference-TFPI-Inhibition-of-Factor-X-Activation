function [LL_,save_str] = fun_load_LL_by_data(data_idx,sim_dat,prms_info)
% Set Data and Initial conditions
% (11)[1] E (VIIa-Tf)   % (12)[2] S (X)     % (13)[3] ES 
% (14)[4] EP            % (15)[5] P (Xa)    % (16)[6] I (TFPI)
% (17)[7] PI            % (18)[8] PIE       % (19)[9] EPI
num_indep_vars = 9; % May change with different model
    
% Model output of interest is P (Xa) or idx = 5;
y_idx = 5;

% Load Simulated Data
SIG = 0.07; DEL = 1;
switch data_idx
    case 1 % %%%%% EXPERIMENT 1 (DIFFERENT INITIAL TFPI CONCENTRATIONS)
        save_str = 'Exp1';
        if sim_dat
            [time_vec_ex1,~,...
                DataExp1,~] = fun_create_simulated_data(SIG,DEL);
            save_str = [save_str,'SimData'];
        else
            [time_vec_ex1, DataExp1] = realData1;
            save_str = [save_str,'ExpData'];
        end
        % Initial concentrations of E (VIIa-TF)
        E0_vec = 0.001.*[32, 64, 128, 192, 256, 384, 512, 1024];
        
        % INITIAL CONDITIONS FOR EXPERIMENT _1_ %%%%%%%%%%
        S0 = 170; % Initial concentration of X (nM?)
        I0 = 2.4; % Initial concentration of TFPI (nM?)
        ICs_data1 = zeros(size(DataExp1,1),num_indep_vars);
        ICs_data1(:,1) = E0_vec;
        ICs_data1(:,2) = S0;
        ICs_data1(:,6) = I0;
    
        LL_ = @(x) fun_LL_exp1_data(x(1:15),x(16),prms_info,y_idx,...
                                    time_vec_ex1,DataExp1,ICs_data1);
    case 2 %%%%% EXPERIMENT 2 (PRE-INCUBATION)
        save_str = 'Exp2';
        if sim_dat
            [~, time_vec_ex2,...
                      ~,DataExp2] = fun_create_simulated_data(SIG,DEL);
            save_str = [save_str,'SimData'];
        else
            [time_vec_ex2, DataExp2] = realData2;
            save_str = [save_str,'ExpData'];
        end

        % INITIAL CONDITIONS FOR EXPERIMENT _2_ %%%%%%%%%%
        E0 = 0.128; % Initial concentration of E (VIIa-TF)
        S0 = 170;   % Initial concentration of X  (nM?)
        I0 = 2.4;   % Initial concentration of TFPI (nM?)
        
        % Initial concentrations of P (Xa)
        P0_vec = [0 0.25 0.5 1];
        ICs_data2 = zeros(size(DataExp2,1),num_indep_vars);
        ICs_data2(:,1) = E0;
        ICs_data2(:,2) = S0;
        ICs_data2(:,5) = P0_vec;
        ICs_data2(:,6) = I0;
        % Full likelihood
        LL_ = @(x) fun_LL_exp2_data(x(1:15),x(16),prms_info,y_idx,...
                                        time_vec_ex2,DataExp2,ICs_data2);
    case 3 %%%%% BOTH EXPERIMENTS
        save_str = 'ExpAll';
        if sim_dat
            [time_vec_ex1, time_vec_ex2,...
                      DataExp1, DataExp2] = fun_create_simulated_data(SIG,DEL);
            save_str = [save_str,'SimData'];
        else
            [time_vec_ex1, DataExp1] = realData1;
            [time_vec_ex2, DataExp2] = realData2;
            save_str = [save_str,'ExpData'];
        end
        % Initial concentrations of E (VIIa-TF)
        E0_vec = 0.001.*[32, 64, 128, 192, 256, 384, 512, 1024];
        
        % INITIAL CONDITIONS FOR EXPERIMENT _1_ %%%%%%%%%%
        S0 = 170; % Initial concentration of X (nM?)
        I0 = 2.4; % Initial concentration of TFPI (nM?)
        ICs_data1 = zeros(size(DataExp1,1),num_indep_vars);
        ICs_data1(:,1) = E0_vec;
        ICs_data1(:,2) = S0;
        ICs_data1(:,6) = I0;
        
        % INITIAL CONDITIONS FOR EXPERIMENT _2_ %%%%%%%%%%
        E0 = 0.128; % Initial concentration of E (VIIa-TF)
        S0 = 170;   % Initial concentration of X  (nM?)
        I0 = 2.4;   % Initial concentration of TFPI (nM?)
        
        % Initial concentrations of P (Xa)
        P0_vec = [0 0.25 0.5 1];
        ICs_data2 = zeros(size(DataExp2,1),num_indep_vars);
        ICs_data2(:,1) = E0;
        ICs_data2(:,2) = S0;
        ICs_data2(:,5) = P0_vec;
        ICs_data2(:,6) = I0;
        
        % Full likelihood
        LL_ = @(x) fun_LL_all_data(x(1:15),x(16),prms_info,y_idx,...
                                    time_vec_ex1,DataExp1,ICs_data1,...
                                        time_vec_ex2,DataExp2,ICs_data2);
end
