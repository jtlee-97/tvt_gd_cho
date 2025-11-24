% Initialize strategies and colors
strategies_all = { 'Strategy A', 'Strategy B', 'Strategy C', 'Strategy D', 'Strategy E', 'Strategy F', 'Strategy G', 'Strategy H'};
strategies_subset = {'Strategy A', 'Strategy D', 'Strategy G', 'Strategy H'};

% Define strategy sets
strategy_sets_all = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
strategy_sets_subset = {'A', 'D', 'G', 'H'};

colors_all = { ...
    'k', [0.5, 0.5, 0.5], [0.8, 0.8, 0.8], ...  % BHO colors
    [0.5, 0.25, 0], [0.6, 0.3, 0], [0.8, 0.4, 0], ...  % CHO colors
    'b', 'r'  % DCHO and Proposed DCHO colors
};
colors_subset = {'k', [0.5, 0.25, 0], 'b', 'r'};
lineStyles_all = { ...
    ':', ':', ':', ...  % BHO line styles
    '-.', '-.', '-.', ...  % CHO line styles
    '-', '-'  % DCHO and Proposed DCHO line styles
};
lineStyles_subset = {':', '-.', '-', '-'};

% Initialize variables to hold data for each strategy
raw_sinr_data_all = cell(1, length(strategies_all));
raw_sinr_data_subset = cell(1, length(strategies_subset));
uho_data_subset = cell(1, length(strategies_subset));
ho_data_subset = cell(1, length(strategies_subset));
uho_ho_ratio_subset = cell(1, length(strategies_subset));  % UHO/HO 비율 추가
rlf_data_all = cell(1, length(strategies_all));  % RLF 데이터 추가
rlf_data_subset = cell(1, length(strategies_subset));  % Subset RLF 데이터 추가

% Load data for each strategy (all)
for i = 1:length(strategies_all)
    data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies_all{i}, '.mat']);
    load(data_path, 'MASTER_RAW_SINR', 'MASTER_RLF');
    raw_sinr_data_all{i} = MASTER_RAW_SINR(:);
    rlf_data_all{i} = sum(MASTER_RLF, 1);  % Sum across all UEs and episodes
end

% Load data for each strategy (subset)
for i = 1:length(strategies_subset)
    data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies_subset{i}, '.mat']);
    load(data_path, 'MASTER_RAW_SINR', 'MASTER_UHO', 'MASTER_HO', 'MASTER_RLF');
    
    raw_sinr_data_subset{i} = MASTER_RAW_SINR(:);
    uho_data_subset{i} = mean(MASTER_UHO, 1);  % Mean across episodes for each UE
    ho_data_subset{i} = mean(MASTER_HO, 1);  % Mean across episodes for each UE
    rlf_data_subset{i} = sum(MASTER_RLF, 1);  % Sum across all UEs and episodes
    
    % Calculate UHO/HO ratio
    uho_ho_ratio_subset{i} = uho_data_subset{i} ./ (ho_data_subset{i} + eps);  % Avoid division by zero
end

% Plotting combined subplots in one figure
figure;

% Subplot 1: CDF plots for SINR (tt_SINR) (All Strategies)
subplot(3, 2, 1);
hold on;
for i = 1:length(strategies_all)
    [cdf_sinr, x_sinr] = ecdf(raw_sinr_data_all{i});
    plot(x_sinr, cdf_sinr, 'Color', colors_all{i}, 'LineStyle', lineStyles_all{i}, 'LineWidth', 1, 'DisplayName', strategies_all{i});
end
hold off;
grid on;
xlabel('DL SINR [dB]');
ylabel('CDF');
legend('Location', 'southeast');
%title('CDF of DL SINR (tt\_SINR)');
xlim([-6 3]);  
ylim([0 1]);
yticks(0:0.1:1);

% Subplot 2: CDF plots for UHO (Subset Strategies)
subplot(3, 2, 2);
hold on;
for i = 1:length(strategies_subset)
    [cdf_uho, x_uho] = ecdf(uho_data_subset{i});
    plot(x_uho, cdf_uho, 'Color', colors_subset{i}, 'LineStyle', lineStyles_subset{i}, 'LineWidth', 1.5, 'DisplayName', strategies_subset{i});
end
hold off;
grid on;
xlabel('UHO');
ylabel('CDF');
legend('Location', 'southeast');
%title('CDF of UHO');
yticks(0:0.1:1);

% Subplot 3: CDF plots for UHO/HO ratio (Subset Strategies)
subplot(3, 2, 3);
hold on;
uho_ho_percentiles_subset = zeros(length(strategies_subset), 3);  % Store 70%, 80%, 90% values
for i = 1:length(strategies_subset)
    [cdf_ratio, x_ratio] = ecdf(uho_ho_ratio_subset{i});
    plot(x_ratio, cdf_ratio, 'Color', colors_subset{i}, 'LineStyle', lineStyles_subset{i}, 'LineWidth', 1.5, 'DisplayName', strategies_subset{i});
    
    % Calculate 70%, 80%, 90% values
    uho_ho_percentiles_subset(i, 1) = interp1(cdf_ratio, x_ratio, 0.70);
    uho_ho_percentiles_subset(i, 2) = interp1(cdf_ratio, x_ratio, 0.80);
    uho_ho_percentiles_subset(i, 3) = interp1(cdf_ratio, x_ratio, 0.90);
end
hold off;
grid on;
xlabel('UHO/HO Ratio');
ylabel('CDF');
legend('Location', 'southeast');
%title('CDF of UHO/HO Ratio');
yticks(0:0.1:1);

% Subplot 4: RLF Operations per UE per Sec (All Strategies)
subplot(3, 2, 4);
%average_rlf_all = cellfun(@(rlf) mean(rlf) / (UE_num * TOTAL_TIME * EPISODE), rlf_data_all);
average_rlf_all = cellfun(@(rlf) mean(rlf) / (EPISODE), rlf_data_all);
b = bar(average_rlf_all, 'FaceColor', [0, 0.4470, 0.7410]); % Blue bars
set(gca, 'XTick', 1:length(strategy_sets_all), 'XTickLabel', strategy_sets_all);
xlabel('Strategy');
ylabel('RLF Operations');
%title('RLF Operations Across Strategies');
grid on;

% Add values on top of each bar
xtips = b.XEndPoints;
ytips = b.YEndPoints;
labels = string(round(b.YData, 3)); % Round to 3 decimal places
text(xtips, ytips, labels, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

% Subplot 5: Average UHO per UE (Subset Strategies)
subplot(3, 2, 5);
hold on;
for i = 1:length(strategies_subset)
    x_values = linspace(100, 25000, length(uho_data_subset{i}));
    plot(x_values, uho_data_subset{i}, 'Color', colors_subset{i}, 'LineStyle', lineStyles_subset{i}, 'LineWidth', 0.7, 'DisplayName', strategies_subset{i});
end
xlabel('Distance [m]');
ylabel('Average UHO');
%title('Average UHO per UE');
legend('Location', 'northwest');
grid on;
xlim([0 25000]);
hold off;

% Subplot 6: Bar plot for Average UHO/HO Ratio (Subset Strategies)
subplot(3, 2, 6);

% Prepare data for plotting
average_uho_ho_ratio = cellfun(@(uho, ho) mean(uho ./ (ho + eps)), uho_data_subset, ho_data_subset);

% Create positions for grouped bars
bar_width = 0.4;
x = 1:length(strategies_subset);

% Create a bar plot for Average UHO/HO Ratio on the right y-axis
bar(x, average_uho_ho_ratio, bar_width, 'FaceColor', [0.8500, 0.3250, 0.0980]); % Orange bars
ylabel('Average UHO/HO Ratio');

% Set x-axis labels and title
set(gca, 'XTick', x, 'XTickLabel', strategy_sets_subset);
xlabel('Strategy');
%title('Average UHO/HO Ratio Across Strategies');
grid on;

% Adjust overall figure size
set(gcf, 'Position', [100, 100, 1000, 800]);  % Adjust the figure size for a square plot
