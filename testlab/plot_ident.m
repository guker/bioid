function plot_ident(ratios)
%%
figure(1);
hold on;
plot(ratios,'LineWidth',4)
legend('Porcentaje de Aciertos','Location','Best');
ylabel('% Aciertos');
xlabel('N� de Candidatos');
axis([1 numel(ratios) 1 105]);
title(' Porcentaje de Aciertos Vs N� Candidatos (CMC)');
grid on

end