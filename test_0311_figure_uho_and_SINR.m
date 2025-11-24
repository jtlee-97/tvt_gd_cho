%% --------------------------------------------------------------------------------------------------------------------
% 📌 데이터 불러오기 및 정규화 + 관계 분석

% 결과 저장 폴더 설정
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 전략 수 계산
num_strategies = length(strategies_all);

% 데이터를 저장할 변수 초기화
uho_data_all_sim = cell(1, num_strategies);

%% 데이터 불러오기
for s = 1:length(scenarios)
    for i = 1:num_strategies
        data_path = fullfile(case_path, [cases, '_MASTER_RESULTS_', strategies_all{i}, '_', scenarios{s}, '.mat']);
        
        if exist(data_path, 'file') == 2
            loaded_data = load(data_path, 'MASTER_UHO');
            
            if isfield(loaded_data, 'MASTER_UHO') && ~isempty(loaded_data.MASTER_UHO)
                uho_data_all_sim{i} = loaded_data.MASTER_UHO(:);
            end
        else
            warning('File %s does not exist.', data_path);
        end
    end
end

%% -------------------------------
% 데이터 정규화 (Min-Max Normalization)
% -------------------------------
uho_all = vertcat(uho_data_all_sim{:});
uho_min = min(uho_all);
uho_max = max(uho_all);

for i = 1:num_strategies
    if ~isempty(uho_data_all_sim{i})
        uho_data_all_sim{i} = (uho_data_all_sim{i} - uho_min) / (uho_max - uho_min);
    end
end

%% -------------------------------
% 1. 히트맵 (Gray 컬러맵)
% -------------------------------
figure('Position', [100, 100, 900, 500]);
h = heatmap(strategies_all, {'Normalized UHO'}, cellfun(@mean, uho_data_all_sim));
h.Title = 'Heatmap of Normalized UHO';
colormap('gray');
savefig(fullfile(output_folder, 'UHO_Heatmap.fig'));
saveas(gcf, fullfile(output_folder, 'UHO_Heatmap.png'));

%% -------------------------------
% 2. 전략별 UHO 데이터 산포도 (Scatter Plot)
% -------------------------------
figure('Position', [100, 100, 1000, 600]);
hold on;
for i = 1:num_strategies
    if ~isempty(uho_data_all_sim{i})
        x_vals = repmat(i, size(uho_data_all_sim{i}));
        y_vals = uho_data_all_sim{i};
        scatter(x_vals, y_vals, 20, y_vals, 'filled');
    end
end
hold off;
xlabel('Strategies', 'FontSize', 14);
ylabel('Normalized UHO Count', 'FontSize', 14);
set(gca, 'XTick', 1:num_strategies, 'XTickLabel', strategies_all, 'FontSize', 12);
title('Scatter Plot of Normalized UHO Distribution', 'FontSize', 16);
colormap('jet');
colorbar;
grid on;
savefig(fullfile(output_folder, 'UHO_Scatter.fig'));
saveas(gcf, fullfile(output_folder, 'UHO_Scatter.png'));

%% -------------------------------
% 3. 전략별 UHO 바 그래프
% -------------------------------
figure('Position', [100, 100, 1000, 600]);
bar(cellfun(@mean, uho_data_all_sim), 'FaceColor', 'k');
xlabel('Strategies', 'FontSize', 14);
ylabel('Mean Normalized UHO Count', 'FontSize', 14);
set(gca, 'XTick', 1:num_strategies, 'XTickLabel', strategies_all, 'FontSize', 12);
title('Bar Chart of Mean Normalized UHO', 'FontSize', 16);
grid on;
savefig(fullfile(output_folder, 'UHO_Bar.fig'));
saveas(gcf, fullfile(output_folder, 'UHO_Bar.png'));
