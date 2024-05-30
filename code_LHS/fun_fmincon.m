function [mle,LL_val] = fun_fmincon(fun_LL_,init_prm_ests,prms_info)
prms_est = prms_info.prms_est;
prms_rem = prms_info.prms_rem;
prms_equ = prms_info.prms_equ;

% Set Up For Optimization
options = optimoptions('fmincon','Display','off','MaxIterations',100000);
nonlcon =[];
KM  = fun_get_KM;
KD3 = 520;
KD4 = 0.026264800769137;

% Model Constraints for FMINCON
A = zeros(16,16);
b = zeros(16,1);

% k2/KM < k1   => k2 < k1*KM  =>  - k1*KM + k2 < 0 
A(1,1) = -KM;
A(1,3) = 1;
% Aeq = zeros(1,length(init_prm_ests));
% [ (1)   (2)  (3)  (4)  (5)   (6) (7) 
% [k1on k1off kcat k3on k3off k4on k4off...] row 1
% [k1on k1off kcat k3on k3off k4on k4off...] row 2
% [k1on k1off kcat k3on k3off k4on k4off...] row 3

% Need to satisfy k1off = KM*k1on-kcat
% -> 0 = KM*k1on - k1off - kcat => [KM -1 -1]
Aeq = zeros(16,16);
if not(prms_est(2))
    Aeq(2,1) = -KM;
    Aeq(2,2) = 1;
    Aeq(2,3) = 1; 
end
beq  = zeros(16,1); 

% Set k_3off (if not estimated)
% Need to satisfy k3off = KD3*k3on
if isempty(prms_equ)
    if not(prms_est(5))
        Aeq(5,4) = -KD3;
        Aeq(5,5) = 1;
    end
else
    if not(prms_est(5)) && not(any(prms_equ(:,1)==5))
        Aeq(5,4) = -KD3;
        Aeq(5,5) = 1;
    end
end

% Set k_4off (if not estimated)
% k_4off = KD4*kon => [
if isempty(prms_equ)
    if not(prms_est(7))
        Aeq(7,6) = -KD4;
        Aeq(7,7) = 1;
    end
else
    if not(prms_est(7)) && not(any(prms_equ(:,1)==7))
        Aeq(7,6) = -KD4;
        Aeq(7,7) = 1;
    end
end

% Equal Reactions
for i = 1:size(prms_equ,1)
    Aeq(prms_equ(i,1),prms_equ(i,1)) = -1;
    Aeq(prms_equ(i,1),prms_equ(i,2)) = 1;
end

% Zero Reaction
Aeq(diag(prms_rem)) = 1;
[lb,ub] = fun_get_param_bounds;
% lb(~prms_est) = init_prm_ests(~prms_est);
% ub(~prms_est) = init_prm_ests(~prms_est);

% Find the Maximum Likelihood Estimate for the Parameters
[mle,LL_val] = fmincon(fun_LL_,init_prm_ests,A,b,Aeq,beq,lb,ub,nonlcon,options);
LL_val = -LL_val;
% % % % function [mle,LL_val] = fun_fmincon(fun_LL_,init_prm_ests,prms_info)
% % % % prms_est = prms_info.prms_est;
% % % % 
% % % % % Set Up For Optimization
% % % % options = optimoptions('fmincon','Display','off','MaxIterations',100000);
% % % % nonlcon =[];
% % % % KM  = fun_get_KM;
% % % % if not(KM==238)
% % % %     warning('K_M is not 238')
% % % % end
% % % % 
% % % % % Model Constraints for FMINCON
% % % % % [ (1)   (2)  (3)  (4)  (5)   (6) (7) 
% % % % % [k1on k1off kcat k3on k3off k4on k4off...] row 1
% % % % % [k1on k1off kcat k3on k3off k4on k4off...] row 2
% % % % % [k1on k1off kcat k3on k3off k4on k4off...] row 3
% % % % % Make sure k1 > k2/238  =>  k2 - k1*238 < 0  [-238 0 1 0 ...]
% % % % nest = sum(prms_est);
% % % % A = zeros(nest,nest);
% % % % if prms_est(1) && prms_est(3)
% % % %     A(1,1) = -KM;
% % % %     A(1,3) = 1;
% % % % end
% % % % b = zeros(nest,1);
% % % % 
% % % % % Aeq = zeros(1,length(init_prm_ests));
% % % % % [ (1)   (2)  (3)  (4)  (5)   (6) (7) 
% % % % % [k1on k1off kcat k3on k3off k4on k4off...] row 1
% % % % % [k1on k1off kcat k3on k3off k4on k4off...] row 2
% % % % % [k1on k1off kcat k3on k3off k4on k4off...] row 3
% % % % 
% % % % % Need to satisfy k1off = KM*k1on-kcat
% % % % % -> 0 = KM*k1on - k1off - kcat => [KM -1 -1]
% % % % Aeq = zeros(nest,nest);
% % % % if not(prms_est(2))
% % % %     Aeq(1,1) = -KM;
% % % %     Aeq(1,2) = 1;
% % % %     Aeq(1,3) = 1; 
% % % % end
% % % % 
% % % % % Add information about equal reactions
% % % % prms_idx = find(prms_est);
% % % % 
% % % % beq  = zeros(nest,1); 
% % % % 
% % % % % Remove bounds for parameters not estimated
% % % % [lb,ub] = fun_get_param_bounds;
% % % % lb(~prms_est) = [];
% % % % ub(~prms_est) = [];
% % % % 
% % % % % Find the Maximum Likelihood Estimate for the Parameters
% % % % [mle,LL_val] = fmincon(fun_LL_,init_prm_ests,A,b,Aeq,beq,lb,ub,nonlcon,options);
% % % % LL_val       = -LL_val;