% Data for each category
categories = {'dd2', 'd2', 'a3c', 'acb'};
SINR = [-0.908813232, -0.63395244, -0.647174927, -0.594959142];
UHO = [0.294820717, 0.474103586, 0.490039841, 2.09561753];
HO = [1.772908367, 1.90438247, 1.892430279, 3.394422311];
UHO_HO = [0.166292135, 0.248953975, 0.258947368, 0.617370892];

% Combine the data
data = [SINR; UHO; HO; UHO_HO];

% Create a bar graph with custom colors
figure;
b = bar(data', 'grouped');

% Customizing colors to emphasize dd2
b(1).FaceColor = [0.2 0.6 1];  % SINR - light blue
b(2).FaceColor = [1 0.4 0];    % UHO - orange
b(3).FaceColor = [1 0.8 0];    % HO - yellow
b(4).FaceColor = [0.6 0 0.8];  % UHO/HO - purple

% Set the x-axis labels
set(gca, 'XTickLabel', categories);

% Add title and axis labels
title('SINR, UHO, HO, UHO/HO values for dd2, d2, a3c, acb');
xlabel('Categories');
ylabel('Values');

% Add legend
legend({'SINR', 'UHO', 'HO', 'UHO/HO'}, 'Location', 'BestOutside');

% Adjust y-axis limits to emphasize the differences
ylim([-1 4]);

% Display grid for better readability
grid on;
