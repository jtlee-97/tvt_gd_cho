% Plotting CDF of SINR (tt_SINR), SINR (MASTER_SINR), UHO, and HO for different HO strategies as separate plots

strategies = {'BHO_A3', 'CHO_A3', 'Distance', 'Distance_DD2'};
colors = {'r-', 'b-', 'k-', 'b--'};

% Initialize variables to hold data for each strategy
raw_sinr_data = cell(1, length(strategies));
sinr_data = cell(1, length(strategies));
uho_data = cell(1, length(strategies));
ho_data = cell(1, length(strategies));

% Load data for each strategy
for i = 1:length(strategies)
    data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
    load(data_path, 'MASTER_RAW_SINR', 'MASTER_SINR', 'MASTER_UHO', 'MASTER_HO');
    
    % Reshape the data to be a single vector
    raw_sinr_data{i} = MASTER_RAW_SINR(:);
    sinr_data{i} = MASTER_SINR(:);
    uho_data{i} = MASTER_UHO(:);
    ho_data{i} = MASTER_HO(:);
end

% Generate CDF plots for SINR (tt_SINR)
figure;
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
title('CDF of DL SINR (tt_SINR) for Different HO Strategies');
xlim([-6 3]);  % X축 범위 설정
ylim([0 1]);   % Y축 범위 설정
yticks(0:0.1:1);  % Y축 틱 설정

% Generate CDF plots for MASTER SINR
figure;
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
title('CDF of DL SINR (MASTER\_SINR) for Different HO Strategies');
xlim([-3 1.5]);
yticks(0:0.1:1);

% Generate CDF plots for UHO
figure;
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
title('CDF of UHO for Different HO Strategies');
yticks(0:0.1:1);

% Generate CDF plots for HO
figure;
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
title('CDF of HO for Different HO Strategies');
yticks(0:0.1:1);

% % Prepare data for boxplot
% group_labels = {};
% all_uho_data = [];
% all_ho_data = [];
% 
% for i = 1:length(strategies)
%     group_labels = [group_labels; repmat({strategies{i}}, length(uho_data{i}), 1)];
%     all_uho_data = [all_uho_data; uho_data{i}];
%     all_ho_data = [all_ho_data; ho_data{i}];
% end
% 
% % Generate Box Plot for UHO
% figure;
% boxplot(all_uho_data, group_labels);
% xlabel('HO Strategies');
% ylabel('UHO');
% title('Box Plot of UHO for Different HO Strategies');
% grid on;
% 
% % Generate Box Plot for HO
% figure;
% boxplot(all_ho_data, group_labels);
% xlabel('HO Strategies');
% ylabel('HO');
% title('Box Plot of HO for Different HO Strategies');
% grid on;

%% 로그스케일
figure;
hold on;
for i = 1:length(strategies)
    [cdf_uho, x_uho] = ecdf(uho_data{i});
    semilogx(x_uho, cdf_uho, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
end
hold off;
grid on;
xlabel('UHO (log scale)');
ylabel('CDF');
legend('Location', 'best');
title('CDF of UHO for Different HO Strategies (Log Scale)');

% %% 히스토그램
% figure;
% hold on;
% for i = 1:length(strategies)
%     histogram(uho_data{i}, 'Normalization', 'probability', 'DisplayName', strategies{i}, 'EdgeAlpha', 0.6);
% end
% hold off;
% grid on;
% xlabel('UHO');
% ylabel('Probability');
% legend('Location', 'best');
% title('Histogram of UHO for Different HO Strategies');
% 
% %% 커널밀도
% figure;
% hold on;
% for i = 1:length(strategies)
%     [f, xi] = ksdensity(uho_data{i});
%     plot(xi, f, colors{i}, 'LineWidth', 1.5, 'DisplayName', strategies{i});
% end
% hold off;
% grid on;
% xlabel('UHO');
% ylabel('Density');
% legend('Location', 'best');
% title('Kernel Density Estimate of UHO for Different HO Strategies');
