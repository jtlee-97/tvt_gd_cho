% Initialize strategies and colors
strategies = {'BHO_A3', 'CHO_A3', 'Distance', 'Distance_DD2'};
colors = {'r-', 'b-', 'k-', 'b--'};

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
subplot(3, 2, 1);
hold on;
for i = 1:length(strategies)
    [cdf_sinr, x_sinr] = ecdf(raw_sinr_data{i});
    plot(x_sinr, cdf_sinr, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('DL SINR [dB]');
ylabel('CDF');
legend('Location', 'best');
title('CDF of DL SINR (tt\_SINR)');
xlim([-6 3]);  
ylim([0 1]);
yticks(0:0.1:1);

% Subplot 2: CDF plots for MASTER SINR
subplot(3, 2, 2);
hold on;
for i = 1:length(strategies)
    [cdf_sinr, x_sinr] = ecdf(sinr_data{i});
    plot(x_sinr, cdf_sinr, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('DL SINR [dB] (MASTER\_SINR)');
ylabel('CDF');
legend('Location', 'best');
title('CDF of DL SINR (MASTER\_SINR)');
xlim([-3 1.5]);
yticks(0:0.1:1);

% Subplot 3: CDF plots for UHO
subplot(3, 2, 3);
hold on;
for i = 1:length(strategies)
    [cdf_uho, x_uho] = ecdf(uho_data{i});
    plot(x_uho, cdf_uho, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('UHO');
ylabel('CDF');
legend('Location', 'best');
title('CDF of UHO');
yticks(0:0.1:1);

% Subplot 4: CDF plots for HO
subplot(3, 2, 4);
hold on;
for i = 1:length(strategies)
    [cdf_ho, x_ho] = ecdf(ho_data{i});
    plot(x_ho, cdf_ho, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('HO');
ylabel('CDF');
legend('Location', 'best');
title('CDF of HO');
yticks(0:0.1:1);

% Subplot 5: CDF plots for UHO/HO ratio (추가)
subplot(3, 2, [5 6]);  % 3행 2열에서 마지막 두 개의 subplot을 합쳐 사용
hold on;
for i = 1:length(strategies)
    [cdf_ratio, x_ratio] = ecdf(uho_ho_ratio{i});
    plot(x_ratio, cdf_ratio, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('UHO/HO Ratio');
ylabel('CDF');
legend('Location', 'best');
title('CDF of UHO/HO Ratio');
yticks(0:0.1:1);

% Adjust layout
set(gcf, 'Position', [100, 100, 1200, 1000]);  % Adjust the figure size for better visibility
