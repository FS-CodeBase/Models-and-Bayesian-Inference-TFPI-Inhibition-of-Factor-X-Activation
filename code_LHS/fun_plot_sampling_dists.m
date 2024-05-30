function fun_plot_sampling_dists(PrmsMat,med_prms,prms_est)
param_names = {...
'$k_{1}=$ %s (nMs)$^{-1}$',... %[01]
'$k_{-1}=$ %s (s$^{-1}$)',...  %[02]
'$k_2=$ %s (s$^{-1})$',...     %[03]
'$k_{3}=$ %s (nMs)$^{-1}$',... %[04]
'$k_{-3}=$ %s (s)$^{-1}$',...  %[05]
'$k_{4}=$ %s (nMs)$^{-1}$',... %[06]
'$k_{-4}=$ %s (s)$^{-1}$',...  %[07]
'$k_{5}=$ %s (nMs)$^{-1}$',... %[08]
'$k_{-5}=$ %s (s)$^{-1}$',...  %[09]
'$k_{6}=$ %s (nMs)$^{-1}$',... %[10]
'$k_{-6}=$ %s (s$^{-1})$',...  %[11]
'$k_{7}=$ %s (s$^{-1}$)',...   %[12]
'$k_{-7}=$ %s (s$^{-1})$',...  %[13]
'$k_{8}=$ %s (nMs)$^{-1}$',... %[14]
'$k_{-8}=$ %s (s$^{-1}$)',...  %[15]
'$\\sigma=$ %s'};               %[16]
T = tiledlayout(4,4); 
for i = 1:16
    nexttile
    histogram(PrmsMat(:,i));
    prm_str = sprintf(param_names{i},fun_custom_xtickformat(med_prms(i)));
    if prms_est(i)
        title(sprintf('EST: %s',prm_str),'Interpreter','latex','FontSize',15)
    else
        title(sprintf('FIX: %s',prm_str),'Interpreter','latex','FontSize',15)
    end
    hold on
    plot(med_prms(i),0,'-o','MarkerSize',10,'MarkerFaceColor','k');
    hold off
    set(gca,'TickLabelInterpreter','latex','FontSize',16)
end
set(gcf, 'Units', 'Inches', 'Position', [0, 1.2, 20, 14]);shg
shg
% x = 4;