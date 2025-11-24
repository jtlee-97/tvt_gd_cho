% Parameters (You can set these)
UE_num = 251;  % Set the number of UEs
SIMTIME = 173.21 / 7.56;  % Set the simulation time

% Strategies for the first figure
strategies_figure_1 = {
    'BHO A3 (0, 0)',
    'CHO A3 (0, 0)',
    'DCHO',
    'Proposed DCHO'
};

% Strategies for the second figure
strategies_figure_2 = {
    'BHO A3 (0, 0)',
    'BHO A3 (1, 0.1)',
    'BHO A3 (2, 0.256)',
    'CHO A3 (0, 0)',
    'CHO A3 (1, 0.1)',
    'CHO A3 (2, 0.256)'
};

% Function to load data
function data = load_data(strategy)
    data = load(fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategy, '.mat']), ...
        'MASTER_RAW_SINR', 'MASTER_UHO', 'MASTER_HO', 'MASTER_RLF');
end

% Function to compute RLF
function rlf_value = compute_rlf(rlf_data, UE_num, SIMTIME)
    rlf_value = sum(rlf_data(:)) / (UE_num * SIMTIME);
end

% Plot function for a figure
function plot_figure(strategies, fig_num, UE_num, SIMTIME)
    % Load data
    data = cellfun(@load_data, strategies, 'UniformOutput', false);
    
    % Prepare figure
    figure(fig_num);

    % Subplot 1: CDF plots for SINR (tt_SINR)
    subplot(2, 2, 1);
    hold on;
    for i = 1:length(strategies)
        [cdf_sinr, x_sinr] = ecdf(data{i}.MASTER_RAW_SINR(:));
        plot(x_sinr, cdf_sinr, 'LineWidth', 1.5, 'DisplayName', strategies{i});
    end
    hold off;
    grid on;
    xlabel('DL SINR [dB]');
    ylabel('CDF');
    legend('Location', 'southeast');
    title('CDF of DL SINR (tt\_SINR)');
    xlim([-6 3]);  
    ylim([0 1]);
    yticks(0:0.1:1);

    % Subplot 2: CDF plots for UHO/HO Ratio
    subplot(2, 2, 2);
    hold on;
    for i = 1:length(strategies)
        uho_ho_ratio = mean(data{i}.MASTER_UHO, 1) ./ (mean(data{i}.MASTER_HO, 1) + eps);
        [cdf_ratio, x_ratio] = ecdf(uho_ho_ratio);
        plot(x_ratio, cdf_ratio, 'LineWidth', 1.5, 'DisplayName', strategies{i});
    end
    hold off;
    grid on;
    xlabel('UHO/HO Ratio');
    ylabel('CDF');
    legend('Location', 'southeast');
    title('CDF of UHO/HO Ratio');
    yticks(0:0.1:1);

    % Subplot 3: Average UHO per UE
    subplot(2, 2, 3);
    hold on;
    for i = 1:length(strategies)
        x_values = linspace(100, 25000, length(data{i}.MASTER_UHO));
        plot(x_values, mean(data{i}.MASTER_UHO, 1), 'LineWidth', 1.5, 'DisplayName', strategies{i});
    end
    xlabel('Distance [m]');
    ylabel('Average UHO');
    title('Average UHO per UE');
    legend('show');
    grid on;
    xlim([0 25000]);
    hold off;

    % Subplot 4: RLF bar plot
    subplot(2, 2, 4);
    rlf_values = cellfun(@(d) compute_rlf(d.MASTER_RLF, UE_num, SIMTIME), data);
    bar(1:length(strategies), rlf_values, 0.4, 'FaceColor', [0, 0.4470, 0.7410]);
    set(gca, 'XTick', 1:length(strategies), 'XTickLabel', strategies);
    xlabel('Strategy');
    ylabel('RLF');
    title('RLF Across Strategies');
    grid on;

    % Adjust overall figure size
    set(gcf, 'Position', [100, 100, 1000, 800]);
end

% Plot the figures
plot_figure(strategies_figure_1, 1, UE_num, SIMTIME);
plot_figure(strategies_figure_2, 2, UE_num, SIMTIME);
