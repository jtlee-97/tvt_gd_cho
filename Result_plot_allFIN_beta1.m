% Initialize strategies and colors
strategies = {'BHO A3', 'CHO A3', 'DCHO', 'Proposed DCHO'};
colors = {'k', 'k', 'b', 'r'};
lineStyles = {':', '-', '-', '-'};

% Initialize variables to hold data for each strategy
raw_sinr_data = cell(1, length(strategies));
uho_data = cell(1, length(strategies));
ho_data = cell(1, length(strategies));
uho_ho_ratio = cell(1, length(strategies));  % UHO/HO 비율 추가

% Load data for each strategy
for i = 1:length(strategies)
    data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
    load(data_path, 'MASTER_RAW_SINR', 'MASTER_UHO', 'MASTER_HO');
    
    % Reshape the data to be a single vector
    raw_sinr_data{i} = MASTER_RAW_SINR(:);
    uho_data{i} = mean(MASTER_UHO, 1);  % Mean across episodes for each UE
    ho_data{i} = mean(MASTER_HO, 1);  % Mean across episodes for each UE
    
    % Calculate UHO/HO ratio
    uho_ho_ratio{i} = uho_data{i} ./ (ho_data{i} + eps);  % Avoid division by zero
end

% Plotting combined subplots in one figure
figure;

% Subplot 1: CDF plots for SINR (tt_SINR)
subplot(3, 2, 1);
hold on;
sinr_percentiles = zeros(length(strategies), 3);  % Store 5%, 50%, 95% values
for i = 1:length(strategies)
    [cdf_sinr, x_sinr] = ecdf(raw_sinr_data{i});
    plot(x_sinr, cdf_sinr, 'Color', colors{i}, 'LineStyle', lineStyles{i}, 'LineWidth', 1, 'DisplayName', strategies{i});
    
    % Calculate 5%, 50%, 95% values
    sinr_percentiles(i, 1) = interp1(cdf_sinr, x_sinr, 0.05);
    sinr_percentiles(i, 2) = interp1(cdf_sinr, x_sinr, 0.50);
    sinr_percentiles(i, 3) = interp1(cdf_sinr, x_sinr, 0.95);
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

% Subplot 2: CDF plots for UHO
subplot(3, 2, 2);
hold on;
for i = 1:length(strategies)
    [cdf_uho, x_uho] = ecdf(uho_data{i});
    plot(x_uho, cdf_uho, 'Color', colors{i}, 'LineStyle', lineStyles{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('UHO');
ylabel('CDF');
legend('Location', 'southeast');
title('CDF of UHO');
yticks(0:0.1:1);

% Subplot 3: CDF plots for UHO/HO ratio
subplot(3, 2, 3);
hold on;
uho_ho_percentiles = zeros(length(strategies), 3);  % Store 70%, 80%, 90% values
for i = 1:length(strategies)
    [cdf_ratio, x_ratio] = ecdf(uho_ho_ratio{i});
    plot(x_ratio, cdf_ratio, 'Color', colors{i}, 'LineStyle', lineStyles{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
    
    % Calculate 70%, 80%, 90% values
    uho_ho_percentiles(i, 1) = interp1(cdf_ratio, x_ratio, 0.70);
    uho_ho_percentiles(i, 2) = interp1(cdf_ratio, x_ratio, 0.80);
    uho_ho_percentiles(i, 3) = interp1(cdf_ratio, x_ratio, 0.90);
end
hold off;
grid on;
xlabel('UHO/HO Ratio');
ylabel('CDF');
legend('Location', 'southeast');
title('CDF of UHO/HO Ratio');
yticks(0:0.1:1);

% Subplot 4: Bar plot for 70%, 80%, 90% values of UHO/HO Ratio
subplot(3, 2, 4);
bar(uho_ho_percentiles, 'grouped');
set(gca, 'XTickLabel', strategies);
xlabel('Strategy');
ylabel('UHO/HO Ratio Value');
legend({'@70%', '@80%', '@90%'}, 'Location', 'northeast');
title('Percentile Values of UHO/HO Ratio');
grid on;

% Subplot 5: Average UHO per UE
subplot(3, 2, 5);
hold on;
for i = 1:length(strategies)
    x_values = linspace(100, 25000, length(uho_data{i}));
    plot(x_values, uho_data{i}, 'Color', colors{i}, 'LineStyle', lineStyles{i}, 'LineWidth', 0.7, 'DisplayName', strategies{i});
end
xlabel('Distance [m]');
ylabel('Average UHO');
title('Average UHO per UE');
legend('show');
grid on;
xlim([0 25000]);
hold off;

% Normalize the SINR percentiles to start from zero
min_sinr = min(sinr_percentiles(:));
normalized_sinr_percentiles = sinr_percentiles - min_sinr + 1;  % Shift to make the lowest value positive

% Subplot 6: Bar plot for normalized SINR percentiles
subplot(3, 2, 6);
bar(normalized_sinr_percentiles, 'grouped');
set(gca, 'XTickLabel', strategies);
xlabel('Strategy');
ylabel('Normalized SINR');
legend({'@5%', '@50%', '@95%'}, 'Location', 'northeast');
title('Normalized Percentile Values of SINR');
grid on;

% Adjust layout
set(gcf, 'Position', [100, 100, 1200, 900]);  % Adjust the figure size for better visibility
