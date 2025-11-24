% Initialize strategies and colors
strategies_all = { 'Strategy A', 'Strategy B', 'Strategy C', 'Strategy D', 'Strategy E', 'Strategy F', 'Strategy G', 'Strategy H', 'Strategy I', 'Strategy J', 'Strategy K'};
strategies_subset = {'Strategy A', 'Strategy D', 'Strategy G', 'Strategy H', 'Strategy I', 'Strategy J', 'Strategy K'};

% Define strategy sets
strategy_sets_all = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'};
strategy_sets_subset = {'A', 'D', 'G', 'H', 'I', 'J', 'K'};

colors_all = { ...
    'k', [0.5, 0.5, 0.5], [0.8, 0.8, 0.8], ...  % BHO colors
    [0.5, 0.25, 0], [0.6, 0.3, 0], [0.8, 0.4, 0], ...  % CHO colors
    [0 0.447 0.741], [0.494 0.184 0.556], [0.494 0.2 0.556], [0.635 0.078 0.184], [0.466 0.674 0.188]  % DCHO and Proposed DCHO colors
};
colors_subset = {'k', [0.5, 0.25, 0], [0 0.447 0.741], [0.494 0.184 0.556], [0.494 0.2 0.556], [0.635 0.078 0.184], [0.466 0.674 0.188]};
lineStyles_all = { ...
    ':', ':', ':', ...  % BHO line styles
    '-.', '-.', '-.', ...  % CHO line styles
    '-', '-', '-.', '-', '-'  % DCHO and Proposed DCHO line styles
};
lineStyles_subset = {':', ':', '-', '-', '-.', '-', '-'};

run("system_parameter.m");

% Initialize variables to hold data for each strategy
raw_sinr_data_all = cell(1, length(strategies_all));
raw_sinr_data_subset = cell(1, length(strategies_subset));
uho_data_subset = cell(1, length(strategies_subset));
ho_data_subset = cell(1, length(strategies_subset));
uho_ho_ratio_subset = cell(1, length(strategies_subset));  % UHO/HO 비율 추가
rlf_data_all = cell(1, length(strategies_all));  % RLF 데이터 추가
rlf_data_subset = cell(1, length(strategies_subset));  % Subset RLF 데이터 추가
tos_data_subset = cell(1, length(strategies_subset));  % ToS 데이터 추가

% Load data for each strategy (all)
for i = 1:length(strategies_all)
    data_path = fullfile('MasterResults', ['case 1','_MASTER_RESULTS_', strategies_all{i}, '_', fading, '.mat']);
    load(data_path, 'MASTER_RAW_SINR', 'MASTER_RLF');
    raw_sinr_data_all{i} = MASTER_RAW_SINR(:);
    rlf_data_all{i} = sum(MASTER_RLF, 1);  % Sum across all UEs and episodes
end

% Load data for each strategy (subset)
for i = 1:length(strategies_subset)
    data_path = fullfile('MasterResults', ['case 1','_MASTER_RESULTS_', strategies_subset{i}, '_', fading, '.mat']);
    
    % Load the data and check if 'MASTER_ToS' exists
    data = load(data_path);
    
    if isfield(data, 'MASTER_ToS')
        tos_data_subset{i} = data.MASTER_ToS(:);  % Treat MASTER_ToS as 1D array
    else
        fprintf('Warning: MASTER_ToS variable is missing from the loaded data for strategy %s.\n', strategies_subset{i});
        tos_data_subset{i} = [];  % Empty array if MASTER_ToS is missing
    end

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
legend('Location', 'northwest');
xlim([-8 3]);  
ylim([0 1]);
yticks(0:0.1:1);

% Subplot 2: Average SINR per Strategy (Subset Strategies)
subplot(3, 2, 2);
bar_width = 0.4;
x = 1:length(strategies_all);
average_sinr_all = zeros(1, length(strategies_all));

% Calculate the average SINR for each strategy
for i = 1:length(strategies_all)
    data_path = fullfile('MasterResults', ['case 1','_MASTER_RESULTS_', strategies_all{i}, '_', fading, '.mat']);
    load(data_path, 'MASTER_SINR');  % MASTER_SINR 로드
    average_sinr_all(i) = mean(MASTER_SINR(:));  % 모든 UE와 에피소드에서 평균 SINR 계산
end

bar(x, average_sinr_all, bar_width, 'FaceColor', [0.8500, 0.3250, 0.0980]); % Orange bars for Average SINR
ylabel('Average SINR [dB]');
set(gca, 'XTick', x, 'XTickLabel', strategy_sets_all);
xlabel('Strategy');
grid on;

% Subplot 3: Average UHO per Strategy (Subset Strategies)
subplot(3, 2, 3);
average_uho_all = cellfun(@(uho) mean(uho), uho_data_subset);
bar_width = 0.4;
x = 1:length(strategies_subset);
bar(x, average_uho_all, bar_width, 'FaceColor', [0.8500, 0.3250, 0.0980]);
ylabel('Average UHO');
set(gca, 'XTick', x, 'XTickLabel', strategy_sets_subset);
xlabel('Strategy');
grid on;

% Subplot 4: Average UHO per UE (Subset Strategies)
subplot(3, 2, 4);
hold on;
for i = 1:length(strategies_subset)
    x_values = 0:100:25000;
    plot(x_values, uho_data_subset{i}, 'Color', colors_subset{i}, 'LineStyle', lineStyles_subset{i}, 'LineWidth', 0.7, 'DisplayName', strategies_subset{i});
end
xlabel('Distance [m]');
ylabel('Average UHO');
legend('Location', 'northwest');
grid on;
xlim([0 25000]);
hold off;

% Subplot 5: RLF Operations per UE per Sec (All Strategies)
subplot(3, 2, 5);
average_rlf_all = cellfun(@(rlf) mean(rlf) / (EPISODE), rlf_data_all);
b = bar(average_rlf_all, 'FaceColor', [0, 0.4470, 0.7410]); % Blue bars
set(gca, 'XTick', 1:length(strategy_sets_all), 'XTickLabel', strategy_sets_all);
xlabel('Strategy');
ylabel('RLF Operations');
grid on;
xtips = b.XEndPoints;
ytips = b.YEndPoints;
labels = string(round(b.YData, 3));
text(xtips, ytips, labels, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

% Subplot 6: CDF plots for ToS (Subset Strategies)
subplot(3, 2, 6);
hold on;

% Define the x-range to highlight (5.291 to 6.161 seconds)
x_range_low = 5.291;
x_range_high = 6.161;

% Highlight the x-range between 5.291 and 6.161 seconds
y_limits = ylim;  % Get current y-axis limits
h_fill = fill([x_range_low, x_range_high, x_range_high, x_range_low], [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], [0.5, 0.5, 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');  % Use RGB triplet for gray
set(get(get(h_fill,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');  % Ensure it appears in the legend
h_fill.DisplayName = 'opt ToS';  % Change the name in the legend

% Plot each strategy's ToS data
for i = 1:length(strategies_subset)
    if ~isempty(tos_data_subset{i})  % Only plot if ToS data exists
        [cdf_tos, x_tos] = ecdf(tos_data_subset{i});
        plot(x_tos, cdf_tos, 'Color', colors_subset{i}, 'LineStyle', lineStyles_subset{i}, 'LineWidth', 1.5, 'DisplayName', strategies_subset{i});
    else
        fprintf('No ToS data for strategy %s.\n', strategies_subset{i});
    end
end

% Bring the plot lines to the front
set(gca, 'Children', flipud(get(gca, 'Children')));

hold off;

% Make sure grid is visible
grid on;

% Add labels and legend
xlabel('ToS [s]');
ylabel('CDF');
legend('Location', 'northwest');

% Set x and y ticks and limit the range
yticks(0:0.1:1);
xlim([0 7]);
ylim([0 1]);

% Set grid to be behind the plot
set(gca, 'Layer', 'bottom');

% Adjust overall figure size
set(gcf, 'Position', [100, 100, 1000, 800]);  % Adjust the figure size for a square plot
