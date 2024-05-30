%% SCRIPT: RUN_ME.m shows how to run LHS and AM Algorithm:
%%         (1) Latin hypercube pre-exploration of parameters space with a
%%             uniform prior.
%%         (2) Use the Latin hypercube pre-exploration to form initial
%%             estimates for application of Adaptive metropolis.
%% Author: Fabian Santiago
%% Last Edit: 5/30/24
%% Email: fsantiago3@ucmerced.edu

% Add Latin hypercube sampling code to path
addpath('code_LHS/')

% Add Likelihood code to path
addpath('code_LL/')

% Add Adaptive Metropolis code to path
addpath('code_AM/')

% Add Model to path
% Model 01: Main model considered in the main text
% Model 02: Alternate model considered in the main text
% Comment addpath('Models/M01') and uncomment addpath('Models/M02') to run
% estimates for model two.
addpath('Models/M01')
% addpath('Models/M02')

%%%%%%%%%%%%%%%%% RUN LATIN HYPERCUBE SAMPLING PARAMETERS %%%%%%%%%%%%%%%%%
DataIdx = 3;   % 1 = Dataset 1, 2 = Dataset 2, 3 = Dataset 1 and 2
NumSmps = 600; % 600 LHS Samples
NumBlks = 6;   % Number of blocks for parallelization

% Generate Latin hypercube samples and break up into samples
fun_process_lhs_params_to_blocks(DataIdx,NumSmps,NumBlks)

% Compute LL for each parameter set per block 
parfor block_idx = 1:NumBlks
    fun_sub_lhs_by_mat_block(DataIdx,block_idx,NumSmps,NumBlks)
end

% Combine all LHS blocks
fun_sub_combine_lhs_blocks(DataIdx,NumSmps,NumBlks)

%%%%%%%%%%%%%%% RUN ADAPTIVE METROPOLIS SAMPLING PARAMETERS %%%%%%%%%%%%%%%
% Set number Metropolis and Adaptive Metropolis iterations
ItrsMA = 1000; % Metropolis algorithm 
ItrsAM = 6000; % Adaptive Metropolis algorithm 

% Use LHS parameters to create initial matrices for Adaptive metropolis
% Estimates will be saved to AM_Ests_Model# folder
fun_sub_lhs_and_am_all_data(DataIdx,NumSmps,NumBlks,ItrsMA,ItrsAM)

% Remove Latin hypercube sampling code from path
addpath('code_LHS/')

% Remove LogLikelihood code from path
addpath('code_LL/')

% Remove Adaptive Metropolis code from path
addpath('code_AM/')

% Remove model from path
addpath('Models/M01')
