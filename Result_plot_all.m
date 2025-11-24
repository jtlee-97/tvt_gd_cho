% Initialize strategies and colors
strategies = {'BHO A3', 'CHO A3', 'DCHO', 'Proposed DCHO'};
colors = {'k:', 'k-.', 'b-', 'r--'};

% Initialize variables to hold data for each strategy
raw_sinr_data = cell(1, length(strategies));
sinr_data = cell(1, length(strategies));
uho_data = cell(1, length(strategies));
ho_data = cell(1, length(strategies));
uho_ho_ratio = cell(1, length(strategies));  % UHO/HO 비율 추가

% Load data for each strategy
for i = 1:length(strategies)
    data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
    load(data_path, 'MASTER_RAW_SINR', 'MASTER_SINR', 'MASTER_UHO', 'MASTER_HO');
    
    % Reshape the data to be a single vector
    raw_sinr_data{i} = MASTER_RAW_SINR(:);
    sinr_data{i} = MASTER_SINR(:);
    uho_data{i} = MASTER_UHO(:);
    ho_data{i} = MASTER_HO(:);
    
    % Calculate UHO/HO ratio
    uho_ho_ratio{i} = uho_data{i} ./ ho_data{i};  % 비율 계산
end

% Plotting combined subplots in one figure
figure;

% Subplot 1: CDF plots for SINR (tt_SINR)
subplot(4, 2, 1);
hold on;
for i = 1:length(strategies)
    [cdf_sinr, x_sinr] = ecdf(raw_sinr_data{i});
    plot(x_sinr, cdf_sinr, colors{i}, 'LineWidth', 1, 'DisplayName', strategies{i});
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

% Subplot 2: CDF plots for MASTER SINR
subplot(4, 2, 2);
hold on;
for i = 1:length(strategies)
    [cdf_sinr, x_sinr] = ecdf(sinr_data{i});
    plot(x_sinr, cdf_sinr, colors{i}, 'LineWidth', 1, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('DL SINR [dB] (MASTER\_SINR)');
ylabel('CDF');
legend('Location', 'southeast');
title('CDF of DL SINR (MASTER\_SINR)');
xlim([-3 1.5]);
yticks(0:0.1:1);

% Subplot 3: CDF plots for UHO
subplot(4, 2, 3);
hold on;
for i = 1:length(strategies)
    [cdf_uho, x_uho] = ecdf(uho_data{i});
    plot(x_uho, cdf_uho, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('UHO');
ylabel('CDF');
legend('Location', 'southeast');
title('CDF of UHO');
yticks(0:0.1:1);

% Subplot 4: CDF plots for HO
subplot(4, 2, 4);
hold on;
for i = 1:length(strategies)
    [cdf_ho, x_ho] = ecdf(ho_data{i});
    plot(x_ho, cdf_ho, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('HO');
ylabel('CDF');
legend('Location', 'southeast');
title('CDF of HO');
yticks(0:0.1:1);

% Subplot 5: CDF plots for UHO/HO ratio
subplot(4, 2, 5);
hold on;
percentiles = zeros(length(strategies), 3);  % Store 5%, 50%, 95% values
for i = 1:length(strategies)
    [cdf_ratio, x_ratio] = ecdf(uho_ho_ratio{i});
    plot(x_ratio, cdf_ratio, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
    
    % Calculate 5%, 50%, 95% values
    percentiles(i, 1) = interp1(cdf_ratio, x_ratio, 0.70);  % 5%
    percentiles(i, 2) = interp1(cdf_ratio, x_ratio, 0.80);  % 50%
    percentiles(i, 3) = interp1(cdf_ratio, x_ratio, 0.90);  % 95%
end
hold off;
grid on;
xlabel('UHO/HO Ratio');
ylabel('CDF');
legend('Location', 'southeast');
title('CDF of UHO/HO Ratio');
yticks(0:0.1:1);

% Subplot 6: Bar plot for 5%, 50%, 95% values of UHO/HO Ratio
subplot(4, 2, 6);
bar(percentiles, 'grouped');
set(gca, 'XTickLabel', strategies);
xlabel('Strategy');
ylabel('UHO/HO Ratio Value');
legend({'@70%', '@80%', '@90%'}, 'Location', 'northeast');
title('Percentile Values of UHO/HO Ratio');
grid on;

% Adjust layout
set(gcf, 'Position', [100, 100, 1200, 800]);  % Adjust the figure size for better visibility
