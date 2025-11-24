% Parameters (You can set these)
UE_num = 251;  % Set the number of UEs
SIMTIME = 173.21 / 7.56;  % Set the simulation time

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

% Initialize an array to store total RLF occurrences
total_rlf = zeros(length(file_names), 1);

% Loop through each file and calculate total RLF occurrences
for i = 1:length(file_names)
    % Generate the full path to the data file
    data_path = fullfile('Result', 'master_results', file_names{i});
    
    % Load the MASTER_RLF data from each file
    data = load(data_path, 'MASTER_RLF');
    
    % Sum all values in MASTER_RLF and store in total_rlf array
    total_rlf(i) = sum(data.MASTER_RLF(:));
end

% Plotting the total RLF occurrences
figure;
bar(total_rlf);
set(gca, 'XTick', 1:length(strategy_labels), 'XTickLabel', strategy_labels);
xlabel('Strategy');
ylabel('Total RLF Occurrences');
title('Total RLF Occurrences Across Strategies');
grid on;

% Adjust figure size
set(gcf, 'Position', [100, 100, 1000, 600]);
