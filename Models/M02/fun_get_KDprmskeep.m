function res = fun_get_KDprmskeep
% [1] Set k_1off
% [2] Set k_2off
% [3] Set k_3off
% [4] Set k_4off
% [5] Set k_5on
% [6] Set k_5off
res = true(1,6);
res([2 5:6]) = false;