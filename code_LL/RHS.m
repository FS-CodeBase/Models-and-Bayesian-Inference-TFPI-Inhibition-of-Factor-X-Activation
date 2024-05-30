function dy = RHS(t,y,p)

dy = zeros(9,1);


% Rename Variables 

E   = y(1); S   = y(2); ES  = y(3); 
EP  = y(4); P   = y(5); I   = y(6); 
PI  = y(7); PIE = y(8); EPI = y(9); 


% Rename Kinetic Parameters 
k_1on  = p(1);   k_1off = p(2);   k_2    = p(3);  
k_3on  = p(4);   k_3off = p(5);   k_4on  = p(6);  
k_4off = p(7);   k_5on  = p(8);   k_5off = p(9);  
k_6on  = p(10);  k_6off = p(11);  k_7on  = p(12);  
k_7off = p(13);  k_8on  = p(14);  k_8off = p(15);  

%------------------------------------%
%--- ODEs from reaction equations ---%
%------------------------------------%

% E
 dy(1)  =  -  k_1on * E * S  +  k_1off * ES  -  k_3on * E * P  +  k_3off * EP  -  k_5on * E * PI  +  k_5off * PIE  -  k_8on * E * PI  +  k_8off * EPI;

% S
 dy(2)  =  -  k_1on * E * S  +  k_1off * ES;

% ES
 dy(3)  =  +  k_1on * E * S  -  k_1off * ES  -  k_2 * ES;

% EP
 dy(4)  =  +  k_2 * ES  +  k_3on * E * P  -  k_3off * EP  -  k_6on * EP * I  +  k_6off * EPI;

% P
 dy(5)  =  -  k_3on * E * P  +  k_3off * EP  -  (k_4on * P * I)  +  k_4off * PI;

% I
 dy(6)  =  -  (k_4on * P * I)  +  k_4off * PI  -  k_6on * EP * I  +  k_6off * EPI;

% PI
 dy(7)  =  +  k_4on * P * I  -  k_4off * PI  -  k_5on * E * PI  +  k_5off * PIE  -  k_8on * E * PI  +  k_8off * EPI;

% PIE
 dy(8)  =  +  k_5on * E * PI  -  k_5off * PIE  +  k_7on * EPI  -  k_7off * PIE;

% EPI
 dy(9)  =  +  k_6on * EP * I  -  k_6off * EPI  -  k_7on * EPI  +  k_7off * PIE  +  k_8on * E * PI  -  k_8off * EPI;

end
