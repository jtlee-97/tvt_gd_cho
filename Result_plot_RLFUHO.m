run('system_parameter.m');

% Define the file names
file_names = {
    'MASTER_RESULTS_BHO A3 (0, 0).mat', ...
    'MASTER_RESULTS_BHO A3 (1, 0.1).mat', ...
    'MASTER_RESULTS_BHO A3 (2, 0.256).mat', ...
    'MASTER_RESULTS_CHO A3 (0, 0).mat', ...
    'MASTER_RESULTS_CHO A3 (1, 0.1).mat', ...
    'MASTER_RESULTS_CHO A3 (2, 0.256).mat', ...
    'MASTER_RESULTS_DCHO.mat', ...
    'MASTER_RESULTS_Proposed DCHO.mat'
};

% Define strategy labels for the x-axis
strategy_labels = {
    'BHO A3 (0, 0)', ...
    'BHO A3 (1, 0.1)', ...
    'BHO A3 (2, 0.256)', ...
    'CHO A3 (0, 0)', ...
    'CHO A3 (1, 0.1)', ...
    'CHO A3 (2, 0.256)', ...
    'DCHO', ...
    'Proposed DCHO'
};

% Initialize arrays to store normalized RLF and UHO occurrences
normalized_rlf = zeros(length(file_names), 1);
normalized_uho = zeros(length(file_names), 1);

% Loop through each file and calculate normalized RLF and UHO occurrences
for i = 1:length(file_names)
    % Generate the full path to the data file
    data_path = fullfile('Result', 'master_results', file_names{i});
    
    % Load the MASTER_RLF and MASTER_UHO data from each file
    data = load(data_path, 'MASTER_RLF', 'MASTER_UHO');
    
    % Sum all values in MASTER_RLF and MASTER_UHO
    total_rlf = sum(data.MASTER_RLF(:));
    total_uho = sum(data.MASTER_UHO(:));
    
    % Normalize the RLF and UHO occurrences
    normalized_rlf(i) = total_rlf / (UE_num * TOTAL_TIME * EPISODE);
    normalized_uho(i) = total_uho / (UE_num * TOTAL_TIME * EPISODE);
end

% Plotting the normalized RLF and UHO occurrences
figure;
b = bar([normalized_rlf, normalized_uho]);  % Create a grouped bar plot
set(gca, 'XTick', 1:length(strategy_labels), 'XTickLabel', strategy_labels);
xlabel('Strategy');
ylabel('[Operations/UE/sec.]');
legend({'RLF', 'UHO'}, 'Location', 'northwest');  % Add a legend to differentiate between RLF and UHO
grid on;

% Add values on top of each bar for RLF
xtips_rlf = b(1).XEndPoints;
ytips_rlf = b(1).YEndPoints;
labels_rlf = string(round(b(1).YData, 3)); % Round to 3 decimal places
text(xtips_rlf, ytips_rlf, labels_rlf, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

% Add values on top of each bar for UHO
xtips_uho = b(2).XEndPoints;
ytips_uho = b(2).YEndPoints;
labels_uho = string(round(b(2).YData, 3)); % Round to 3 decimal places
text(xtips_uho, ytips_uho, labels_uho, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

% Adjust figure size
set(gcf, 'Position', [100, 100, 1000, 600]);
