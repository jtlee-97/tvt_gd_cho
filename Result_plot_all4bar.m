%% 분할 그래프
% % Initialize strategies and colors
% strategies = {'BHO_A3', 'CHO_A3', 'Distance', 'Distance_DD2'};
% colors = {'r', 'b', 'k', 'm'};
% 
% % Create a new figure for the line plots
% figure;
% 
% for i = 1:length(strategies)
%     % Load data for each strategy
%     data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
%     load(data_path, 'MASTER_UHO', 'MASTER_HO');
% 
%     % Calculate the mean across each column (each UE) for UHO and HO
%     avg_uho_data = mean(MASTER_UHO, 1);  % Mean across columns for UHO
%     avg_ho_data = mean(MASTER_HO, 1);    % Mean across columns for HO
% 
%     % Subplot for UHO
%     subplot(4, 2, 2*i-1);
%     plot(avg_uho_data, '-', 'Color', colors{i}, 'LineWidth', 0.5);
%     xlabel('UEs');
%     ylabel('Average UHO');
%     title(['Average UHO per UE - ', strategies{i}]);
%     grid on;
% 
%     % Subplot for HO
%     subplot(4, 2, 2*i);
%     plot(avg_ho_data, '-', 'Color', colors{i}, 'LineWidth', 0.5);
%     xlabel('UEs');
%     ylabel('Average HO');
%     title(['Average HO per UE - ', strategies{i}]);
%     grid on;
% end
% 
% % Adjust layout
% set(gcf, 'Position', [100, 100, 1200, 800]);  % Adjust the figure size for better visibility

%% 통합 그래프
% % Initialize strategies and colors
% strategies = {'BHO_A3', 'CHO_A3', 'Distance', 'Distance_DD2'};
% colors = {'r', 'b', 'k', 'm'};
% 
% % Create a new figure for the combined line plots
% figure;
% 
% % Subplot for UHO
% subplot(1, 2, 1);
% hold on;
% for i = 1:length(strategies)
%     % Load data for each strategy
%     data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
%     load(data_path, 'MASTER_UHO');
% 
%     % Calculate the mean across each column (each UE) for UHO
%     avg_uho_data = mean(MASTER_UHO, 1);  % Mean across columns for UHO
% 
%     % Plot UHO data
%     plot(avg_uho_data, '-', 'Color', colors{i}, 'LineWidth', 0.5, 'DisplayName', strategies{i});
% end
% xlabel('UEs');
% ylabel('Average UHO');
% title('Average UHO per UE');
% legend('show');
% grid on;
% hold off;
% 
% % Subplot for HO
% subplot(1, 2, 2);
% hold on;
% for i = 1:length(strategies)
%     % Load data for each strategy
%     data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
%     load(data_path, 'MASTER_HO');
% 
%     % Calculate the mean across each column (each UE) for HO
%     avg_ho_data = mean(MASTER_HO, 1);  % Mean across columns for HO
% 
%     % Plot HO data
%     plot(avg_ho_data, '-', 'Color', colors{i}, 'LineWidth', 0.5, 'DisplayName', strategies{i});
% end
% xlabel('UEs');
% ylabel('Average HO');
% title('Average HO per UE');
% legend('show');
% grid on;
% hold off;
% 
% % Adjust layout
% set(gcf, 'Position', [100, 100, 1200, 600]);  % Adjust the figure size for better visibility

% % Initialize strategies and colors
% strategies = {'CHO A3', 'DCHO', 'Proposed DCHO'};
% colors = {'k', 'b', 'r'};
% lineStyles = {':', '-', '-'};
% 
% % Create a new figure for the combined line plots
% figure;
% 
% % Subplot for UHO
% subplot(1, 2, 1);
% hold on;
% for i = 1:length(strategies)
%     % Load data for each strategy
%     data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
%     load(data_path, 'MASTER_UHO');
% 
%     % Calculate the mean across each column (each UE) for UHO
%     avg_uho_data = mean(MASTER_UHO, 1);  % Mean across columns for UHO
% 
%     % Generate x-axis values based on the length of avg_uho_data
%     x_values = linspace(100, 25000, length(avg_uho_data));
% 
%     % Plot UHO data with different line styles (no markers)
%     plot(x_values, avg_uho_data, 'Color', colors{i}, 'LineStyle', lineStyles{i}, ...
%         'LineWidth', 0.7, 'DisplayName', strategies{i});
% end
% xlabel('Distance [m]');
% ylabel('Average UHO');
% title('Average UHO per UE');
% legend('show');
% grid on;
% xlim([0 25000]);
% hold off;
% 
% % Subplot for HO
% subplot(1, 2, 2);
% hold on;
% for i = 1:length(strategies)
%     % Load data for each strategy
%     data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
%     load(data_path, 'MASTER_HO');
% 
%     % Calculate the mean across each column (each UE) for HO
%     avg_ho_data = mean(MASTER_HO, 1);  % Mean across columns for HO
% 
%     % Generate x-axis values based on the length of avg_ho_data
%     x_values = linspace(100, 25000, length(avg_ho_data));
% 
%     % Plot HO data with different line styles (no markers)
%     plot(x_values, avg_ho_data, 'Color', colors{i}, 'LineStyle', lineStyles{i}, ...
%         'LineWidth', 1, 'DisplayName', strategies{i});
% end
% xlabel('Distance [m]');
% ylabel('Average HO');
% title('Average HO per UE');
% legend('show');
% grid on;
% xlim([0 25000]);
% hold off;
% 
% % Adjust layout
% set(gcf, 'Position', [100, 100, 1200, 600]);  % Adjust the figure size for better visibility

% Initialize strategies and colors
strategies = {'CHO A3', 'DCHO', 'Proposed DCHO'};
colors = {'k', 'b', 'r'};
lineStyles = {':', '-', '-'};

% Create a new figure for the combined line plots
figure;

% Subplot 1: UHO
subplot(1, 3, 1);
hold on;
for i = 1:length(strategies)
    % Load data for each strategy
    data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
    load(data_path, 'MASTER_UHO');
    
    % Calculate the mean across each column (each UE) for UHO
    avg_uho_data = mean(MASTER_UHO, 1);  % Mean across columns for UHO
    
    % Generate x-axis values based on the length of avg_uho_data
    x_values = linspace(100, 25000, length(avg_uho_data));
    
    % Plot UHO data with different line styles (no markers)
    plot(x_values, avg_uho_data, 'Color', colors{i}, 'LineStyle', lineStyles{i}, ...
        'LineWidth', 0.7, 'DisplayName', strategies{i});
end
xlabel('Distance [m]');
ylabel('Average UHO');
title('Average UHO per UE');
legend('show');
grid on;
xlim([0 25000]);
hold off;

% Subplot 2: HO
subplot(1, 3, 2);
hold on;
for i = 1:length(strategies)
    % Load data for each strategy
    data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
    load(data_path, 'MASTER_HO');
    
    % Calculate the mean across each column (each UE) for HO
    avg_ho_data = mean(MASTER_HO, 1);  % Mean across columns for HO
    
    % Generate x-axis values based on the length of avg_ho_data
    x_values = linspace(100, 25000, length(avg_ho_data));
    
    % Plot HO data with different line styles (no markers)
    plot(x_values, avg_ho_data, 'Color', colors{i}, 'LineStyle', lineStyles{i}, ...
        'LineWidth', 1, 'DisplayName', strategies{i});
end
xlabel('Distance [m]');
ylabel('Average HO');
title('Average HO per UE');
legend('show');
grid on;
xlim([0 25000]);
hold off;

% Subplot 3: UHO/HO ratio
subplot(1, 3, 3);
hold on;
for i = 1:length(strategies)
    % Load data for each strategy
    data_path = fullfile('Result', 'master_results', ['MASTER_RESULTS_', strategies{i}, '.mat']);
    load(data_path, 'MASTER_UHO', 'MASTER_HO');
    
    % Calculate the mean across each column (each UE) for UHO and HO
    avg_uho_data = mean(MASTER_UHO, 1);  % Mean across columns for UHO
    avg_ho_data = mean(MASTER_HO, 1);    % Mean across columns for HO
    
    % Calculate UHO/HO ratio, avoiding division by zero
    ratio_data = avg_uho_data ./ (avg_ho_data + eps);  % Add eps to avoid division by zero
    
    % Generate x-axis values based on the length of ratio_data
    x_values = linspace(100, 25000, length(ratio_data));
    
    % Plot UHO/HO ratio data with different line styles (no markers)
    plot(x_values, ratio_data, 'Color', colors{i}, 'LineStyle', lineStyles{i}, ...
        'LineWidth', 1, 'DisplayName', strategies{i});
end
xlabel('Distance [m]');
ylabel('UHO/HO Ratio');
title('UHO to HO Ratio per UE');
legend('show');
grid on;
xlim([0 25000]);
hold off;

% Adjust layout
set(gcf, 'Position', [100, 100, 1200, 900]);  % Adjust the figure size for better visibility
