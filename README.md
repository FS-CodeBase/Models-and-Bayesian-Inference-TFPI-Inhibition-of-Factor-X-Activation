# TFPI_Inhibition_of_Factor_X_Activation_Code
Code for "A New Look at TFPI Inhibition of Factor X Activation"

See the RUN_ME.m Matlab code to see how to: 
(1) Run the code to perform the Latin hypercube pre-exploration of the 
    parameter space
(2) Run the Adaptive Metropolis code using the pre-exploration using LHS
(3) How to print the median estimates

NOTE: The adaptive Metropolis code prints an estimate of how long it will
      take for the desired iterations to be completed. To test the code, 
      just set ItrsMA = 200 and ItrsAM = 600.