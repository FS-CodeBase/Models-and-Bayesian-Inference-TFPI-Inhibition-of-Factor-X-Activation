function tmpPRMS = fun_get_param_set(PRMS,unc_info)
prms_var  = unc_info.prms_info.prms_var;

% PARAMETERS
% k_1on [01]; k_1off [02]; k_2 [03];   k_3on [04];  k_3off [05];
% k_4on [06]; k_4off [07]; k_5on [08]; k_5off [09];
% k_6on [10]; k_6off [11]; k_7on [12]; k_7off [13];
% k_8on [14]; k_8off [15]; sigma [16];

% Choose AM chain parameter estimates
prms_med = unc_info.prms_med(1:15);

% Fix "on" rate, vary KD -> vary "off" rates
switch unc_info.var_type
    case 1
        fprintf('VARTYPE 1: Vary KDs, fix "on", vary "off" rates\n')
        if mod(sum(prms_var(1:15)),2)==1
            error('fun_get_param_set. Assumes only KDs are varied!')
        end
        num_samples = unc_info.num_samples;

        tmpPRMS = repmat(prms_med,num_samples,1);
        KDsidx = find(prms_var(1:15));
        KDsvec = prms_med(KDsidx(2:2:end))./prms_med(KDsidx(1:2:end));
        LHS_Mat = lhsdesign(num_samples,numel(KDsvec))+0.5;
        % k_off = (rand()*KD)*k_on
        % Set off rates
        tmpPRMS(:,KDsidx(2:2:end)) = tmpPRMS(:,KDsidx(1:2:end)).*KDsvec.*LHS_Mat;

    % Vary parameters by sampling from AM chain
    case 2  
        fprintf('VARTYPE 2: Vary rates according to posterior estimates \n')
        num_samples = unc_info.num_samples;
        % Set kinetic rates
        idx_samples = randi(size(PRMS,1),num_samples,1);
    
        tmpPRMS     = repmat(prms_med,num_samples,1);
        tmpPRMS(:,prms_var(1:15)) = PRMS(idx_samples,prms_var(1:15));

    % Fix KDs vary median paramater values
    case unc_info.var_type == 3
        fprintf('VARTYPE 3: Fix KDs vary rates by +/-50%%\n')
        if mod(sum(prms_var(1:15)),2)==1
            error('fun_get_param_set. Assumes KDs are fixed!')
        end
        if contains(unc_info.unc_type,'flow-ss')
            num_samples = unc_info.num_samples_ss;
        else
            num_samples = unc_info.num_samples;
        end
        tmpPRMS = repmat(prms_med,num_samples,1);
        KDsidx = find(prms_var(1:15));
        KDsvec = prms_med(KDsidx(2:2:end))./prms_med(KDsidx(1:2:end));
        LHS_Mat = lhsdesign(num_samples,numel(KDsvec))+0.5;
        koffs = tmpPRMS(:,KDsidx(1:2:end)).*KDsvec.*LHS_Mat;
        tmpPRMS(:,KDsidx(2:2:end)) = koffs;
        kons = tmpPRMS(:,KDsidx(1:2:end)).*LHS_Mat;
        kons(kons>1)               = 1; % No on rates greater than 1
        tmpPRMS(:,KDsidx(1:2:end)) = kons;
    case 4 
        fprintf(['VARTYPE 4: Fix KDs vary on and off rates by\n',...
            ' alpha = [1-2.^(-1:-1:-3),1,1+2.^(-3:1:-1)]\n'])
        alp_vec = [1-2.^(-1:-1:-3),1,1+2.^(-3:1:-1)];
        if mod(sum(prms_var(1:15)),2)==1
            error('fun_get_kflow_params. Assumes KDs are fixed!')
        end
        num_samples = numel(alp_vec);

        tmpPRMS = repmat(prms_med,num_samples,1);
        alp_sidx            = find(prms_var(1:15));
        tmpPRMS(:,alp_sidx) = tmpPRMS(:,alp_sidx).*alp_vec'; 
end

% Adjust other parameter values
% tmpPRMS = fun_get_full_paramset(tmpPRMS,unc_info.prms_info);
fprintf('EXPECTED: PRMS_VAR\n')
fun_print_parameter_est_bin(prms_var(1:15))
fprintf('ACTUAL: PRMS_VAR\n')
fun_print_parameter_est_bin(var(tmpPRMS(:,1:15))>eps)