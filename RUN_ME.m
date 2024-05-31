%% SCRIPT: RUN_ME.m shows how to run LHS and AM Algorithm:
%%         (1) Latin hypercube pre-exploration of parameters space with a
%%             uniform prior.
%%         (2) Use the Latin hypercube pre-exploration to form initial
%%             estimates for application of Adaptive metropolis.
%%         (3) Shows how to print the estimated parameter values
%% Author: Fabian Santiago
%% Last Edit: 5/30/24
%% Email: fsantiago3@ucmerced.edu

% Clear workspace
clear

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
NumSmps = 3000; % 600 LHS Samples
NumBlks = 6;   % Number of blocks for parallelization

% Generate Latin hypercube samples and break up into samples
fun_process_lhs_params_to_blocks(DataIdx,NumSmps,NumBlks)

% Compute the LogLikelihood for each parameter set, per block 
parfor block_idx = 1:NumBlks
    fun_sub_lhs_by_mat_block(DataIdx,block_idx,NumSmps,NumBlks)
end

% Combine all LHS blocks
fun_sub_combine_lhs_blocks(DataIdx,NumSmps,NumBlks)

%%%%%%%%%%%%%%% RUN ADAPTIVE METROPOLIS SAMPLING PARAMETERS %%%%%%%%%%%%%%%
% Set number Metropolis and Adaptive Metropolis iterations
ItrsMA = 20000; % Metropolis algorithm 
ItrsAM = 60000; % Adaptive Metropolis algorithm 

% Use LHS parameters to create initial matrices for Adaptive metropolis
% Estimates will be saved to AM_Ests_Model# folder
fun_sub_lhs_and_am_all_data(DataIdx,NumSmps,NumBlks,ItrsMA,ItrsAM)

% Contents of AM_Ests folder and parameter estimates file 
% AM_ParamEsts_Dataset1and2:
%   > PRMS: Parameter estimates by iterations. Each column represents one
%           parameter and each row is an accepted sample.
%   > Cmat1: Intial covariance
%   > Cmat2: Covariance during AM 
%   > LL_Vec: log-likelihood values per iteration

% Load AM samples
load('AM_Ests_M01/AM_ParamEsts_Dataset1and2.mat','PRMS')

% Compute median of samples for each column
med_prms = median(PRMS,1); 

% Print medians. false is a placeholder for the log-likelihood value
fun_print_parameter_est([med_prms false])

% Remove Latin hypercube sampling code from path
addpath('code_LHS/')

% Remove LogLikelihood code from path
addpath('code_LL/')

% Remove Adaptive Metropolis code from path
addpath('code_AM/')

% Remove model from path
addpath('Models/M01')
