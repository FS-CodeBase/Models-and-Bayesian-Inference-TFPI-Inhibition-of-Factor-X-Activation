function out_prms = fun_get_full_paramset(in_prms,prms_info)
prms_est = prms_info.prms_est; % boolean vector 1 by 16
prms_rem = prms_info.prms_rem; % boolean vector 1 by 16
prms_equ = prms_info.prms_equ; % n rows by 2 matrix
% KD_keep  = prms_info.KD_keep; % n rows by 2 matrix
% With prms_equ, parameter indices in the first column are set equal to 
% the value of those in the second column
% ub = [1,...     % [01] k_1on  = 1;   % Maximum value for k_1on 
%       238,...   % [02] k_1off = 238;  
%       238,...   % [03] k_cat  = 238; % ub value for kcat---Units=(1/s) KM is 
%       1,...     % [04] k_3on  = 1;   % diffusion limit 0.1 nM 
%       520,...   % [05] k_3off = 520; % diffusion limit 0.1 nM
%       1,...     % [06] k_4on  = 1; 
%       100,...   % [07] k_4off = 100; 
%       1,...     % [08] k_5on  = 1;
%       100,...   % [09] k_5off = 100;
%       1,...     % [10] k_6on  = 1;   % responsible for flipping the curves
%       100,...   % [11] k_6off = 100; % 3.6*10^(-4); 
%       500,...   % [12] k_7on  = 500; %tail up or down
%       100,...   % [13] k_7off = 10^(-3);
%       1,...     % [14] k_8on  = 1;
%       100];...  % [15] k_8off = 100;
% k_{-3} = (k_{-1}/k_1)*k_3

%%%%%%%%%%%%%%%%%%%%% Processing with known quantities %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute parameters
K_M = fun_get_KM;
KD3 = 520;
KD4 = 0.026264800769137;
KD_and_prms_set = fun_get_KDprmskeep;

% Set k_cat
if not(prms_est(2)) && KD_and_prms_set(2)
    in_prms(:,3) = 7;
end

% Compute k_1off
% If kcat or k1on are varied, need to make sure that k1 in (KM/k2,1)
if not(prms_est(2)) && KD_and_prms_set(1)
    in_prms(:,2) = (in_prms(:,1)*K_M-in_prms(:,3));
end

%%%%%%%%%%%%%%%%%%%%% Using Known KD values
% Set k_3off
if not(prms_est(5)) && KD_and_prms_set(3)
    in_prms(:,5) = KD3*in_prms(:,4);
end

% Set k_4off
if not(prms_est(7)) && KD_and_prms_set(4)
    in_prms(:,7) = KD4*in_prms(:,6);
end

%%%%%%%%%%%%%%%%%%%%% Known parameter values
% Set k_5on
if not(prms_est(8)) && KD_and_prms_set(5)
    in_prms(:,8) = 7.34*10^(-3);
    % in_prms(:,8) = 0;
end

% Set k_5off
if not(prms_est(9)) && KD_and_prms_set(6)
    in_prms(:,9) = 1.10*10^(-3);
    % in_prms(:,9) = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Remove Rates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
in_prms(:,prms_rem) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Equal Reactions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if not(isempty(prms_equ))
    % Modified 4/22/24
    % Need to estimate k_1, k_{-1}, k_3, and set k_{-3} by k_{-3} =
    % (k_{-1}/k1)*k_3
    % prms(5) = prms(2)/prms(1)*prms(4);
    in_prms(:,5) = (in_prms(:,2)./in_prms(:,1)).*in_prms(:,4);
    % in_prms(:,prms_equ(:,1)) = in_prms(:,prms_equ(:,2));
end

%%%%%%%%%%%%%%%%%%%%% Set out_parameters
out_prms = in_prms;

end