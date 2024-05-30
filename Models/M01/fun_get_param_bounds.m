function [lb,ub] = fun_get_param_bounds
ub = [1,...     % [01] k_1on  = 1;   % Maximum value for k_1on 
      fun_get_KM,...   % [02] k_1off = 238;  
      fun_get_KM,...   % [03] k_cat  = 238; % ub value for kcat---Units=(1/s) KM is 
      1,...     % [04] k_3on  = 1; % diffusion limit 0.1 nM 
      200,...   % [05] k_3off = 520; % diffusion limit 0.1 nM
      1,...     % [06] k_4on  = 1; 
      1E-1,...   % [07] k_4off = 100; 
      1,...     % [08] k_5on  = 1;
      1,...   % [09] k_5off = 100;
      1,...     % [10] k_6on  = 1;  % responsible for flipping the curves
      100,...   % [11] k_6off = 100; % 3.6*10^(-4); 
      500,...   % [12] k_7on  = 500;%tail up or down
      1E-2,...   % [13] k_7off = 10^(-3);
      1,...     % [14] k_8on  = 1;
      100,...   % [15] k_8off = 100;
      0.50];    % [16] sigma  = 0.75; % proportional error

lb = zeros(1,16);
