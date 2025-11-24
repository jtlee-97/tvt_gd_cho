clear all;

%% =======================================
% 설정 확인 필수
UE_num = 10;

START_TIME = 0;
SAMPLE_TIME = 0.2; % 200ms 간격
TOTAL_TIME = 173.21 / 7.56; % 동적으로 계산된 총 시뮬레이션 시간
STOP_TIME = TOTAL_TIME;
TIMEVECTOR = START_TIME:SAMPLE_TIME:STOP_TIME; % 동적으로 시간 벡터 생성
expected_samples = length(TIMEVECTOR); % 예상되는 시간 스텝 개수
% =======================================

%% 데이터 경로 관련
cases = 'case 1';
case_path = 'MasterResults';

% 결과 저장 폴더 설정
output_folder = '_MASTER_RESULTS_FIGURE_';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

strategies_all = {'Strategy A', 'Strategy B', 'Strategy C', 'Strategy D', ...
                  'Strategy E', 'Strategy F', 'Strategy G', 'Strategy H'};
scenarios = {'DenseUrban', 'Rural'}; % 시나리오 추가

%% 색상 설정
display_names = {'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5', 'Set 6', 'Set 7', 'Set 8'};
bar_colors = [0.8500, 0.3250, 0.0980;  % DenseUrban (주황)
              0, 0.4470, 0.7410];      % Rural (파랑)

%% 데이터 컨테이너 초기화
num_scenarios = length(scenarios);
num_strategies = length(strategies_all);
uho_data_all = zeros(num_strategies, num_scenarios);
ho_data_all = zeros(num_strategies, num_scenarios);
rlf_data_all = zeros(num_strategies, num_scenarios);
hopp_data_all = zeros(num_strategies, num_scenarios);

%% 데이터 로드
for s = 1:num_scenarios
    for i = 1:num_strategies
        data_path = fullfile(case_path, [cases, '_MASTER_RESULTS_', strategies_all{i}, '_', scenarios{s}, '.mat']);
        
        if exist(data_path, 'file') == 2
            loaded_data = load(data_path, 'MASTER_UHO', 'MASTER_HO', 'MASTER_RLF', 'MASTER_HOPP');

            uho_data_all(i, s) = mean(loaded_data.MASTER_UHO, 'all');
            ho_data_all(i, s) = mean(loaded_data.MASTER_HO, 'all');
            rlf_data_all(i, s) = sum(loaded_data.MASTER_RLF, 'all');
            hopp_data_all(i, s) = mean(loaded_data.MASTER_HOPP, 'all');
        else
            warning('File %s does not exist.', data_path);
        end
    end
end

%% KPI별 개별 바 그래프 생성
kpi_labels = {'UHO per HO (%)', 'HOPP per HO (%)', 'RLF per UE/sec'};
kpi_data = { ...
    (uho_data_all ./ (ho_data_all + eps)) * 100, ... % UHO/HO 비율
    (hopp_data_all ./ (ho_data_all + eps)) * 100, ... % HOPP/HO 비율
    (rlf_data_all ./ (TOTAL_TIME * UE_num))}; % RLF per UE/sec

file_names = {'results_UHO_HO', 'results_HOPP_HO', 'results_RLF_per_UE'};

for k = 1:length(kpi_labels)
    figure('Position', [100, 100, 1200, 800]); % 개별 KPI 그래프
    total_groups = num_strategies; % 그룹 개수 (Set 개수)
    num_bars_per_group = num_scenarios; % 각 그룹 내 바 개수 (DenseUrban + Rural)

    kpi_grouped = zeros(total_groups, num_bars_per_group);
    labels_grouped = strings(total_groups, 1);

    for i = 1:num_strategies
        for s = 1:num_scenarios
            kpi_grouped(i, s) = kpi_data{k}(i, s);
        end
        labels_grouped(i) = strcat(display_names{i});
    end

    % 개별 KPI 그래프 그리기 (Grouped Bar)
    b = bar(kpi_grouped, 'grouped');
    for s = 1:num_scenarios
        b(s).FaceColor = bar_colors(s, :);
    end

    % X축 설정
    set(gca, 'XTick', 1:total_groups, 'XTickLabel', labels_grouped, 'FontSize', 12);
    xtickangle(45);

    % 범례 추가
    legend(scenarios, 'Location', 'best', 'FontSize', 12);

    % 라벨 및 제목
    ylabel(kpi_labels{k}, 'FontSize', 14);
    title([kpi_labels{k}, ' Comparison (DenseUrban vs Rural)'], 'FontSize', 14);
    grid on;

    % 결과 저장
    savefig(fullfile(output_folder, [file_names{k}, '.fig']));
    saveas(gcf, fullfile(output_folder, [file_names{k}, '.png']));
end
