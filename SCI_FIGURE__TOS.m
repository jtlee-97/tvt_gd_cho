% %% ToS 데이터 불러오기 및 전처리
% % 결과 데이터 폴더 지정
% case_path = 'MasterResults';
% cases = 'case 1';
% scenarios = {'DenseUrban'};
% strategies_all = {'Strategy A', 'Strategy B', 'Strategy C', 'Strategy D', 'Strategy E', 'Strategy F', 'Strategy G', 'Strategy H'}; 
% 
% % ToS 데이터 저장용 변수 초기화
% tos_data_all = cell(length(scenarios), length(strategies_all));
% 
% % 각 전략별 데이터 로드 및 전처리
% for s = 1:length(scenarios)
%     for i = 1:length(strategies_all)
%         % 파일 경로 설정
%         data_path = fullfile(case_path, [cases, '_MASTER_RESULTS_', strategies_all{i}, '_', scenarios{s}, '.mat']);
% 
%         % 파일이 존재하는 경우 데이터 로드
%         if exist(data_path, 'file') == 2
%             loaded_data = load(data_path, 'MASTER_ToS');  % ToS 데이터 로드
% 
%             % ToS 데이터 존재 여부 확인 후 저장
%             if isfield(loaded_data, 'MASTER_ToS') && ~isempty(loaded_data.MASTER_ToS)
%                 tos_data_all{s, i} = loaded_data.MASTER_ToS(:);
%             else
%                 tos_data_all{s, i} = [];  % 데이터가 없을 경우 빈 배열 저장
%                 warning('ToS data missing for strategy %s in %s.', strategies_all{i}, scenarios{s});
%             end
%         else
%             tos_data_all{s, i} = [];
%             warning('File %s does not exist.', data_path);
%         end
%     end
% end
% 
% %% ToS 히스토그램 생성
% figure('Position', [100, 100, 1000, 850]);  % Figure 창 크기 설정
% hold on;
% 
% % 히스토그램을 위한 Bin 설정 (범위 및 개수 조정 가능)
% num_bins = 20; % 히스토그램 구간 개수
% edges = linspace(0, max(cellfun(@max, tos_data_all(~cellfun(@isempty, tos_data_all)))), num_bins + 1); % ToS 범위 설정
% 
% % 각 전략별 ToS 데이터 히스토그램 생성
% for i = 1:length(strategies_all)
%     tos_data = tos_data_all{1, i};  % 현재 전략의 ToS 데이터 가져오기
% 
%     if ~isempty(tos_data) && isvector(tos_data)
%         histogram(tos_data, edges, 'Normalization', 'probability', 'FaceAlpha', 0.5, ...
%                   'DisplayName', strategies_all{i});
%     else
%         warning('ToS data for strategy %s in DenseUrban is empty or not valid.', strategies_all{i});
%     end
% end
% 
% hold off;
% xlabel('Time of Stay (ToS) [s]', 'FontSize', 17.5);
% ylabel('Probability', 'FontSize', 17.5);
% legend('Location', 'northeast');
% title('Distribution of ToS Across Strategies', 'FontSize', 18);
% grid on;
% grid minor;
% 
% % 결과 저장
% output_folder = '_MASTER_RESULTS_FIGURE_';
% if ~exist(output_folder, 'dir')
%     mkdir(output_folder);
% end
% 
% savefig(fullfile(output_folder, 'results_ToS_histogram.fig'));  % fig 저장
% saveas(gcf, fullfile(output_folder, 'results_ToS_histogram.png'));  % png 저장
% 
% %% 개선된 ToS 히스토그램 코드
% figure('Position', [100, 100, 1200, 900]);  % Figure 창 크기 설정
% hold on;
% 
% % 히스토그램을 위한 Bin 설정 (범위 및 개수 조정 가능)
% num_bins = 20;
% edges = linspace(0, max(cellfun(@max, tos_data_all(~cellfun(@isempty, tos_data_all)))), num_bins + 1);
% 
% % 색상 팔레트 설정 (MATLAB 기본 colormap 활용)
% colors = lines(length(strategies_all));  % 각 전략별 다른 색상 적용
% 
% % 각 전략별 ToS 데이터 히스토그램 생성
% for i = 1:length(strategies_all)
%     tos_data = tos_data_all{1, i};  % 현재 전략의 ToS 데이터 가져오기
% 
%     if ~isempty(tos_data) && isvector(tos_data)
%         histogram(tos_data, edges, 'Normalization', 'probability', ...
%                   'FaceColor', colors(i, :), 'EdgeColor', 'k', 'FaceAlpha', 0.7, ...
%                   'LineWidth', 1.2, 'DisplayName', strategies_all{i});
%     else
%         warning('ToS data for strategy %s in DenseUrban is empty or not valid.', strategies_all{i});
%     end
% end
% 
% hold off;
% xlabel('Time of Stay (ToS) [s]', 'FontSize', 17.5);
% ylabel('Probability', 'FontSize', 17.5);
% legend('Location', 'northeastoutside'); % 범례를 바깥에 위치
% title('Improved Distribution of ToS Across Strategies', 'FontSize', 18);
% grid on;
% grid minor;
% 
% % 결과 저장
% output_folder = '_MASTER_RESULTS_FIGURE_';
% if ~exist(output_folder, 'dir')
%     mkdir(output_folder);
% end
% 
% savefig(fullfile(output_folder, 'results_ToS_histogram_improved.fig'));  % fig 저장
% saveas(gcf, fullfile(output_folder, 'results_ToS_histogram_improved.png'));  % png 저장

%% ToS 데이터 불러오기 및 전처리
% 결과 데이터 폴더 지정
case_path = 'MasterResults';
cases = 'case 1';
scenarios = {'DenseUrban'};
strategies_all = {'Strategy A', 'Strategy B', 'Strategy C', 'Strategy D', 'Strategy E', 'Strategy F', 'Strategy G', 'Strategy H'}; 

% ToS 데이터 저장용 변수 초기화
tos_data_all = cell(length(scenarios), length(strategies_all));

% 각 전략별 데이터 로드 및 전처리
for s = 1:length(scenarios)
    for i = 1:length(strategies_all)
        % 파일 경로 설정
        data_path = fullfile(case_path, [cases, '_MASTER_RESULTS_', strategies_all{i}, '_', scenarios{s}, '.mat']);
        
        % 파일이 존재하는 경우 데이터 로드
        if exist(data_path, 'file') == 2
            loaded_data = load(data_path, 'MASTER_ToS');  % ToS 데이터 로드
            
            % ToS 데이터 존재 여부 확인 후 저장
            if isfield(loaded_data, 'MASTER_ToS') && ~isempty(loaded_data.MASTER_ToS)
                tos_data_all{s, i} = loaded_data.MASTER_ToS(:);
            else
                tos_data_all{s, i} = [];  % 데이터가 없을 경우 빈 배열 저장
                warning('ToS data missing for strategy %s in %s.', strategies_all{i}, scenarios{s});
            end
        else
            tos_data_all{s, i} = [];
            warning('File %s does not exist.', data_path);
        end
    end
end

% %% 커널 밀도 추정 (KDE) 기반 확률 밀도 그래프
% figure('Position', [100, 100, 1200, 900]);  % Figure 창 크기 설정
% hold on;
% 
% % 색상 팔레트 설정 (MATLAB 기본 colormap 활용)
% colors = lines(length(strategies_all));  % 각 전략별 다른 색상 적용
% 
% % 각 전략별 KDE 그래프 생성
% for i = 1:length(strategies_all)
%     tos_data = tos_data_all{1, i};  % 현재 전략의 ToS 데이터 가져오기
% 
%     if ~isempty(tos_data) && isvector(tos_data)
%         [f, x] = ksdensity(tos_data, 'Bandwidth', 0.2); % KDE 수행, Bandwidth 조정 가능
%         plot(x, f, 'Color', colors(i, :), 'LineWidth', 2, 'DisplayName', strategies_all{i});
%     else
%         warning('ToS data for strategy %s in DenseUrban is empty or not valid.', strategies_all{i});
%     end
% end
% 
% hold off;
% xlabel('Time of Stay (ToS) [s]', 'FontSize', 17.5);
% ylabel('Probability Density', 'FontSize', 17.5);
% legend('Location', 'northeastoutside'); % 범례를 그래프 바깥에 배치
% title('Probability Density of ToS Across Strategies (KDE)', 'FontSize', 18);
% grid on;
% grid minor;
% 
% % 결과 저장
% output_folder = '_MASTER_RESULTS_FIGURE_';
% if ~exist(output_folder, 'dir')
%     mkdir(output_folder);
% end
% 
% savefig(fullfile(output_folder, 'results_ToS_KDE.fig'));  % fig 저장
% saveas(gcf, fullfile(output_folder, 'results_ToS_KDE.png'));  % png 저장
% 
% %% CDF 기반 누적 확률 그래프
% figure('Position', [100, 100, 1200, 900]);  
% hold on;
% 
% % 색상 팔레트 설정
% colors = lines(length(strategies_all));
% 
% % 각 전략별 CDF 그래프 생성
% for i = 1:length(strategies_all)
%     tos_data = tos_data_all{1, i};
% 
%     if ~isempty(tos_data) && isvector(tos_data)
%         [f, x] = ksdensity(tos_data, 'Function', 'cdf'); % CDF로 변환
%         plot(x, f, 'Color', colors(i, :), 'LineWidth', 2, 'DisplayName', strategies_all{i});
%     else
%         warning('ToS data for strategy %s in DenseUrban is empty or not valid.', strategies_all{i});
%     end
% end
% 
% hold off;
% xlabel('Time of Stay (ToS) [s]', 'FontSize', 17.5);
% ylabel('Cumulative Probability', 'FontSize', 17.5);
% legend('Location', 'northeastoutside');  
% title('Cumulative Distribution Function (CDF) of ToS Across Strategies', 'FontSize', 18);
% grid on;
% grid minor;
% 
% % 결과 저장
% savefig(fullfile(output_folder, 'results_ToS_CDF.fig'));  
% saveas(gcf, fullfile(output_folder, 'results_ToS_CDF.png'));  

%% ToS 누적 막대 그래프 (Stacked Bar Plot)
figure('Position', [100, 100, 1200, 900]);  
hold on;

% 시간 구간 설정
time_bins = 0:1:ceil(max(cellfun(@max, tos_data_all(~cellfun(@isempty, tos_data_all))))); % 1초 단위 구간
num_bins = length(time_bins) - 1;

% 각 전략별 ToS 히스토그램 데이터 생성
tos_hist_data = zeros(length(strategies_all), num_bins);

for i = 1:length(strategies_all)
    tos_data = tos_data_all{1, i};
    
    if ~isempty(tos_data) && isvector(tos_data)
        tos_hist_data(i, :) = histcounts(tos_data, time_bins);
    else
        warning('ToS data for strategy %s in DenseUrban is empty or not valid.', strategies_all{i});
    end
end

% 막대 그래프 (누적)
bar(time_bins(1:end-1), tos_hist_data', 'stacked');

% 그래프 스타일링
xlabel('Time of Stay (ToS) [s]', 'FontSize', 17.5);
ylabel('Number of Occurrences', 'FontSize', 17.5);
legend(strategies_all, 'Location', 'northeastoutside');
title('Stacked Bar Chart of ToS Across Strategies', 'FontSize', 18);
grid on;
grid minor;

% 결과 저장
output_folder = '_MASTER_RESULTS_FIGURE_';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

savefig(fullfile(output_folder, 'results_ToS_StackedBar.fig'));  
saveas(gcf, fullfile(output_folder, 'results_ToS_StackedBar.png'));  

%% ToS 누적 면적 그래프 (Stacked Area Chart)
figure('Position', [100, 100, 1200, 900]);  
hold on;

% 시간 구간 설정
time_bins = 0:1:ceil(max(cellfun(@max, tos_data_all(~cellfun(@isempty, tos_data_all))))); % 1초 단위 구간
num_bins = length(time_bins) - 1;

% 각 전략별 ToS 히스토그램 데이터 생성
tos_hist_data = zeros(length(strategies_all), num_bins);

for i = 1:length(strategies_all)
    tos_data = tos_data_all{1, i};
    
    if ~isempty(tos_data) && isvector(tos_data)
        tos_hist_data(i, :) = histcounts(tos_data, time_bins);
    else
        warning('ToS data for strategy %s in DenseUrban is empty or not valid.', strategies_all{i});
    end
end

% 데이터 정규화 (각 시간 구간에서 전체 비율로 변환)
tos_hist_data_norm = tos_hist_data ./ sum(tos_hist_data, 1);

% 면적 그래프 (누적)
area(time_bins(1:end-1), tos_hist_data_norm');

% 그래프 스타일링
xlabel('Time of Stay (ToS) [s]', 'FontSize', 17.5);
ylabel('Proportion', 'FontSize', 17.5);
legend(strategies_all, 'Location', 'northeastoutside');
title('Stacked Area Chart of ToS Across Strategies', 'FontSize', 18);
grid on;
grid minor;

% 결과 저장
savefig(fullfile(output_folder, 'results_ToS_StackedArea.fig'));  
saveas(gcf, fullfile(output_folder, 'results_ToS_StackedArea.png'));  

%% ToS CDF 그래프 생성
figure('Position', [100, 100, 1200, 900]);  
hold on;

% 색상 팔레트 설정 (MATLAB 기본 colormap 활용)
colors = lines(length(strategies_all));

% 각 전략별 CDF 그래프 생성
for i = 1:length(strategies_all)
    tos_data = tos_data_all{1, i};  % 현재 전략의 ToS 데이터 가져오기
    
    if ~isempty(tos_data) && isvector(tos_data)
        % 누적 분포 함수 (CDF) 계산
        [f, x] = ecdf(tos_data); 
        
        % CDF 그래프 플롯
        plot(x, f, 'Color', colors(i, :), 'LineWidth', 2, 'DisplayName', strategies_all{i});
    else
        warning('ToS data for strategy %s in DenseUrban is empty or not valid.', strategies_all{i});
    end
end

hold off;
xlabel('Time of Stay (ToS) [s]', 'FontSize', 17.5);
ylabel('Cumulative Probability', 'FontSize', 17.5);
legend('Location', 'southeast');  % 누적 확률은 1에 수렴하므로 범례를 아래 배치
title('Cumulative Distribution Function (CDF) of ToS Across Strategies', 'FontSize', 18);
grid on;
grid minor;

% 결과 저장
output_folder = '_MASTER_RESULTS_FIGURE_';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

savefig(fullfile(output_folder, 'results_ToS_CDF.fig'));  
saveas(gcf, fullfile(output_folder, 'results_ToS_CDF.png'));  
