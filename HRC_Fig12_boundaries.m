clear
addpath(genpath(pwd))

load HRC_scenario4

mask_year = data_scenario_4{3}.Year >= 1960;

figure(2), clf
yyaxis left
plot(data_scenario_4{3}.Year(mask_year), data_scenario_4{3}.Sedimentation(mask_year), 'b-');
xlabel('Year');
ylabel('Sedimentation rate (mm/yr)');
grid on;
yline(0, 'k-', 'LineWidth', 0.5);

yyaxis right
plot(data_scenario_4{3}.Year, data_scenario_4{3}.Uplift, 'r-');
xlabel('Year');
ylabel('Uplift rate (mm/yr)');
grid on;
yline(0, 'k-', 'LineWidth', 0.5);

% export
rect = [2,4,15,10]; set(gcf,'PaperUnits','centimeters','PaperType','A4','paperposition',rect);
fout = 'figs/HRC_Fig12_boundaries.png'; saveas(gcf,fout,'png');
%opts.Resolution = 150;
%opts.BackgroundColor = 'none';
%opts.ContentType='vector';
%exportPlotToPDF_Advanced(gcf, fout, rect, opts);

