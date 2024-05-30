function res = fun_LL(model_inputs,prms_info,y_idx,time_vec,data_vec,exp_type)

LogL =@(x,mu,sig) -log(sig)-log(sqrt(2*pi))-((x - mu)./sig).^2/2;

% Returns 15 model parameters (same for both experiments)
full_prms_set = fun_get_full_paramset(model_inputs(1:15),prms_info);
% fun_print_parameter_est([full_prms_set NaN])
% PARAMETERS
% k_1on [01]; k_1off [02]; k_2 [03];   k_3on [04];  k_3off [05];
% k_4on [06]; k_4off [07]; k_5on [08]; k_5off [09];
% k_6on [10]; k_6off [11]; k_7on [12]; k_7off [13];
% k_8on [14]; k_8off [15];

% INITIAL CONDITIONS
% E   [16]; S   [17]; % ES  [18]; EP  [19]; 
% P   [20]; I   [21]; % PI  [22]; PIE [23]; % EPI [24];

% MODEL VAR
% sig = [25];
sig = model_inputs(25); % Model standard deviation

switch exp_type
    % Simulated data of Experiment 1 Type %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 1
        % Extract initial conditions
        init_cond = model_inputs(16:24); % Experiment 1

        % Run Experiment 1 simulation
        [~,res_out] = ode23s(@(t,y) RHS(t,y,full_prms_set),...
                                    time_vec,...
                                        init_cond);
    case 2
        % Phase 1) Preincubation of TFPI with Xa
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Extract initial conditions (for preincubation)
        init_cond      = zeros(1,9); % 9 states in ODE RHS
        init_cond(5:6) = model_inputs(20:21); % Set initial P (Xa)  and I (TFPI)
        phase_one_time = [0 (120*60)]; % !!need to verify this time
        [~,tmp_res_out]    = ode23s(@(t,y) RHS(t,y,full_prms_set),...
                                    phase_one_time,...
                                        init_cond);

        % Phase 2) Post-incubation dynamics
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update initial conditions following preincubation
        init_cond      = zeros(1,9);
        init_cond(1:2) = model_inputs(16:17);  % Initial conditions of Experiment 2
        init_cond(5:7) = tmp_res_out(end,5:7); % I, P, PI, initial conditions

        % Run Experiment 2 simulation
        [~,res_out] = ode23s(@(t,y) RHS(t,y,full_prms_set),...
                                            time_vec,...
                                                init_cond);
end

% Compute logLikelihood
%%%%%%%%%%%%%%%%%%%%%%%
res = sum(LogL(data_vec(2:end)',res_out(2:end,y_idx),...
                                res_out(2:end,y_idx).*sig),'all');