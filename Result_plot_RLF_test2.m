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

% Initialize an array to store normalized RLF occurrences
normalized_rlf = zeros(length(file_names), 1);

% Loop through each file and calculate normalized RLF occurrences
for i = 1:length(file_names)
    % Generate the full path to the data file
    data_path = fullfile('Result', 'master_results', file_names{i});
    
    % Load the MASTER_RLF data from each file
    data = load(data_path, 'MASTER_RLF');
    
    % Sum all values in MASTER_RLF
    total_rlf = sum(data.MASTER_RLF(:));
    
    % Normalize the RLF occurrences
    normalized_rlf(i) = total_rlf / (UE_num * TOTAL_TIME * EPISODE);
end

% Plotting the normalized RLF occurrences
figure;
b = bar(normalized_rlf);
set(gca, 'XTick', 1:length(strategy_labels), 'XTickLabel', strategy_labels);
xlabel('Strategy');
ylabel('[RLF operations/UE/sec.]');
grid on;

% Add values on top of each bar
xtips = b.XEndPoints;
ytips = b.YEndPoints;
labels = string(round(b.YData, 4)); % Adjust the rounding as needed
text(xtips, ytips, labels, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

% Adjust figure size
set(gcf, 'Position', [100, 100, 1000, 600]);
