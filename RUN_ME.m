% SCRIPT: RUN_ME.m shows how to run:
%         (1) Latin hypercube pre-exploration of parameters space with a
%             uniform prior.
%         (2) Use the Latin hypercube pre-exploration to form initial
%             estimates for application of Adaptive metropolis.
% Author: Fabian Santiago
% Last Edit: 5/29/24
% Email: fsantiago3@ucmerced.edu

% Add Latin hypercube sampling code to path
addpath('code_LHS/')

% Add Likelihood code to path
addpath('code_LL/')

% Add Adaptive Metropolis code to path
addpath('code_AM/')

% Add model to path
% Model 01: Main model considered in the main text
% Model 02: Alternate model considered in the main text
addpath('Models/M01')

% Generate Latin hypercube samples and break up into samples
fun_process_lhs_params_to_blocks(3,600,6)

% Compute LL for each parameter set per block 
for block_idx = 1:6
    fun_sub_lhs_by_mat_block(3,block_idx,600,6)
end

% Combine all LHS blocks
fun_sub_combine_lhs_blocks(3,600,6)

% Use LHS parameters to create initial matrices for Adaptive metropolis
% Estimates will be saved to AM_Ests folder
fun_sub_lhs_and_am_all_data(3,600,6,10000,60000)

% Remove Latin hypercube sampling code from path
addpath('code_LHS/')

% Remove LogLikelihood code from path
addpath('code_LL/')

% Remove Adaptive Metropolis code from path
addpath('code_AM/')

% Remove model from path
addpath('Models/M01')