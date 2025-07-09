clear
addpath(genpath(pwd))

load HRC_scenarios.mat

figure(1); clf

% Plot all scenarios
subplot(4, 2, 1);
plot_scenario_with_subsidencia_decay_and_shading(data_scenario_1, 'Constant Uplift, Constant Sedimentation', ...
    decaying_uncertainty, ssp_scenarios, 'a', true);

subplot(4, 2, 2);
plot_scenario_with_subsidencia_decay_and_shading(data_scenario_2, 'Constant Uplift, Sedimentation Function', ...
    decaying_uncertainty, ssp_scenarios, 'b', false);

subplot(4, 2, 3);
plot_scenario_with_subsidencia_decay_and_shading(data_scenario_3, 'Postseismic Uplift Function, Constant Sedimentation', decaying_uncertainty, ssp_scenarios, 'c', false);

subplot(4, 2, 4);
plot_scenario_with_subsidencia_decay_and_shading(data_scenario_4, 'Postseismic Uplift Function, Sedimentation Function', decaying_uncertainty, ssp_scenarios, 'd', false);

subplot(4, 2, 5);
plot_scenario_with_subsidencia_decay_and_shading(data_scenario_5, 'Constant Uplift, No Sedimentation', decaying_uncertainty, ssp_scenarios, 'e', false);

subplot(4, 2, 6);
plot_scenario_with_subsidencia_decay_and_shading(data_scenario_6, 'Postseismic Uplift Function, No Sedimentation', decaying_uncertainty, ssp_scenarios, 'f', false);

subplot(4, 2, 7);
plot_scenario_with_subsidencia_decay_and_shading(data_scenario_7, 'No Uplift, Constant Sedimentation', decaying_uncertainty, ssp_scenarios, 'g', false);

subplot(4, 2, 8);
plot_scenario_with_subsidencia_decay_and_shading(data_scenario_8, 'No Uplift, Sedimentation Function', decaying_uncertainty, ssp_scenarios, 'h', false);

rect = [2,4,40,30]; set(gcf,'PaperUnits','centimeters','PaperType','A4','paperposition',rect);
fout = 'figs/HRC_Fig13_scenarios.png'; saveas(gcf,fout,'png');

function plot_scenario_with_subsidencia_decay_and_shading(data_list, title_text, decaying_uncertainty, ssp_scenarios, label_letter, show_legend)    
    colors = {'r', 'g', 'b'};
    
    % Zona de recurrencia sísmica
    x_fill = [2200 2300 2300 2200];
    y_fill = [-5000 -5000 5000 5000];  % Large values to ensure coverage
    fill(x_fill, y_fill, [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    hold on;
    
    for i = 1:length(data_list)
        data = data_list{i};
        color = colors{i};
        ssp = ssp_scenarios{i};
        
        % Get sea level and uncertainty values
        sea_level_curve = data.Sea_Level;
        years_to_plot = data.Year >= 1960;
        years_array = data.Year(years_to_plot);
        sl_curve = sea_level_curve(years_to_plot);
        
        % Calculate uncertainty based on decaying model
        sl_uncertainty_curve = decaying_uncertainty(1:sum(years_to_plot));
        
        % Plot uncertainty band (gray)
        fill([years_array; flip(years_array)], ...
             [sl_curve - sl_uncertainty_curve'; flip(sl_curve + sl_uncertainty_curve')], ...
             [0.8 0.8 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
        
        % Plot sea level curve
        psl(i)=plot(data.Year, data.Sea_Level, color, 'LineWidth', 0.5, 'DisplayName', strrep(ssp, '_mean', ''));
        
        % Plot total uncertainty band
        fill([data.Year; flip(data.Year)], ...
             [data.Sea_Level - data.Total_Uncertainty; flip(data.Sea_Level + data.Total_Uncertainty)], ...
             color, 'EdgeColor', 'none', 'FaceAlpha', 0.2);
    end
    
    % Plot horizontal line at y=0
    yline(0, 'k-', 'LineWidth', 0.5);
    
    % Set title and labels
    title(title_text);
    xlabel('Year');
    ylabel('Relative Sea Level (mm)');
    
    % Add panel letter
    text(-0.1, 1.2, label_letter, 'Units', 'normalized', 'FontSize', 12, ...
         'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    
    % Add legend if needed
    if show_legend
        legd=legend(psl,'Location', 'southwest', 'FontSize', 9);
    end
    
    hold off;
    ylim([-4000,3000])

end
