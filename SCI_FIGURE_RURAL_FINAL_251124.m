clear;
close all;

%% =======================================
% 설정 확인 필수
UE_num = 100;
START_TIME = 0;
SAMPLE_TIME = 0.2; % 200ms 간격
TOTAL_TIME = 173.21 / 7.56; % 동적으로 계산된 총 시뮬레이션 시간
STOP_TIME = TOTAL_TIME;
TIMEVECTOR = START_TIME:SAMPLE_TIME:STOP_TIME; % 동적으로 시간 벡터 생성
expected_samples = length(TIMEVECTOR); % 예상되는 시간 스텝 개수

% =======================================
% 데이터 경로 관련
cases = 'case 1';
case_path = 'MasterResults';

% 결과 저장 폴더 설정
output_folder = '_TVT_REV1_1123_RESULTS_FIGURE_2511242230';
% 폴더가 없으면 생성
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% strategies_all = {'Strategy A', 'Strategy B', 'Strategy D', 'Strategy F', 'Strategy I', 'Strategy J', 'Strategy K', 'Strategy L'};
strategies_all = {'Strategy A', 'Strategy B', 'Strategy C', 'Strategy D', 'Strategy E', 'Strategy F', 'Strategy G'};
subset_indices = [1, 4, 7, 8, 9];  % A, D, G, J, K

% scenarios = {'DenseUrban', 'Rural'};
scenarios = {'Rural'};

% 색상 설정
display_names = {'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5', 'Set 6', 'Set 7'}; 

colors_all = { ...
    [0, 0.447, 0.741], [0, 0.447, 0.741], [0, 0.447, 0.741] ...
    [0.85, 0.325, 0.098], [0.635, 0.078, 0.184], [0.494, 0.184, 0.556], [0.494, 0.184, 0.556]};
lineStyles_all = {'--',':','--','--','--','-.', '-.', '-.', '-'};
markerStyles_all = {'o', 'v', '^', 'square', 'diamond', 'pentagram', 'hexagram', 'x'};

% 부드러운 색상 설정
bar1_colors = [0, 0.447, 0.7410];  % 파란색
bar2_colors = [0.635, 0.078, 0.184];  % 빨간색
bar3_colors = [0.4940 0.1840 0.5560];  % 보라색

% Initialize data containers
raw_sinr_data_all = cell(length(scenarios), length(strategies_all));
raw_rsrp_data_all = cell(length(scenarios), length(strategies_all));
sinr_data_all = cell(length(scenarios), length(strategies_all));
rsrp_data_all = cell(length(scenarios), length(strategies_all));
rlf_data_all = cell(length(scenarios), length(strategies_all));
uho_data_all = cell(length(scenarios), length(strategies_all));
ho_data_all = cell(length(scenarios), length(strategies_all));
uho_ho_ratio_all = cell(length(scenarios), length(strategies_all));
sub_tos_data_all = cell(length(scenarios), length(subset_indices));
tos_data_all = cell(length(scenarios), length(strategies_all));
hopp_data_all = cell(length(scenarios), length(strategies_all));
rbs_data_all = cell(length(scenarios), length(strategies_all));

% Load data for each strategy and scenario
for s = 1:length(scenarios)
    for i = 1:length(strategies_all)
        % Corrected path using filesep
        data_path = fullfile(case_path, [cases, '_MASTER_RESULTS_', strategies_all{i}, '_', scenarios{s}, '.mat']);
        
        % Check if the file exists before attempting to load
        if exist(data_path, 'file') == 2
            loaded_data = load(data_path, 'MASTER_RAW_SINR', 'MASTER_RAW_RSRP', 'MASTER_UHO', 'MASTER_HO', 'MASTER_RLF', 'MASTER_SINR', 'MASTER_RSRP', 'MASTER_ToS', 'MASTER_HOPP', 'MASTER_RBs');
            
            raw_sinr_data_all{s, i} = loaded_data.MASTER_RAW_SINR(:);
            sinr_data_all{s, i} = loaded_data.MASTER_SINR(:);
            raw_rsrp_data_all{s, i} = loaded_data.MASTER_RAW_RSRP(:);
            rsrp_data_all{s, i} = loaded_data.MASTER_RSRP(:);
            uho_data_all{s, i} = mean(loaded_data.MASTER_UHO, 1);
            ho_data_all{s, i} = mean(loaded_data.MASTER_HO, 1);
            rlf_data_all{s, i} = sum(loaded_data.MASTER_RLF, 1);
            hopp_data_all{s, i} = mean(loaded_data.MASTER_HOPP, 1);
            rbs_data_all{s, i} = mean(loaded_data.MASTER_RBs, 1);
            
            % Calculate UHO/HO ratio
            uho_ho_ratio_all{s, i} = uho_data_all{s, i} ./ (ho_data_all{s, i} + eps);
            
            % Load ToS data only for the subset strategies
            if ismember(i, subset_indices) && isfield(loaded_data, 'MASTER_ToS')
                sub_tos_data_all{s, i == subset_indices} = loaded_data.MASTER_ToS(:);
            end
            
            % Load ToS data for all strategies
            if isfield(loaded_data, 'MASTER_ToS')
                tos_data_all{s, i} = loaded_data.MASTER_ToS(:);
            end
        else
            warning('File %s does not exist.', data_path);
        end
    end
end

total_rb_per_ue_all = zeros(length(strategies_all), length(scenarios));  % 각 전략과 시나리오별로 단말당 사용된 RB 계산
for s = 1:length(scenarios)
    for i = 1:length(strategies_all)
        ho_data = ho_data_all{s, i};  % 해당 시나리오의 HO 횟수 데이터
        total_rb_per_ue_all(i, s) = sum(ho_data * 10) / UE_num;  % 각 전략에서 단말당 평균 사용된 RB 계산
    end
end

% 각 전략과 시나리오별로 HO당 발생한 HOPP 비율 계산
hopp_per_ho_all = zeros(length(strategies_all), length(scenarios));  % 각 전략과 시나리오별로 HO당 HOPP 발생률 계산
for s = 1:length(scenarios)
    for i = 1:length(strategies_all)
        ho_data = ho_data_all{s, i};  % 해당 시나리오의 HO 횟수 데이터
        hopp_data = hopp_data_all{s, i};  % 해당 시나리오의 HOPP 데이터
        total_ho = sum(ho_data);  % 전체 HO 횟수 계산
        total_hopp = sum(hopp_data);  % 전체 HOPP 횟수 계산
        % HO당 HOPP 비율 계산
        if total_ho > 0
             hopp_per_ho_all(i, s) = (total_hopp / total_ho) * 100;  % HO당 HOPP 비율 (%)로 계산
        else
             hopp_per_ho_all(i, s) = 0;
        end
    end
end

% Load HOPP Data for Each Strategy and Scenario (Re-loading logic kept as per original)
hopp_data_all = cell(length(scenarios), length(strategies_all));
for s = 1:length(scenarios)
    for i = 1:length(strategies_all)
        % Load the MASTER_HOPP data from the existing MAT file
        data_path = fullfile(case_path, [cases, '_MASTER_RESULTS_', strategies_all{i}, '_', scenarios{s}, '.mat']);
        
        % Check if the file exists before attempting to load
        if exist(data_path, 'file') == 2
            loaded_data = load(data_path, 'MASTER_HOPP');
            hopp_data_all{s, i} = mean(loaded_data.MASTER_HOPP, 1);  % 평균 HOPP 값을 저장
        else
            % warning('File %s does not exist.', data_path); % Already warned above
        end
    end
end

% Calculate UHO per HO and HOPP per UHO for both DenseUrban and Rural scenarios
uho_per_ho_all = zeros(length(strategies_all), length(scenarios));  % Initialize UHO per HO
hopp_per_ho_all = zeros(length(strategies_all), length(scenarios));  % Initialize HOPP per UHO

for s = 1:length(scenarios)
    for i = 1:length(strategies_all)
        % UHO per HO 계산
        ho_data = ho_data_all{s, i};  % HO data for the current scenario and strategy
        uho_data = uho_data_all{s, i};  % UHO data
        total_ho = sum(ho_data);  % Total HO count
        total_uho = sum(uho_data);  % Total UHO count
        
        % UHO per HO 비율 계산
        if total_ho > 0  % HO가 존재할 때만 계산
            uho_per_ho_all(i, s) = (total_uho / total_ho) * 100;  % UHO per HO as a percentage
        else
            uho_per_ho_all(i, s) = 0;  % HO가 없으면 0으로 설정
        end
        
        % HOPP per UHO 계산
        total_hopp = sum(hopp_data_all{s, i});  % Total HOPP count
        
        % UHO가 존재할 때만 HOPP per UHO 계산
        if total_uho > 0 && total_hopp > 0  % UHO와 HOPP가 모두 존재할 때만 계산
            hopp_per_ho_all(i, s) = (total_hopp / total_ho) * 100;  % HOPP per UHO as percentage
        else
            hopp_per_ho_all(i, s) = 0;  % UHO 또는 HOPP가 없으면 0으로 설정
        end
        
        % 디버그 정보 출력
        fprintf('Strategy: %s, Scenario: %s, total_ho: %d, total_uho: %d, total_hopp: %d\n', ...
                strategies_all{i}, scenarios{s}, total_ho, total_uho, total_hopp);
    end
end

% 반올림
raw_sinr_data_all = cellfun(@(x) round(x, 3), raw_sinr_data_all, 'UniformOutput', false);
sinr_data_all = cellfun(@(x) round(x, 3), sinr_data_all, 'UniformOutput', false);
raw_rsrp_data_all = cellfun(@(x) round(x, 3), raw_rsrp_data_all, 'UniformOutput', false);
rsrp_data_all = cellfun(@(x) round(x, 3), rsrp_data_all, 'UniformOutput', false);
uho_data_all = cellfun(@(x) round(x, 3), uho_data_all, 'UniformOutput', false);
ho_data_all = cellfun(@(x) round(x, 3), ho_data_all, 'UniformOutput', false);
rlf_data_all = cellfun(@(x) round(x, 3), rlf_data_all, 'UniformOutput', false);
hopp_data_all = cellfun(@(x) round(x, 3), hopp_data_all, 'UniformOutput', false);
uho_ho_ratio_all = cellfun(@(x) round(x, 3), uho_ho_ratio_all, 'UniformOutput', false);
sub_tos_data_all = cellfun(@(x) round(x, 3), sub_tos_data_all, 'UniformOutput', false);
tos_data_all = cellfun(@(x) round(x, 3), tos_data_all, 'UniformOutput', false);
hopp_per_ho_all = round(hopp_per_ho_all, 3);
uho_per_ho_all = round(uho_per_ho_all, 3);

% 각 bar의 색상을 개별 설정 적용하기
% Plot: 초당 단말당 RLF, UHO/HO, HOPP/HO, UHO per HO & HOPP per UHO, SINR Box Plot, SINR CDF, RBs, ToS
% 각 figure의 subplot을 독립적으로 저장하도록 수정

% =========================================================================
% [UPDATED] Calculate Ratios & Comprehensive Logging
% =========================================================================
fprintf('\n================== SIMULATION KPI SUMMARY ==================\n');

% Initialize Arrays
uho_per_ho_all = zeros(length(strategies_all), length(scenarios));
hopp_per_ho_all = zeros(length(strategies_all), length(scenarios));

for s = 1:length(scenarios)
    for i = 1:length(strategies_all)
        % 1. 데이터 추출
        curr_ho_data = ho_data_all{s, i};
        curr_uho_data = uho_data_all{s, i};
        curr_hopp_data = hopp_data_all{s, i};
        curr_rlf_data = rlf_data_all{s, i};
        curr_rbs_data = rbs_data_all{s, i};
        curr_sinr_raw = raw_sinr_data_all{s, i};

        % 2. Total/Average 값 계산
        val_total_ho = sum(curr_ho_data);
        val_total_uho = sum(curr_uho_data);
        val_total_hopp = sum(curr_hopp_data);
        val_total_rlf = sum(curr_rlf_data);
        val_total_rb = sum(curr_rbs_data); % 전체 시뮬레이션 동안 소모된 총 RB (누적)
        val_avg_sinr = mean(curr_sinr_raw); % 전체 SINR 샘플의 평균

        % 3. 비율(Ratio) 계산 (기존 로직 유지)
        if val_total_ho > 0
            uho_per_ho_all(i, s) = (val_total_uho / val_total_ho) * 100;
        else
            uho_per_ho_all(i, s) = 0;
        end

        if val_total_uho > 0 && val_total_hopp > 0
            hopp_per_ho_all(i, s) = (val_total_hopp / val_total_ho) * 100;
        else
            hopp_per_ho_all(i, s) = 0;
        end
        
        % 4. [NEW] 통합 로그 출력 (정렬 적용)
        fprintf('Strategy: %-10s | Scen: %-8s | HO: %5d | UHO: %4d | HOPP: %4d | RLF: %4d | Tot RB: %8.1f | Avg SINR: %6.3f dB\n', ...
            strategies_all{i}, scenarios{s}, ...
            round(val_total_ho), round(val_total_uho), round(val_total_hopp), ...
            round(val_total_rlf), val_total_rb, val_avg_sinr);
    end
end
fprintf('============================================================\n\n');

%% --------------------------------------------------------------------------------------------------------------------
% FIGURE CODE
% RLF, UHO, ToS, RSRP, SINR, RBs, HOPP, SHORTTOS, etc
% --------------------------------------------------------------------------------------------------------------------

%% [SCI MAIN FIGURE] RLF (Rural Only 버전, Set별 색상 적용)
figure('Position', [100, 100, 1000, 800]);

% 📌 평균 RLF 계산 (초당 단말당 RLF 횟수) - Rural만 사용
average_rlf_per_sec = zeros(length(strategies_all), 1);  % 전략 개수만큼 1열
for i = 1:length(strategies_all)
    average_rlf_per_sec(i) = mean(rlf_data_all{1, i});  % Rural
end

% 🎨 Set별 색상 정의 (동적 크기 조정)
full_rural_colors = [
    repmat([0, 0, 0.5], 3, 1);       % Set 1~4: 진한 남색
    repmat([0.5, 0.25, 0], 2, 1);    % Set 5~7: 진한 갈색
    repmat([0.6, 0, 0], 2, 1);    % Set 8: 진한 붉은색
];
% 전략 수에 맞게 색상 자르기 (오류 방지)
rural_colors = full_rural_colors(1:length(strategies_all), :);

% 📊 막대 그래프 (Rural만)
b = bar(average_rlf_per_sec, 'FaceColor', 'flat');
b.CData = rural_colors;

% 🧭 축 및 라벨 설정
set(gca, 'XTick', 1:length(strategies_all), 'XTickLabel', display_names, 'FontSize', 17.5);
ylabel('Average RLF [#operations/UE]', 'FontSize', 17.5);
ylim([0, max(average_rlf_per_sec) + 0.05]);
grid on; grid minor;

% ✅ 막대 위에 수치 표시
xt = get(gca, 'XTick');
for i = 1:length(strategies_all)
    value = average_rlf_per_sec(i);
    text(xt(i), value + 0.013, sprintf('%.2f', value), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 12);
end

% 💾 저장
savefig(fullfile(output_folder, 'compare_rlf_rural_only_coloredBySet.fig'));
saveas(gcf, fullfile(output_folder, 'compare_rlf_rural_only_coloredBySet.png'));

% %% [SCI MAIN FIGURE] UHO/HO (Rural Only + Set별 색상 적용)
% figure('Position', [100, 100, 1000, 800]);
% 
% % 🌾 Rural 데이터만 추출
% uho_per_ho_rural = uho_per_ho_all(:, 1);  % Rural만 사용 (col 1)
% 
% % 🎨 Set별 색상 정의 (위에서 정의한 rural_colors 재사용)
% % rural_colors 는 이미 사이즈 조정됨
% 
% % 📊 막대 그래프
% b = bar(uho_per_ho_rural, 'FaceColor', 'flat');
% b.CData = rural_colors;
% 
% % 🧭 축 및 라벨 설정
% set(gca, 'XTick', 1:length(strategies_all), ...
%          'XTickLabel', display_names, ...
%          'FontSize', 17.5);
% ylabel('UHO/HO ratio (%)', 'FontSize', 17.5);
% ylim([0, max(uho_per_ho_rural) + 5]);
% grid on; grid minor;
% 
% % ✅ 막대 위에 수치 표기
% xt = get(gca, 'XTick');
% for i = 1:length(strategies_all)
%     value = uho_per_ho_rural(i);
%     x = xt(i);  % 단일 막대 중심
%     y = value + 0.5;
%     text(x, y, sprintf('%d', round(value)), ...
%         'HorizontalAlignment', 'center', ...
%         'FontSize', 13);
% end
% 
% % 💾 저장
% savefig(fullfile(output_folder, 'compare_uho_per_ho_rural_only_coloredBySet.fig'));
% saveas(gcf, fullfile(output_folder, 'compare_uho_per_ho_rural_only_coloredBySet.png'));

% %% [SCI MAIN FIGURE] HOPP/HO (Rural Only + Set별 색상 적용)
% figure('Position', [100, 100, 1000, 800]);
% 
% % 🌾 Rural 데이터만 추출
% hopp_per_ho_rural = hopp_per_ho_all(:, 1);  % Rural만 사용 (col 1)
% 
% % 📊 막대 그래프
% b = bar(hopp_per_ho_rural, 'FaceColor', 'flat');
% b.CData = rural_colors;
% 
% % 🧭 축 및 라벨 설정
% set(gca, 'XTick', 1:length(strategies_all), ...
%          'XTickLabel', display_names, ...
%          'FontSize', 17.5);
% ylabel('PP/HO ratio (%)', 'FontSize', 17.5);
% ylim([0, max(hopp_per_ho_rural) + 5]);
% grid on; grid minor;
% 
% % ✅ 막대 위에 수치 표기
% xt = get(gca, 'XTick');
% for i = 1:length(strategies_all)
%     value = hopp_per_ho_rural(i);
%     x = xt(i);
%     y = value + 0.5;
%     text(x, y, sprintf('%d', round(value)), ...
%         'HorizontalAlignment', 'center', ...
%         'FontSize', 13);
% end
% 
% % 💾 저장
% savefig(fullfile(output_folder, 'compare_hopp_per_ho_rural_only_coloredBySet.fig'));
% saveas(gcf, fullfile(output_folder, 'compare_hopp_per_ho_rural_only_coloredBySet.png'));

% %% [SCI MAIN FIGURE] Combined UHO & HOPP (Rural Only, Dual Y-Axis)
% figure('Position', [180, 180, 1080, 880]);
% 
% % 🌾 Rural 데이터만 추출
% uho_rural = uho_per_ho_all(:, 1);    % UHO/HO (%)
% hopp_rural = hopp_per_ho_all(:, 1);  % HOPP/HO (%)
% 
% % 🎨 색상 정의 (UHO: 진한색, HOPP: 연한색)
% uho_colors = rural_colors; % 이미 사이즈 조정됨
% hopp_colors = uho_colors * 0.6 + 0.4;  % 동일한 계열의 연한 색상
% 
% % 🧱 막대 폭과 간격 설정
% bar_width = 0.4;
% 
% % 🎨 UHO - 왼쪽 y축
% yyaxis left;
% b1 = bar((1:length(uho_rural)) - bar_width/2, uho_rural, bar_width, 'FaceColor', 'flat');
% b1.CData = uho_colors;
% ylabel('UHO/HO ratio (%)', 'FontSize', 17.5);
% ylim([0, 16]);
% 
% % 🎨 HOPP - 오른쪽 y축
% yyaxis right;
% b2 = bar((1:length(hopp_rural)) + bar_width/2, hopp_rural, bar_width, 'FaceColor', 'flat');
% b2.CData = hopp_colors;
% ylabel('HOPP/HO ratio (%)', 'FontSize', 17.5);
% ylim([0, 16]);
% 
% % 🧭 공통 x축
% set(gca, 'XTick', 1:length(strategies_all), ...
%          'XTickLabel', display_names, ...
%          'FontSize', 17.5);
% xtickangle(0);
% grid on; grid minor;
% 
% % ✅ 수치 표기 (UHO - 왼쪽)
% yyaxis left;
% xt = get(gca, 'XTick');
% for i = 1:length(uho_rural)
%     x = xt(i) - bar_width/2;
%     y = uho_rural(i) + 0.5;
%     text(x, y, sprintf('%d', round(uho_rural(i))), ...
%         'HorizontalAlignment', 'center', 'FontSize', 13);
% end
% 
% % ✅ 수치 표기 (HOPP - 오른쪽)
% yyaxis right;
% for i = 1:length(hopp_rural)
%     x = xt(i) + bar_width/2;
%     y = hopp_rural(i) + 0.5;
%     text(x, y, sprintf('%d', round(hopp_rural(i))), ...
%         'HorizontalAlignment', 'center', 'FontSize', 13);
% end
% 
% % 💾 저장
% savefig(fullfile(output_folder, 'compare_uho_hopp_per_ho_rural_combined_dualy.fig'));
% saveas(gcf, fullfile(output_folder, 'compare_uho_hopp_per_ho_rural_combined_dualy.png'));

%% --------------------------------------------------------------------------------------------------------------------
%% [SCI MAIN FIGURE] Average SINR (Rural Only + Set별 색상 적용)
figure('Position', [100, 100, 1000, 850]);

% 데이터 준비
sinr_data_per_strategy_rural = [];
group_rural = [];
for i = 1:length(display_names)
    current_data = round(sinr_data_all{1, i}, 3);  % 소수점 3자리 반올림
    sinr_data_per_strategy_rural = [sinr_data_per_strategy_rural; current_data];  
    group_rural = [group_rural; i * ones(length(current_data), 1)];
end

% boxplot 그리기
boxplot(sinr_data_per_strategy_rural, group_rural, 'Labels', display_names, 'Colors', 'k');

% Box 색상 덮어씌우기
h = findobj(gca, 'Tag', 'Box');
% h는 역순으로 반환될 수 있으므로 주의
for j = 1:length(h)
    % h의 인덱스와 strategies의 인덱스 매핑 (역순 처리)
    idx = length(h) - j + 1;
    if idx <= size(rural_colors, 1)
        patch(get(h(j), 'XData'), get(h(j), 'YData'), rural_colors(idx,:), 'FaceAlpha', 0.3);
    end
    % 중앙값 선을 검정색으로 진하게 설정
    h_median = findobj(gca, 'Tag', 'Median');
    set(h_median, 'Color', 'k', 'LineWidth', 1.8);  % 중앙값 선 두껍게
end

% 라벨 설정
ylabel('Average DL SINR [dB]', 'FontSize', 17.5);
set(gca, 'XTickLabel', display_names, 'FontSize', 17.5);
grid on;
grid minor;

% 저장
savefig(fullfile(output_folder, 'results_DLSINR_box_rural_coloredBySet.fig'));
saveas(gcf, fullfile(output_folder, 'results_DLSINR_box_rural_coloredBySet.png'));




%% AVERAGE SINR - new 바이올린 플롯으로 유력한 MAIN
figure('Position', [70, 70, 930, 730]);
hold on;

% 색상 정의 (위에서 만든 box_colors 사용)
% box_colors = box_colors(1:length(strategies_all), :);

% 평균/중앙값 마커 저장용
mean_handles = gobjects(1,1);
median_handles = gobjects(1,1);

for i = 1:length(display_names)
    y_data = round(sinr_data_all{1, i}, 3);

    % 분포 곡선
    [f, xi] = ksdensity(y_data);
    f = f / max(f) * 0.3;  % 정규화 후 너비 조절
    fill([i - f, fliplr(i + f)], [xi, fliplr(xi)], rural_colors(i, :), ...
        'FaceAlpha', 0.35, 'EdgeColor', 'none');

    % 중앙값 (점선)
    median_val = median(y_data);
    median_handles = plot([i - 0.2, i + 0.2], [median_val, median_val], ...
        'k:', 'LineWidth', 2.0);  % 점선으로 표기

    % 평균 (빈 원)
    mean_val = mean(y_data);
    mean_handles = plot(i, mean_val, 'ko', 'MarkerSize', 7, 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
end

xlim([0.5, length(display_names) + 0.5]);
ylim([-4.8, -0.7]);
xticks(1:length(display_names));
xticklabels(display_names);
ylabel('Average DL SINR [dB]', 'FontSize', 17.5);
set(gca, 'FontSize', 15);
grid on; grid minor;

% 범례 추가
legend([median_handles, mean_handles], {'Median value', 'Mean value'}, ...
    'Location', 'southwest', 'FontSize', 13);

% 저장
savefig(fullfile(output_folder, 'results_DLSINR_violin_median_mean_rural_legend.fig'));
saveas(gcf, fullfile(output_folder, 'results_DLSINR_violin_median_mean_rural_legend.png'));

% %% AVERAGE SINR - new 바이올린 플롯으로 유력한 MAIN (오류 수정됨)
% figure('Position', [70, 70, 930, 730]);
% hold on;
% 
% % 색상 정의 (기존 box_colors 사용, 없으면 위에서 정의된 것 사용)
% % box_colors = box_colors(1:length(strategies_all), :); 
% 
% mean_handles = gobjects(1,1);
% median_handles = gobjects(1,1);
% 
% for i = 1:length(display_names)
%     y_data = round(sinr_data_all{1, i}, 3);
% 
%     if isempty(y_data)
%         continue;
%     end
% 
%     % --- [오류 수정 핵심 파트] ---
%     min_val = min(y_data);
%     max_val = max(y_data);
% 
%     % 만약 모든 데이터가 똑같다면(분산 0), 강제로 아주 작은 폭을 만들어줌
%     if max_val == min_val
%         max_val = max_val + 1e-4;
%         min_val = min_val - 1e-4;
%     end
% 
%     % Support 범위에 아주 미세한 여유(buffer)를 줌 (부동소수점 오류 방지)
%     buffer = 1e-4; 
%     support_range = [min_val - buffer, max_val + buffer];
%     % ---------------------------
% 
%     % ksdensity 실행 (Support 범위 수정됨)
%     try
%         [f, xi] = ksdensity(y_data, 'Support', support_range, 'BoundaryCorrection', 'reflection');
%     catch
%         % 만약 그래도 에러가 나면(데이터가 너무 적은 경우 등), 일반 정규분포 근사 시도 혹은 건너뜀
%         warning('Strategy %d: ksdensity failed, trying default bandwidth.', i);
%         [f, xi] = ksdensity(y_data); 
%     end
% 
%     % 너비 정규화 (그래프 모양 예쁘게)
%     scale_factor = 0.4; 
%     if max(f) > 0
%         f = f / max(f) * scale_factor; 
%     end
% 
%     % 바이올린 그리기
%     fill([i - f, fliplr(i + f)], [xi, fliplr(xi)], box_colors(i, :), ...
%         'FaceAlpha', 0.4, 'EdgeColor', 'none'); 
% 
%     % 중앙값 (점선)
%     median_val = median(y_data);
%     median_handles = plot([i - 0.15, i + 0.15], [median_val, median_val], ...
%         'k:', 'LineWidth', 2.0); 
% 
%     % 평균 (빈 원)
%     mean_val = mean(y_data);
%     mean_handles = plot(i, mean_val, 'ko', 'MarkerSize', 6, 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
% end
% 
% xlim([0.5, length(display_names) + 0.5]);
% % ylim 자동 조정 (필요시 주석 해제하여 수동 설정)
% % ylim([-5.5, 0.5]); 
% 
% xticks(1:length(display_names));
% xticklabels(display_names);
% ylabel('Average DL SINR [dB]', 'FontSize', 17.5);
% set(gca, 'FontSize', 15);
% grid on; grid minor;
% 
% % 범례 추가
% legend([median_handles, mean_handles], {'Median value', 'Mean value'}, ...
%     'Location', 'southwest', 'FontSize', 13);
% 
% % 저장
% savefig(fullfile(output_folder, 'results_DLSINR_violin_corrected.fig'));
% saveas(gcf, fullfile(output_folder, 'results_DLSINR_violin_corrected.png'));

% %% AVG SINR CUSTOM HISTOGRAM
% figure('Position', [100, 100, 1000, 850]);
% hold on;
% 
% for i = 1:length(display_names)
%     y_data = sinr_data_all{1, i};
%     x_jitter = (rand(size(y_data)) - 0.5) * 0.6;  % x축 jitter 추가
%     x_pos = i + x_jitter;
% 
%     % 점 분포 (색상 적용)
%     scatter(x_pos, y_data, 10, ...
%         'MarkerEdgeAlpha', 0.3, ...
%         'MarkerFaceAlpha', 0.3, ...
%         'MarkerFaceColor', box_colors(i,:), ...
%         'MarkerEdgeColor', box_colors(i,:));
% 
%     % 중앙값 점선
%     median_val = median(y_data);
%     plot([i - 0.25, i + 0.25], [median_val, median_val], ...
%         'Color', [0.4 0.4 0.4], 'LineStyle', '--', 'LineWidth', 1.8);
% 
%     % 평균값 빈 원 마커
%     mean_val = mean(y_data);
%     plot(i, mean_val, 'ko', 'MarkerSize', 7, 'LineWidth', 1.6);  % 빈 원
% end
% 
% % 라벨 및 축 설정
% set(gca, 'XTick', 1:length(display_names), 'XTickLabel', display_names, 'FontSize', 17.5);
% ylabel('Average DL SINR [dB]', 'FontSize', 17.5);
% ylim([-4.5, -0.3]);
% grid on; grid minor;
% title('DL SINR Distribution per Strategy (Rural)', 'FontSize', 18);
% 
% % 🔍 범례 추가 (중앙값과 평균 구분)
% h_median = plot(NaN, NaN, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.8);  % 중앙값 점선
% h_mean = plot(NaN, NaN, 'ko', 'MarkerSize', 7, 'LineWidth', 1.6);          % 평균 빈 원
% legend([h_median, h_mean], {'Median', 'Mean'}, 'FontSize', 14, 'Location', 'southwest');
% 
% % 저장
% savefig(fullfile(output_folder, 'results_DLSINR_distribution_strip_rural.fig'));
% saveas(gcf, fullfile(output_folder, 'results_DLSINR_distribution_strip_rural.png'));

% %% SINR CDF plot
% figure('Position', [100, 100, 1000, 850]);
% hold on;
% for i = 1:length(strategies_all)
%     sinr_data = raw_sinr_data_all{1, i};
%     if ~isempty(sinr_data) && isvector(sinr_data)
%         sinr_data_rounded = round(sinr_data, 3);  % SINR 데이터 소수점 3자리 반올림
%         [cdf_sinr, x_sinr] = ecdf(sinr_data_rounded);
%         plot(x_sinr, cdf_sinr, 'Color', colors_all{i}, 'LineStyle', lineStyles_all{i}, 'LineWidth', 1.5, ...
%             'DisplayName', display_names{i});
%     else
%         warning('SINR data for strategy %s in DenseUrban is either empty or not valid.', strategies_all{i});
%     end
% end
% hold off;
% xlabel('DL SINR [dB]', 'FontSize', 17.5);
% ylabel('Cumulative distribution function', 'FontSize', 17.5);
% legend_handle = legend('Location', 'northwest');
% set(legend_handle, 'FontSize', 17.5);  % legend의 글씨 크기 설정
% xlim([-10 5]);
% ylim([0 1]);
% yticks(0:0.1:1);
% grid on;
% grid minor;
% 
% % 결과를 fig와 png로 저장
% savefig(fullfile(output_folder, 'results_DLSINR_cdf.fig'));  % fig 저장
% saveas(gcf, fullfile(output_folder, 'results_DLSINR_cdf.png'));  % png 저장

% %% SINR FIGURE _ AVERAGE SINR FIGURE BAR FIGURE (수정된 부분: 시나리오 개수 체크)
% % ===== SINR 평균값 비교 Bar Plot =====
% % 중요: 시나리오가 2개 미만이면 이 그래프를 생성할 수 없습니다.
% 
% if length(scenarios) >= 2
%     figure('Position', [100, 100, 1000, 800]);
%     average_sinr = zeros(length(strategies_all), 2);  % 전략별 x 환경별 (DenseUrban=1, Rural=2)
% 
%     for s = 1:2  % 1: DenseUrban, 2: Rural (or 1:first, 2:second)
%         for i = 1:length(strategies_all)
%             sinr_data = sinr_data_all{s, i};
%             if ~isempty(sinr_data)
%                 average_sinr(i, s) = round(mean(sinr_data), 2);  % 평균값 소수점 2자리
%             end
%         end
%     end
% 
%     b = bar(average_sinr, 'grouped');
%     b(1).FaceColor = [0.7, 0.7, 0.7];  % Scenario 1 (e.g., Rural/Urban)
%     b(2).FaceColor = [0, 0, 0.5];      % Scenario 2
% 
%     set(gca, 'XTick', 1:length(strategies_all), ...
%              'XTickLabel', display_names, ...
%              'FontSize', 17.5);
%     ylabel('Average DL SINR [dB]', 'FontSize', 17.5);
%     legend(scenarios, 'Location', 'northeast'); % 시나리오 이름 자동 사용
%     ylim([min(average_sinr(:)) - 1, max(average_sinr(:)) + 1]);
%     grid on; grid minor;
% 
%     % 수치 표기 (막대 위 텍스트)
%     xt = get(gca, 'XTick');
%     for i = 1:length(strategies_all)
%         for j = 1:2
%             value = average_sinr(i, j);
%             x = xt(i) + (j - 1.5) * 0.28;  % 위치 조정
%             y = value - 0.05;
%             text(x, y, sprintf('%.1f', value), ...
%                 'HorizontalAlignment', 'center', ...
%                 'FontSize', 13);
%         end
%     end
% 
%     % 저장
%     savefig(fullfile(output_folder, 'compare_avg_sinr_rural_vs_urban.fig'));
%     saveas(gcf, fullfile(output_folder, 'compare_avg_sinr_rural_vs_urban.png'));
% else
%     warning('Less than 2 scenarios loaded. Skipping "Urban vs Rural" SINR comparison plot.');
% end

% %% [NEED FIX -- SCI MAIN FIGURE] SINR FIGURE _ CDF LOW *log term
% % 이 부분도 시나리오 2개를 가정하고 있으므로 조건부 실행합니다.
% if length(scenarios) >= 2
%     figure('Position', [100, 100, 1200, 800]);
%     hold on;
%     num_sets = length(strategies_all);
%     base_colors = lines(num_sets);  % 기본 컬러맵
%     adjusted_colors = base_colors * 0.85;  % 채도 낮추기
% 
%     for i = 1:num_sets
%         % First Scenario (s = 1)
%         sinr_data_urban = raw_sinr_data_all{1, i};
%         if ~isempty(sinr_data_urban)
%             [f_urban, x_urban] = ecdf(sinr_data_urban);
%             semilogy(x_urban, f_urban, '-', ...
%                 'LineWidth', 1.6, ...
%                 'Color', adjusted_colors(i, :), ...
%                 'DisplayName', sprintf('Set %d - %s', i, scenarios{1}));
%         end
% 
%         % Second Scenario (s = 2)
%         sinr_data_rural = raw_sinr_data_all{2, i};
%         if ~isempty(sinr_data_rural)
%             [f_rural, x_rural] = ecdf(sinr_data_rural);
%             semilogy(x_rural, f_rural, '--', ...
%                 'LineWidth', 1.6, ...
%                 'Color', adjusted_colors(i, :), ...
%                 'DisplayName', sprintf('Set %d - %s', i, scenarios{2}));
%         end
%     end
% 
%     % 축 설정
%     xlabel('DL SINR [dB]', 'FontSize', 17.5);
%     ylabel('CDF', 'FontSize', 17.5);
%     set(gca, 'YScale', 'log');  % 로그 스케일
%     xlim([-10, 0]);
%     ylim([1e-2, 1]);
%     legend('Location', 'southeast', 'FontSize', 12);
%     grid on;
%     grid minor;
% 
%     % 저장
%     savefig(fullfile(output_folder, 'results_DLSINR_logCDF_rural_vs_urban.fig'));
%     saveas(gcf, fullfile(output_folder, 'results_DLSINR_logCDF_rural_vs_urban.png'));
% else
%     % 단일 시나리오용 Log CDF
%      figure('Position', [100, 100, 1200, 800]);
%     hold on;
%     num_sets = length(strategies_all);
%     base_colors = lines(num_sets);
%     adjusted_colors = base_colors * 0.85;
% 
%     for i = 1:num_sets
%         % Single Scenario (s = 1)
%         sinr_data_rural = raw_sinr_data_all{1, i};
%         if ~isempty(sinr_data_rural)
%             [f_rural, x_rural] = ecdf(sinr_data_rural);
%             semilogy(x_rural, f_rural, '-', ...
%                 'LineWidth', 1.6, ...
%                 'Color', adjusted_colors(i, :), ...
%                 'DisplayName', sprintf('Set %d - %s', i, scenarios{1}));
%         end
%     end
%      % 축 설정
%     xlabel('DL SINR [dB]', 'FontSize', 17.5);
%     ylabel('CDF', 'FontSize', 17.5);
%     set(gca, 'YScale', 'log');  % 로그 스케일
%     xlim([-10, 0]);
%     ylim([1e-2, 1]);
%     legend('Location', 'southeast', 'FontSize', 12);
%     grid on;
%     grid minor;
% 
%     % 저장 (단일)
%     savefig(fullfile(output_folder, 'results_DLSINR_logCDF_single.fig'));
%     saveas(gcf, fullfile(output_folder, 'results_DLSINR_logCDF_single.png'));
% end

% %% RSRP plot
% % RSRP Box plot
% figure('Position', [100, 100, 1000, 850]);
% rsrp_data_per_strategy = [];
% group_rsrp = [];
% for i = 1:length(display_names)
%     current_data = round(rsrp_data_all{1, i}, 3);  % 소수점 3자리 반올림
%     rsrp_data_per_strategy = [rsrp_data_per_strategy; current_data];  
%     group_rsrp = [group_rsrp; i * ones(length(current_data), 1)]; 
% end
% 
% boxplot(rsrp_data_per_strategy, group_rsrp, 'Labels', display_names);
% ylabel('Average DL RSRP [dBm]', 'FontSize', 17.5);
% set(gca, 'XTickLabel', display_names, 'FontSize', 17.5);  % X축 FontSize 설정
% grid on;
% grid minor;
% 
% % 결과를 fig와 png로 저장
% savefig(fullfile(output_folder, 'results_DLRSPR_box.fig'));  % fig 저장
% saveas(gcf, fullfile(output_folder, 'results_DLRSPR_box.png'));  % png 저장
% 
% % RSRP CDF plot
% figure('Position', [100, 100, 1000, 850]);
% hold on;
% for i = 1:length(strategies_all)
%     rsrp_data = raw_rsrp_data_all{1, i};
%     if ~isempty(rsrp_data) && isvector(rsrp_data)
%         rsrp_data_rounded = round(rsrp_data, 3);  % RSRP 데이터 소수점 3자리 반올림
%         [cdf_rsrp, x_rsrp] = ecdf(rsrp_data_rounded);
%         plot(x_rsrp, cdf_rsrp, 'Color', colors_all{i}, 'LineStyle', lineStyles_all{i}, 'LineWidth', 1.5, ...
%             'DisplayName', display_names{i});
%     else
%         warning('RSRP data for strategy %s in DenseUrban is either empty or not valid.', strategies_all{i});
%     end
% end
% hold off;
% xlabel('DL RSRP [dBm]', 'FontSize', 17.5);
% ylabel('Cumulative distribution function', 'FontSize', 17.5);
% legend_handle = legend('Location', 'northwest');
% set(legend_handle, 'FontSize', 17.5);  % legend의 글씨 크기 설정
% grid on;
% grid minor;
% 
% % 결과를 fig와 png로 저장
% savefig(fullfile(output_folder, 'results_DLRSPR_cdf.fig'));  % fig 저장
% saveas(gcf, fullfile(output_folder, 'results_DLRSPR_cdf.png'));  % png 저장

% %% RSRP/SINR 시간축 기준 변화 그래프
% % RSRP xy 그래프 (시간 vs 평균 RSRP : 전체 전략 한번에 Plot)
% figure('Position', [100, 100, 1000, 850]);
% hold on;
% for i = 1:length(strategies_all)
%     rsrp_raw_data = raw_rsrp_data_all{1, i}; % 해당 전략의 RSRP 데이터
% 
%     if ~isempty(rsrp_raw_data)
%         [rows, cols] = size(rsrp_raw_data); % 현재 데이터 크기 확인
%         if rows == expected_samples * UE_num && cols == 1
%             % 데이터를 115 x UE_num 형태로 변환
%             rsrp_raw_data = reshape(rsrp_raw_data, expected_samples, UE_num);
%         end
% 
%         if size(rsrp_raw_data, 1) == expected_samples && size(rsrp_raw_data, 2) == UE_num
%             rsrp_mean = mean(rsrp_raw_data, 2);  % 열 방향 평균 (115x1)
%             % xy 그래프 플롯
%             plot(TIMEVECTOR, rsrp_mean, 'Color', colors_all{i}, 'LineStyle', lineStyles_all{i}, ...
%                 'LineWidth', 1.5, 'DisplayName', display_names{i});
%         else
%             warning('RSRP data size mismatch for strategy %s. Expected (%dx%d), but got (%dx%d).', ...
%                 strategies_all{i}, expected_samples, UE_num, size(rsrp_raw_data, 1), size(rsrp_raw_data, 2));
%         end
%     else
%         warning('RSRP data for strategy %s in DenseUrban is empty.', strategies_all{i});
%     end
% end
% hold off;
% xlabel('Time (s)', 'FontSize', 17.5);
% ylabel('Average DL RSRP [dBm]', 'FontSize', 17.5);
% legend_handle = legend('Location', 'best');
% set(legend_handle, 'FontSize', 17.5);  % legend 글씨 크기 설정
% grid on;
% grid minor;
% 
% % 결과 저장
% savefig(fullfile(output_folder, 'results_DLRSPR_time.fig'));  % fig 저장
% saveas(gcf, fullfile(output_folder, 'results_DLRSPR_time.png'));  % png 저장
% 
% % RSRP xy 그래프 - 각 전략별 subplot
% figure('Position', [100, 100, 1200, 1000]); % 전체 figure 크기 설정
% num_strategies = length(strategies_all); % 총 전략 개수
% num_rows = ceil(sqrt(num_strategies)); % 서브플롯 행 개수
% num_cols = ceil(num_strategies / num_rows); % 서브플롯 열 개수
% 
% for i = 1:num_strategies
%     rsrp_raw_data = raw_rsrp_data_all{1, i}; % 해당 전략의 RSRP 데이터
% 
%     subplot(num_rows, num_cols, i); % 서브플롯 배치
%     hold on;
% 
%     if ~isempty(rsrp_raw_data)
%         [rows, cols] = size(rsrp_raw_data);
%         if rows == expected_samples * UE_num && cols == 1
%             rsrp_raw_data = reshape(rsrp_raw_data, expected_samples, UE_num);
%         end
% 
%         if size(rsrp_raw_data, 1) == expected_samples && size(rsrp_raw_data, 2) == UE_num
%             rsrp_mean = mean(rsrp_raw_data, 2);
%             plot(TIMEVECTOR, rsrp_mean, 'Color', colors_all{i}, 'LineStyle', lineStyles_all{i}, ...
%                 'LineWidth', 1.5, 'DisplayName', display_names{i});
%             title(display_names{i}, 'FontSize', 12);
%         end
%     end
% 
%     xlabel('Time (s)', 'FontSize', 10);
%     ylabel('Avg DL RSRP [dBm]', 'FontSize', 10);
%     ylim([-109 -105]);
%     grid on;
%     grid minor;
%     hold off;
% end
% sgtitle('RSRP Time Evolution for Each Strategy', 'FontSize', 15);
% savefig(fullfile(output_folder, 'results_DLRSPR_time_subplot.fig'));
% saveas(gcf, fullfile(output_folder, 'results_DLRSPR_time_subplot.png'));

% %% SINR xy 그래프 (시간 vs 평균 SINR : 전체 전략 한번에 Plot)
% figure('Position', [100, 100, 1000, 850]);
% hold on;
% for i = 1:length(strategies_all)
%     sinr_raw_data = raw_sinr_data_all{1, i}; % 해당 전략의 SINR 데이터
% 
%     if ~isempty(sinr_raw_data)
%         [rows, cols] = size(sinr_raw_data); 
%         if rows == expected_samples * UE_num && cols == 1
%             sinr_raw_data = reshape(sinr_raw_data, expected_samples, UE_num);
%         end
% 
%         if size(sinr_raw_data, 1) == expected_samples && size(sinr_raw_data, 2) == UE_num
%             sinr_mean = mean(sinr_raw_data, 2);
%             plot(TIMEVECTOR, sinr_mean, 'Color', colors_all{i}, 'LineStyle', lineStyles_all{i}, ...
%                 'LineWidth', 1.5, 'DisplayName', display_names{i});
%         end
%     end
% end
% hold off;
% xlabel('Time (s)', 'FontSize', 17.5);
% ylabel('Average DL SINR [dB]', 'FontSize', 17.5);
% legend_handle = legend('Location', 'best');
% set(legend_handle, 'FontSize', 17.5);
% grid on;
% grid minor;
% savefig(fullfile(output_folder, 'results_DLSINR_time.fig'));
% saveas(gcf, fullfile(output_folder, 'results_DLSINR_time.png'));
% 
% % SINR xy 그래프 - 각 전략별 subplot
% figure('Position', [100, 100, 1200, 1000]);
% num_strategies = length(strategies_all);
% num_rows = ceil(sqrt(num_strategies));
% num_cols = ceil(num_strategies / num_rows);
% 
% for i = 1:num_strategies
%     sinr_raw_data = raw_sinr_data_all{1, i};
%     subplot(num_rows, num_cols, i);
%     hold on;
% 
%     if ~isempty(sinr_raw_data)
%         [rows, cols] = size(sinr_raw_data);
%         if rows == expected_samples * UE_num && cols == 1
%             sinr_raw_data = reshape(sinr_raw_data, expected_samples, UE_num);
%         end
% 
%         if size(sinr_raw_data, 1) == expected_samples && size(sinr_raw_data, 2) == UE_num
%             sinr_mean = mean(sinr_raw_data, 2);
%             plot(TIMEVECTOR, sinr_mean, 'Color', colors_all{i}, 'LineStyle', lineStyles_all{i}, ...
%                 'LineWidth', 1.5, 'DisplayName', display_names{i});
%             title(display_names{i}, 'FontSize', 12);
%         end
%     end
% 
%     xlabel('Time (s)', 'FontSize', 10);
%     ylabel('Avg DL SINR [dB]', 'FontSize', 10);
%     ylim([-6 2]);
%     grid on;
%     grid minor;
%     hold off;
% end
% sgtitle('SINR Time Evolution for Each Strategy', 'FontSize', 15);
% savefig(fullfile(output_folder, 'results_DLSINR_time_subplot.fig'));
% saveas(gcf, fullfile(output_folder, 'results_DLSINR_time_subplot.png'));

%% [SCI MAIN FIGURE] Average RBs (Rural Only + Set별 색상)
figure('Position', [100, 100, 1000, 800]);

% 📌 Rural만 평균 계산
mean_rbs_per_rural = zeros(length(strategies_all), 1);
for i = 1:length(strategies_all)
    avg_hos_times = mean(ho_data_all{1, i}) / TOTAL_TIME;  % 1: Rural
    avg_rbs_times =  mean(rbs_data_all{1, i})/TOTAL_TIME;
    avg_hos_times2 = mean(ho_data_all{1, i});  % 1: Rural
    avg_rbs_times2 =  mean(rbs_data_all{1, i});
    mean_rbs_per_rural(i) = round(avg_hos_times, 2);  % 평균 RBs 사용량 (소수점 2자리)
end

% 🎨 Set별 색상 정의 (재사용)
% rural_colors 이미 사이즈 조정됨

% 📊 막대 그래프
b = bar(mean_rbs_per_rural, 'FaceColor', 'flat');
b.CData = rural_colors;

% 🧭 축 설정
ylabel('RBs usage [#/UE/sec]', 'FontSize', 17.5);
set(gca, 'XTick', 1:length(strategies_all), ...
         'XTickLabel', display_names, ...
         'FontSize', 17.5);
ylim([0, max(mean_rbs_per_rural) + 0.2]);
grid on;
grid minor;

% ✅ 수치 표기
xt = get(gca, 'XTick');
for i = 1:length(strategies_all)
    value = mean_rbs_per_rural(i);
    x = xt(i);
    y = value + 0.01;
    text(x, y, sprintf('%.2f', value), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 13);
end

% 💾 저장
savefig(fullfile(output_folder, 'compare_avgRBs_rural_only_coloredBySet.fig'));
saveas(gcf, fullfile(output_folder, 'compare_avgRBs_rural_only_coloredBySet.png'));

%% [SCI MAIN FIGURE - SAFE VERSION] Wasted vs Effective RB Usage
figure('Position', [100, 100, 1000, 800]);

% 1. 시그널링 비용 정의 (Based on Table II in Manuscript)
% HO Cost = NMR(1) + Cmd(2) + RA(6) + Cnf(1) = 10
COST_HO = 10;
% RLF Cost = Re-est Request(1) + Re-est(2) + RA(6) + Complete(1) approx = 10
% (RLF 복구도 최소한 HO만큼의 자원이 든다고 보수적으로 가정)
COST_RLF = 10;       

% 2. 데이터 계산 (Rural Only)
eff_rb_usage = zeros(length(strategies_all), 1);   % 유효한 RB (Valid HO)
wasted_rb_usage = zeros(length(strategies_all), 1); % 낭비된 RB (UHO + RLF)

for i = 1:length(strategies_all)
    % 데이터 로드 (Rural = 1)
    ho_val = ho_data_all{1, i};    % 총 핸드오버 횟수
    uho_val = uho_data_all{1, i};  % 불필요 핸드오버(UHO) 횟수
    rlf_val = rlf_data_all{1, i};  % RLF 횟수
    
    % 평균 횟수 계산
    avg_ho = mean(ho_val);
    avg_uho = mean(uho_val);
    avg_rlf = mean(rlf_val);
    
    % [낭비된 비용] = (UHO * 10) + (RLF * 10)
    % 논리: UHO는 안 해도 될 HO를 한 것이므로 낭비.
    %       RLF는 연결이 끊겨서 '복구'하느라 쓴 비용이므로, 
    %       HO 1회 분량의 자원을 소모했다고 가정(보수적 접근).
    waste_cost_total = (avg_uho * COST_HO) + (avg_rlf * COST_RLF);
    
    % [전체 비용] = (Total HO * 10) + (RLF * 10)
    % 주의: 시뮬레이션 HO Count에 RLF 복구 시도가 포함되지 않았다면 더해줘야 함.
    % 보통 RLF 후 재연결은 별도 이벤트이므로 더하는 게 맞음.
    total_cost_total = (avg_ho * COST_HO) + (avg_rlf * COST_RLF);
    
    % [유효 비용] = 전체 - 낭비
    % 즉, (Total HO - UHO) * 10
    % RLF로 인한 비용은 전액 '낭비(Waste)'로 간주 (끊기지 말았어야 하므로)
    effective_cost_total = total_cost_total - waste_cost_total;
    
    % 초당 단말당 RB Usage로 변환
    wasted_rb_usage(i) = waste_cost_total / TOTAL_TIME; 
    eff_rb_usage(i) = effective_cost_total / TOTAL_TIME;
end

% 3. Stacked Bar 그리기
rb_stacked = [eff_rb_usage, wasted_rb_usage];
b = bar(rb_stacked, 'stacked');

% 🎨 색상 설정
b(1).FaceColor = [0, 0.447, 0.741];  % 파란색: Effective
b(2).FaceColor = [0.85, 0.325, 0.098]; % 주황색: Wasted (Redundant)

% 🧭 축 설정
set(gca, 'XTick', 1:length(strategies_all), ...
         'XTickLabel', display_names, ...
         'FontSize', 17.5);
ylabel('RB usage overhead [#/UE/sec]', 'FontSize', 17.5);
ylim([0, max(sum(rb_stacked, 2)) * 1.3]); % 범례 공간 확보
grid on; grid minor;

% 📝 수치 표기
xt = get(gca, 'XTick');
totals = sum(rb_stacked, 2);
for i = 1:length(strategies_all)
    text(xt(i), totals(i) + 0.01, sprintf('%.2f', totals(i)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 13, 'FontWeight', 'bold');
end

% 🏷️ 범례 수정
legend({'Effective Signaling (Valid HO)', 'Redundant Signaling (UHO + RLF Recovery)'}, ...
       'Location', 'northeast', 'FontSize', 14);

% 💾 저장
savefig(fullfile(output_folder, 'compare_RBs_stacked_conservative.fig'));
saveas(gcf, fullfile(output_folder, 'compare_RBs_stacked_conservative.png'));

% %% [SCI MAIN FIGURE] TOS FIGURE - CDF 0 to 1 TERM DENSEURBAN AND RURAL
% figure('Position', [100, 100, 800, 600]);
% hold on;
% 
% % 🎯 이상적 구간 시각화: 4.84 ~ 6.61초 (회색 음영)
% x_ideal_start = 4.84;
% x_ideal_end = 6.61;
% y_bottom = 0;
% y_top = 1;
% fill([x_ideal_start x_ideal_end x_ideal_end x_ideal_start], ...
%      [y_bottom y_bottom y_top y_top], ...
%      [0.8 0.8 0.8], ...       % 회색
%      'EdgeColor', 'none', ...
%      'FaceAlpha', 0.3, ...
%      'HandleVisibility', 'off');
% 
% % 💡 스타일 정의
% num_sets = length(strategies_all);
% line_styles = {'--', '--', '--', '--', '-.', ':', '--', '-'};
% legend_names = display_names;
% cmap = lines(num_sets);
% adjusted_cmap = cmap * 0.85;
% 
% % 📈 각 Set의 ToS 데이터로 CDF 곡선 그리기
% for i = 1:num_sets
%     tos_data = tos_data_all{1, i};
%     if ~isempty(tos_data)
%         tos_data = round(tos_data, 3);
%         [cdf_vals, x_vals] = ecdf(tos_data);
%         plot(x_vals, cdf_vals, ...
%             'LineStyle', line_styles{i}, ...
%             'Color', adjusted_cmap(i, :), ...
%             'LineWidth', 1.6, ...
%             'MarkerSize', 6, ...
%             'DisplayName', sprintf('%s', legend_names{i}));
%     else
%         % warning('Set %d has no ToS data.', i);
%     end
% end
% 
% % 🧭 축 및 기타 설정
% xlabel('Time-of-Stay [s]', 'FontSize', 14);
% ylabel('CDF', 'FontSize', 14);
% xlim([0, 7]);
% ylim([0, 1]);
% grid on;
% legend('Location', 'southeast', 'FontSize', 11);
% set(gca, 'FontSize', 13);
% set(gcf, 'Color', 'w');
% 
% % 💾 저장
% savefig(fullfile(output_folder, 'results_ToS_CDF_bySet_withIdeal.fig'));
% saveas(gcf, fullfile(output_folder, 'results_ToS_CDF_bySet_withIdeal.png'));

% %% [SCI MAIN FIGURE2] TOS FIGURE - CDF 0 to 1 TERM DENSEURBAN AND RURAL (With Inset)
% figure('Position', [100, 100, 800, 600]);
% hold on;
% 
% num_sets = length(strategies_all);
% line_styles = {'--', '--', '--', '--', '-.', ':', '--', '-'};
% legend_names = display_names;
% cmap = lines(num_sets) * 0.85;
% 
% % 📈 메인 플롯
% for i = 1:num_sets
%     tos_data = tos_data_all{1, i};
%     if ~isempty(tos_data)
%         tos_data = round(tos_data, 3);
%         [cdf_vals, x_vals] = ecdf(tos_data);
% 
%         % Set 6만 굵게 강조 (전략이 6개 이상일 때 유효)
%         lw = 1.6;
%         if i == 6 || (length(strategies_all) >= 6 && strcmp(legend_names{i}, 'Set 6'))
%              lw = 2.5;
%         end
% 
%         plot(x_vals, cdf_vals, ...
%             'LineStyle', line_styles{i}, ...
%             'Color', cmap(i, :), ...
%             'LineWidth', lw, ...
%             'DisplayName', sprintf('%s', legend_names{i}));
%     end
% end
% 
% % 🧭 축 설정
% xlabel('Time-of-Stay [s]', 'FontSize', 14);
% ylabel('CDF', 'FontSize', 14);
% xlim([0, 7]);
% ylim([0, 1]);
% grid on;
% legend('Location', 'southeast', 'FontSize', 11);
% set(gca, 'FontSize', 13);
% set(gcf, 'Color', 'w');
% 
% % 🔍 Inset 확대 그래프
% ax_inset = axes('Position', [0.22, 0.60, 0.28, 0.28]);  % 상단 좌측 위치
% box on;
% hold on;
% for i = 1:num_sets
%     tos_data = tos_data_all{1, i};
%     if ~isempty(tos_data)
%         tos_data = round(tos_data, 3);
%         [cdf_vals, x_vals] = ecdf(tos_data);
% 
%         lw = 1.6;
%         if i == 6 || (length(strategies_all) >= 6 && strcmp(legend_names{i}, 'Set 6'))
%              lw = 2.5;
%         end
% 
%         plot(x_vals, cdf_vals, ...
%             'LineStyle', line_styles{i}, ...
%             'Color', cmap(i, :), ...
%             'LineWidth', lw);
%         grid on;
%     end
% end
% xlim([4.7, 5.3]);
% ylim([0.5, 0.9]);
% set(gca, 'FontSize', 10);
% 
% % 💾 저장
% savefig(fullfile(output_folder, 'results_ToS_CDF_bySet_withIdeal_inset.fig'));
% saveas(gcf, fullfile(output_folder, 'results_ToS_CDF_bySet_withIdeal_inset.png'));

%% [SCI MAIN FIGURE] Short ToS (Rural Only + 색상 적용)
figure('Position', [100, 100, 1000, 800]);

% 📌 Rural (s = 1)만 Short ToS 계산
short_tos_ratio_rural = zeros(length(strategies_all), 1);
for i = 1:length(strategies_all)
    tos_data = tos_data_all{1, i};  % 1: Rural
    if ~isempty(tos_data)
        total_tos_count = length(tos_data);
        short_tos_count = sum(tos_data < 1);
        short_tos_ratio_rural(i) = (short_tos_count / total_tos_count) * 100;
    end
end

% 🎨 Set별 색상 정의 (재사용)
% rural_colors 이미 사이즈 조정됨

% 📊 막대 그래프
b = bar(short_tos_ratio_rural, 'FaceColor', 'flat');
b.CData = rural_colors;

% 🧭 축 설정
ylabel('Short ToS ratio (%)', 'FontSize', 17.5);
set(gca, 'XTick', 1:length(strategies_all), ...
         'XTickLabel', display_names, ...
         'FontSize', 17.5);
ylim([0, max(short_tos_ratio_rural) + 5]);
grid on; grid minor;

% ✅ 수치 표기
xt = get(gca, 'XTick');
for i = 1:length(strategies_all)
    value = short_tos_ratio_rural(i);
    x = xt(i);
    y = value + 0.5;
    text(x, y, sprintf('%d', round(value)), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 13);
end

% 💾 저장
savefig(fullfile(output_folder, 'compare_shortToS_ratio_rural_only_coloredBySet.fig'));
saveas(gcf, fullfile(output_folder, 'compare_shortToS_ratio_rural_only_coloredBySet.png'));

fprintf('All figures generated successfully.\n');


%% [SCI MAIN FIGURE] Average ToS (Rural Only + 색상 적용)
figure('Position', [100, 100, 1000, 800]);

% 📌 Rural (s = 1)만 Average ToS 계산
mean_tos_rural = zeros(length(strategies_all), 1);
for i = 1:length(strategies_all)
    tos_data = tos_data_all{1, i};  % 1: Rural
    if ~isempty(tos_data)
        mean_tos_rural(i) = mean(tos_data); % 평균값 계산
    end
end

% 🎨 Set별 색상 정의 (Short ToS와 동일한 로직)
% (만약 위에서 rural_colors가 이미 정의되어 있다면 이 부분은 주석 처리해도 됨)
% 📊 막대 그래프
b = bar(mean_tos_rural, 'FaceColor', 'flat');
b.CData = rural_colors;

% 🧭 축 설정
ylabel('Average Time-of-Stay [s]', 'FontSize', 17.5);
set(gca, 'XTick', 1:length(strategies_all), ...
         'XTickLabel', display_names, ...
         'FontSize', 17.5);
ylim([0, max(mean_tos_rural) * 1.15]); % 여유 공간 확보
grid on; grid minor;

% ✅ 수치 표기
xt = get(gca, 'XTick');
for i = 1:length(strategies_all)
    value = mean_tos_rural(i);
    x = xt(i);
    y = value + 0.1; % ToS 값에 맞춰 위치 조정 (초 단위이므로 작게)
    text(x, y, sprintf('%.2f', value), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 13);
end

% 💾 저장
savefig(fullfile(output_folder, 'compare_avg_ToS_rural_only_coloredBySet.fig'));
saveas(gcf, fullfile(output_folder, 'compare_avg_ToS_rural_only_coloredBySet.png'));


%% [Additional Figure] Efficiency vs Stability Trade-off
figure('Position', [100, 100, 800, 600]);
hold on;

% 데이터 준비 (X: 불안정성, Y: 비용)
% X축: RLF 횟수 + (Short ToS 비율 * 10) -> 스케일 맞춤 (가중치는 조절 가능)
% Y축: RB Usage (Calculated previously)

x_data = zeros(length(strategies_all), 1);
y_data = wasted_rb_usage + eff_rb_usage; % Total RB Usage

for i = 1:length(strategies_all)
    % X축: 불안정성 지표 (RLF가 제일 나쁘고, Short ToS도 나쁨)
    rlf_val = mean(rlf_data_all{1, i});
    
    % Short ToS 비율 계산
    tos_data = tos_data_all{1, i};
    short_tos_ratio = 0;
    if ~isempty(tos_data)
        short_tos_ratio = sum(tos_data < 1) / length(tos_data);
    end
    
    % X값: RLF에는 큰 페널티(10), Short ToS에는 작은 페널티(1)
    x_data(i) = (rlf_val * 10) + (short_tos_ratio * 100); 
end

% 산점도 그리기
scatter(x_data, y_data, 100, 'filled', 'MarkerFaceColor', 'k');

% 각 포인트에 라벨 달기
for i = 1:length(strategies_all)
    text(x_data(i)+0.2, y_data(i), display_names{i}, 'FontSize', 12);
    
    % Set 7(제안)만 빨간색으로 강조
    if i == length(strategies_all)
        scatter(x_data(i), y_data(i), 150, 'filled', 'MarkerFaceColor', 'r');
        text(x_data(i)+0.2, y_data(i), 'Proposed (Set 7)', 'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');
    end
end

% 구역 표시 (배경)
xlabel('Instability Index (RLF & Short ToS)', 'FontSize', 14);
ylabel('Signaling Overhead (RB Usage)', 'FontSize', 14);
grid on;
title('Efficiency vs. Stability Trade-off', 'FontSize', 16);

% 이상적인 방향 화살표
annotation('arrow', [0.8 0.2], [0.8 0.2], 'Color', 'r', 'LineWidth', 2);
text(10, max(y_data), 'Ideal Direction (Low Cost, High Stability)', 'Color', 'r');

saveas(gcf, fullfile(output_folder, 'trade_off_plot.png'));

%% ========================================================================
% [FINAL REVISED] Full Comparison (Set 1-7) without Text Annotations
% 모든 Set 포함 (1~7) & 텍스트 제거 버전
% ========================================================================

% 1. 비교 대상 설정 (Set 1 ~ Set 7 전체)
% comp_indices = 1:7; 
% comp_names = {'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5', 'Set 6', 'Proposed (Set 7)'};
n_comp = length(comp_indices);

% 색상 설정 (Set 1~6: 회색조/파란조, Set 7: 붉은색 강조)
% 기본 색상
base_color = [0.2 0.4 0.6]; % 차분한 파란색
highlight_color = [0.8 0.1 0.1]; % 강조용 붉은색

% ---------------------------------------------------------
% FIGURE A: UHO & HOPP Count (전체 비교)
% ---------------------------------------------------------
figure('Position', [300, 300, 900, 600]);
uho_vals = zeros(1, n_comp);
hopp_vals = zeros(1, n_comp);

for k = 1:n_comp
    idx = comp_indices(k);
    uho_vals(k) = sum(uho_data_all{1, idx})/UE_num; % Rural scenario
    hopp_vals(k) = sum(hopp_data_all{1, idx})/UE_num;
end

% 그룹형 바 차트
b = bar([uho_vals', hopp_vals'], 'grouped');
b(1).FaceColor = [0.3 0.5 0.7]; % UHO
b(2).FaceColor = [0.8 0.5 0.3]; % HOPP

ylabel('Number of Events', 'FontSize', 15, 'FontWeight', 'bold');
set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names, 'FontSize', 13, 'FontWeight', 'bold');
legend({'Unnecessary HO (UHO)', 'Ping-Pong (HOPP)'}, 'Location', 'northeast', 'FontSize', 13);
grid on;
title('Stability Comparison: UHO & HOPP Counts (All Sets)', 'FontSize', 16);

% 수치만 표시 (텍스트 제거됨)
for k = 1:n_comp
    % UHO
    if uho_vals(k) > 0
        text(k-0.15, uho_vals(k)+100, num2str(round(uho_vals(k))), ...
            'HorizontalAlignment', 'center', 'FontSize', 11);
    end
    % HOPP
    if hopp_vals(k) > 0
        text(k+0.15, hopp_vals(k)+100, num2str(round(hopp_vals(k))), ...
            'HorizontalAlignment', 'center', 'FontSize', 11);
    end
end
saveas(gcf, fullfile(output_folder, 'review_response_UHO_AllSets.png'));


% % ---------------------------------------------------------
% % FIGURE B: Total RB Usage (전체 비교)
% % ---------------------------------------------------------
% figure('Position', [300, 300, 900, 600]);
% rb_vals = zeros(1, n_comp);
% 
% for k = 1:n_comp
%     idx = comp_indices(k);
%     % rb_vals(k) = sum(rbs_data_all{1, idx}); 
%     rb_vals(k) = sum(ho_data_all{1, idx}); 
% end
% 
% hold on;
% for k = 1:n_comp
%     if k == n_comp % 제안 기법만 강조색
%         bar(k, rb_vals(k), 'FaceColor', highlight_color);
%     else
%         bar(k, rb_vals(k), 'FaceColor', base_color);
%     end
% end
% 
% ylabel('Total Control Signaling Overhead [RBs]', 'FontSize', 15, 'FontWeight', 'bold');
% set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names, 'FontSize', 13, 'FontWeight', 'bold');
% grid on;
% title('Signaling Efficiency: RB Usage Comparison (All Sets)', 'FontSize', 16);
% 
% % 값 표시
% for k = 1:n_comp
%     text(k, rb_vals(k)*1.02, num2str(round(rb_vals(k))), ...
%         'HorizontalAlignment', 'center', 'FontSize', 12);
% end
% hold off;
% saveas(gcf, fullfile(output_folder, 'review_response_RB_AllSets.png'));


% ---------------------------------------------------------
% FIGURE C: Trade-off Analysis (HO Count vs SINR) - 추천 그래프
% ---------------------------------------------------------
figure('Position', [300, 300, 900, 600]);
sinr_means = zeros(1, n_comp);
ho_counts = zeros(1, n_comp);

for k = 1:n_comp
    idx = comp_indices(k);
    sinr_means(k) = mean(raw_sinr_data_all{1, idx});
    ho_counts(k) = sum(ho_data_all{1, idx});
end

% [왼쪽 Y축] HO Count (Bar)
yyaxis left
b_ho = bar(ho_counts, 0.6, 'FaceAlpha', 0.6);
b_ho.FaceColor = [0.8 0.2 0.2]; % 붉은색 계열 (HO Count)
ylabel('Total Handover Count', 'FontSize', 15, 'FontWeight', 'bold');
ax = gca; 
ax.YColor = [0.8 0.1 0.1];
ylim([0, max(ho_counts)*1.1]); 

% [오른쪽 Y축] SINR (Line)
yyaxis right
p_sinr = plot(sinr_means, '-s', 'LineWidth', 3, 'MarkerSize', 10, ...
    'MarkerEdgeColor', 'b', 'MarkerFaceColor', 'b', 'Color', [0 0.447 0.741]);
ylabel('Average DL SINR [dB]', 'FontSize', 15, 'FontWeight', 'bold');
ax = gca; 
ax.YColor = [0 0.447 0.741];
% SINR 범위는 데이터에 맞춰 조정 (-4 ~ -2 정도가 적당해 보임)
ylim([min(sinr_means)-0.5, max(sinr_means)+0.5]); 

% 축 및 타이틀 설정
set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names, 'FontSize', 12, 'FontWeight', 'bold');
xtickangle(20); % 라벨이 많으므로 살짝 기울임
grid on;
title('Performance Comparison: Signaling Overhead vs. Link Quality', 'FontSize', 16);

legend([b_ho, p_sinr], {'Total HO Count (Left)', 'Avg. DL SINR (Right)'}, ...
    'Location', 'north', 'FontSize', 12);

saveas(gcf, fullfile(output_folder, 'review_response_Tradeoff_AllSets.png'));


%% ========================================================================
% [NEW VISUALIZATION] Maximizing the Impact of Proposed Method
% 전략: 정규화(Normalization)를 최소화하고 절대적 격차(Magnitude)를 강조
% ========================================================================

% 비교 대상 인덱스 및 이름 설정
comp_indices = 1:8; 
comp_names_short = {'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5', 'Set 6', 'Set 7', 'Set 8'};
n_comp = length(comp_indices);

% 데이터 추출 (Rural 시나리오 기준: s=1)
total_ho_counts = zeros(1, n_comp);
total_rb_counts = zeros(1, n_comp);
avg_sinr_vals = zeros(1, n_comp);

for k = 1:n_comp
    idx = comp_indices(k);
    % [중요] 평균이 아니라 '합계(Sum)'를 사용하여 규모감 강조
    total_ho_counts(k) = sum(ho_data_all{1, idx}); 

    % RB 계산: 논문에 언급된 HO * 10 RB 공식을 그대로 적용하여 누적값 계산
    % (만약 rbs_data_all에 이미 계산되어 있다면 그것을 써도 됩니다)
    % 여기서는 명확한 비교를 위해 HO 횟수 기반으로 스케일링합니다.
    total_rb_counts(k) = total_ho_counts(k) * 10; 

    avg_sinr_vals(k) = mean(raw_sinr_data_all{1, idx});
end

% 색상 설정 (제안 기법만 강렬한 색상)
bar_color_base = [0.7 0.7 0.7]; % 회색
bar_color_prop = [0.8 0.1 0.1]; % 빨간색

% %% [Figure A] Total Network Signaling Overhead (Absolute Scale)
% % 설명: "초당/단말당"으로 나누지 않고 전체 네트워크 부하를 보여줌으로써 압도적 차이 강조
% figure('Position', [100, 100, 900, 650]);
% 
% % 왼쪽 축: Total HO Count
% yyaxis left
% b = bar(total_ho_counts, 0.6);
% b.FaceColor = 'flat';
% for k = 1:n_comp
%     if k == n_comp
%         b.CData(k,:) = bar_color_prop; % 제안 기법 강조
%     else
%         b.CData(k,:) = bar_color_base;
%     end
% end
% ylabel('Total Handover Events (Network-wide)', 'FontSize', 16, 'FontWeight', 'bold');
% set(gca, 'YColor', 'k', 'FontSize', 14);
% ylim([0, max(total_ho_counts)*1.15]); % 여유 공간
% 
% % 텍스트: 감소율 표시 (Set 4 기준 vs Proposed)
% ref_idx = 4; % Distance-based 기준 (Set 4)
% reduction_rate = (total_ho_counts(ref_idx) - total_ho_counts(end)) / total_ho_counts(ref_idx) * 100;
% 
% % 화살표 및 텍스트 추가
% hold on;
% x_start = ref_idx; 
% x_end = n_comp;
% y_high = total_ho_counts(ref_idx) * 1.05;
% plot([x_start, x_end], [y_high, y_high], 'k-', 'LineWidth', 2);
% plot([x_start, x_start], [total_ho_counts(ref_idx), y_high], 'k-', 'LineWidth', 1);
% plot([x_end, x_end], [total_ho_counts(end), y_high], 'k-', 'LineWidth', 1);
% text((x_start+x_end)/2, y_high + 2000, sprintf('\\bf -%.1f%% Signaling Reduction', reduction_rate), ...
%     'HorizontalAlignment', 'center', 'Color', 'r', 'FontSize', 16);
% 
% % 오른쪽 축: Total RB Usage (비용 관점)
% yyaxis right
% % RB는 HO 횟수와 비례하므로 굳이 그래프를 또 그리기보다 축만 표시하여 비용 의미 전달
% ylabel('Total Signaling Cost (RBs)', 'FontSize', 16, 'FontWeight', 'bold');
% set(gca, 'YColor', [0.8 0.4 0], 'FontSize', 14);
% ylim([0, (max(total_ho_counts)*1.15) * 10]); % HO 스케일의 10배로 축 설정
% 
% set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names_short, 'FontSize', 14, 'FontWeight', 'bold');
% grid on;
% title('Total Network Load Analysis: Absolute Impact', 'FontSize', 18);
% 
% % 막대 위 수치 표시
% for k = 1:n_comp
%     if k == n_comp
%         txt_color = 'r'; weight = 'bold';
%     else
%         txt_color = 'k'; weight = 'normal';
%     end
%     text(k, total_ho_counts(k), num2str(round(total_ho_counts(k))), ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
%         'FontSize', 13, 'Color', txt_color, 'FontWeight', weight);
% end
% 
% saveas(gcf, fullfile(output_folder, 'results_Total_Load_Absolute.png'));


%% [Figure B] Handover Frequency per Minute (Human-Readable Scale)
% 설명: "초당 0.xx회" 대신 "분당 12회"로 변환하여 직관성 향상
figure('Position', [150, 150, 900, 600]);

% 계산: (총 HO / 총 시간 / 단말 수) * 60초 = 분당 단말당 HO 횟수
ho_per_min = (total_ho_counts ./ TOTAL_TIME ./ UE_num) * 60;

b2 = bar(ho_per_min, 0.5);
b2.FaceColor = 'flat';
for k = 1:n_comp
    if k == n_comp
        b2.CData(k,:) = [0 0.447 0.741]; % 파란색 강조 (안정성 의미)
    else
        b2.CData(k,:) = [0.8 0.8 0.8]; % 연한 회색
    end
end

ylabel('HO Frequency [events / min / UE]', 'FontSize', 16, 'FontWeight', 'bold');
set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names_short, 'FontSize', 14);
grid on;
title('User Experience: Average Handover Frequency per Minute', 'FontSize', 18);

% 수치 표시
for k = 1:n_comp
    text(k, ho_per_min(k), sprintf('%.1f', ho_per_min(k)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', 14, 'FontWeight', 'bold');
end

% Insight 텍스트 추가
text(2, max(ho_per_min)*0.9, 'Frequent Interruptions', 'FontSize', 14, 'Color', [0.5 0.5 0.5]);
text(n_comp, ho_per_min(end)*2.5, 'Stable Connectivity', 'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', 'b', 'FontWeight', 'bold');

saveas(gcf, fullfile(output_folder, 'results_HO_Frequency_PerMin.png'));


% %% [Figure C] "Wasted Cost" Analysis (Excess vs Essential)
% % 설명: 제안 기법(Set 7)을 '필수 비용(Essential)'으로 정의하고,
% % 나머지 기법들이 얼마나 많은 '낭비(Waste)'를 하고 있는지 시각화
% figure('Position', [200, 200, 900, 600]);
% 
% % 제안 기법(Set 7)의 값을 기준(Baseline)으로 설정
% baseline_ho = total_ho_counts(end);
% excess_ho = total_ho_counts - baseline_ho; % 초과분 계산
% excess_ho(excess_ho < 0) = 0; % 음수 방지
% 
% % 스택 바 차트 데이터 구성 [필수(Baseline), 낭비(Excess)]
% stacked_data = [repmat(baseline_ho, n_comp, 1), excess_ho'];
% 
% b3 = bar(stacked_data, 'stacked', 'BarWidth', 0.6);
% b3(1).FaceColor = [0.2 0.6 0.2]; % 필수 (녹색: Essential)
% b3(2).FaceColor = [0.8 0.2 0.2]; % 낭비 (적색: Wasted/Redundant)
% 
% ylabel('Total Handover Count', 'FontSize', 16, 'FontWeight', 'bold');
% set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names_short, 'FontSize', 14);
% legend({'Essential HOs (Proposed Baseline)', 'Redundant HOs (Wasted Cost)'}, ...
%     'Location', 'northeast', 'FontSize', 13);
% grid on;
% title('Efficiency Analysis: Essential vs. Redundant HOs', 'FontSize', 18);
% 
% % 낭비 비율 텍스트 표시
% for k = 1:n_comp-1 % 제안 기법 제외
%     waste_pct = (excess_ho(k) / total_ho_counts(k)) * 100;
%     text(k, total_ho_counts(k), sprintf('%.0f%% Wasted', waste_pct), ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
%         'FontSize', 11, 'Color', 'r', 'FontWeight', 'bold');
% end
% text(n_comp, baseline_ho, 'Optimum', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', [0.2 0.6 0.2], 'FontWeight', 'bold');
% 
% saveas(gcf, fullfile(output_folder, 'results_Excess_Cost_Analysis.png'));

% %% [Figure C] "Wasted Cost" Analysis (Excess vs Essential) - RB Cost Version
% % 설명: HO 횟수가 아닌 'RB 비용(Signaling Cost)'으로 환산하여 보여줌 (HO * 10)
% % 정규화(시간/단말 나눗셈)를 하지 않아 '전체 네트워크 절감량'을 강조함
% 
% figure('Position', [200, 200, 900, 600]);
% 
% % 1. 데이터 변환: HO 횟수 -> RB 비용 (x 10)
% % 논문 근거: 1 HO = 10 RBs overhead
% total_rb_cost = total_ho_counts * 10; 
% 
% % 2. 기준점 설정 (제안 기법의 RB 소모량)
% baseline_cost = total_rb_cost(end);
% excess_cost = total_rb_cost - baseline_cost; % 초과 비용 계산
% excess_cost(excess_cost < 0) = 0; % 음수 방지
% 
% % 3. 스택 바 차트 데이터 구성 [필수 비용(Baseline), 낭비 비용(Excess)]
% stacked_data = [repmat(baseline_cost, n_comp, 1), excess_cost'];
% 
% % 4. 그래프 그리기
% b3 = bar(stacked_data, 'stacked', 'BarWidth', 0.6);
% b3(1).FaceColor = [0.2 0.6 0.2]; % 필수 비용 (녹색: Essential Cost)
% b3(2).FaceColor = [0.8 0.2 0.2]; % 낭비 비용 (적색: Wasted Cost)
% 
% % 5. 축 및 라벨 설정
% ylabel('Total Signaling Overhead [RBs]', 'FontSize', 16, 'FontWeight', 'bold'); % 단위 변경
% set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names_short, 'FontSize', 14);
% grid on;
% 
% % 범례 수정
% legend({'Essential Cost (Proposed)', 'Wasted Cost (Redundant HO)'}, ...
%     'Location', 'northeast', 'FontSize', 13);
% title('Efficiency Analysis: Network-wide Signaling Cost', 'FontSize', 18);
% 
% % 6. 낭비 비율 텍스트 표시 (비율은 HO 횟수 기준이나 RB 기준이나 동일함)
% for k = 1:n_comp-1 % 제안 기법 제외
%     % 전체 대비 낭비된 비율 계산
%     waste_pct = (excess_cost(k) / total_rb_cost(k)) * 100;
% 
%     % 막대 위에 텍스트 표시 (수치는 RB 단위)
%     text(k, total_rb_cost(k), sprintf('%.0f%% Wasted\n(%d RBs)', waste_pct, round(excess_cost(k))), ...
%         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
%         'FontSize', 11, 'Color', 'r', 'FontWeight', 'bold');
% end
% 
% % 제안 기법 강조 텍스트
% text(n_comp, baseline_cost, sprintf('Optimum\n(%d RBs)', round(baseline_cost)), ...
%     'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
%     'FontSize', 12, 'Color', [0.2 0.6 0.2], 'FontWeight', 'bold');
% 
% % 저장
% saveas(gcf, fullfile(output_folder, 'results_Excess_RB_Cost_Analysis.png'));

%% ========================================================================
% [Final Revised Figure 2] Efficiency Analysis (Normalized RB Cost)
% 수정 사항:
% 1. 데이터 변환: 'RBs/UE/min' 단위 유지
% 2. 텍스트 위치 복원: 막대 위(Above)에 검은색 글씨로 표시
% ========================================================================

figure('Position', [200, 200, 900, 700]);

% 1. 데이터 준비 및 정규화
% comp_names_short = {'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5', 'Set 6', 'Set 7'};
n_comp = length(comp_indices);

% 정규화 계수 (분당 단말당 RB 수로 변환)
norm_factor = (1 / (UE_num * TOTAL_TIME)) * 60; 

val_essential_norm = zeros(1, n_comp);
val_wasted_norm = zeros(1, n_comp);
val_total_norm = zeros(1, n_comp);

for k = 1:n_comp
    idx = comp_indices(k);
    curr_ho_count = sum(ho_data_all{1, idx});
    curr_uho_count = sum(uho_data_all{1, idx});
    
    val_essential_norm(k) = (curr_ho_count - curr_uho_count) * 10 * norm_factor;
    val_wasted_norm(k) = curr_uho_count * 10 * norm_factor;
    val_total_norm(k) = val_essential_norm(k) + val_wasted_norm(k);
end

% 2. 그래프 그리기
stacked_data = [val_essential_norm', val_wasted_norm'];
b3 = bar(stacked_data, 'stacked', 'BarWidth', 0.6);
b3(1).FaceColor = [0.2 0.6 0.2]; % 녹색: Essential
b3(2).FaceColor = [0.8 0.2 0.2]; % 적색: Wasted

% 3. 축 및 라벨 설정
ylabel('Total Signaling Overhead [RBs/UE/min]', 'FontSize', 16, 'FontWeight', 'bold');
set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names_short, 'FontSize', 15, 'FontWeight', 'bold');
grid on;
legend({'Essential Cost (Valid HO)', 'Wasted Cost (UHO)'}, 'Location', 'northeast', 'FontSize', 15); 

% Y축 여유 공간 확보 (텍스트가 잘리지 않도록 1.35배 설정)
ylim([0, max(val_total_norm) * 1.35]); 

% 4. 텍스트 라벨 추가 (막대 위, 검은색)
for k = 1:n_comp
    if val_total_norm(k) > 0
        waste_pct = (val_wasted_norm(k) / val_total_norm(k)) * 100;
    else
        waste_pct = 0;
    end
    
    % 표시할 텍스트 내용
    label_str = sprintf('%.1f%% wasted\n(%.1f)', waste_pct, val_total_norm(k));
    if waste_pct == 0
        label_str = sprintf('0%% wasted\n(%.1f)', val_total_norm(k));
    end

    % [수정됨] 위치: 막대 높이보다 약간 위 (1.02배)
    % 색상: 검은색 ('k')
    text(k, val_total_norm(k) + (max(val_total_norm)*0.02), label_str, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');
end

saveas(gcf, fullfile(output_folder, 'FINAL_Fig2_RB_Cost_Efficiency_Top.png'));

%% ========================================================================
% [Final Figure C] Efficiency Analysis (Handover Count Basis) - Text Top
% 수정 사항:
% 1. 데이터: RB 가중치 제거 -> 순수 횟수(Count) 기반
% 2. 단위: [events/UE/min]
% 3. 텍스트 위치: 막대 위(Above)로 복원, 검은색 글씨
% ========================================================================

figure('Position', [200, 200, 900, 700]);

% 1. 데이터 준비
% comp_indices = 1:7; (기존 인덱스 사용)
% comp_names_short = {'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5', 'Set 6', 'Set 7'};
n_comp = length(comp_indices);

% [핵심] 정규화 계수 (분당 단말당 횟수로 변환)
norm_factor = (1 / (UE_num * TOTAL_TIME)) * 60;

% 데이터 담을 배열 초기화
val_essential_norm = zeros(1, n_comp);
val_wasted_norm = zeros(1, n_comp);
val_total_norm = zeros(1, n_comp);

for k = 1:n_comp
    idx = comp_indices(k);
    
    % 데이터 추출 (Rural: s=1)
    curr_ho_count = sum(ho_data_all{1, idx});
    curr_uho_count = sum(uho_data_all{1, idx});
    
    % [수정] RB 곱하기(x10) 제거 -> 순수 횟수에 정규화 적용
    % Essential: 유효한 핸드오버 (전체 - UHO)
    val_essential_norm(k) = (curr_ho_count - curr_uho_count) * norm_factor;
    
    % Wasted: 불필요한 핸드오버 (UHO)
    val_wasted_norm(k) = curr_uho_count * norm_factor;
    
    % Total
    val_total_norm(k) = val_essential_norm(k) + val_wasted_norm(k);
end

% 2. 스택 바 차트 데이터 구성
stacked_data = [val_essential_norm', val_wasted_norm'];

% 3. 그래프 그리기
b3 = bar(stacked_data, 'stacked', 'BarWidth', 0.6);
b3(1).FaceColor = [0.2 0.6 0.2]; % 녹색: Essential (Valid HO)
b3(2).FaceColor = [0.8 0.2 0.2]; % 적색: Wasted (UHO)

% 4. 축 및 라벨 설정
ylabel('Average Handover Frequency [HOs/UE/min]', 'FontSize', 16, 'FontWeight', 'bold');
set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names_short, 'FontSize', 15, 'FontWeight', 'bold');
grid on;

% 범례
legend({'Essential HO (Valid)', 'Wasted HO (UHO)'}, ...
    'Location', 'northeast', 'FontSize', 15);

% Y축 범위 넉넉하게 조정 (텍스트 공간 확보)
ylim([0, max(val_total_norm) * 1.35]);

% 5. 텍스트 라벨 추가 (막대 위, 검은색)
for k = 1:n_comp
    % (1) 낭비 비율 계산
    if val_total_norm(k) > 0
        waste_pct = (val_wasted_norm(k) / val_total_norm(k)) * 100;
    else
        waste_pct = 0;
    end
    
    % (2) 텍스트 표시
    label_str = sprintf('%.1f%% Wasted\n(%.1f)', waste_pct, val_total_norm(k));
    
    if waste_pct == 0
        label_str = sprintf('0%% Wasted\n(%.1f)', val_total_norm(k));
    end

    % [수정] 위치: 막대 높이보다 약간 위 (Total Height + Margin)
    % 색상: 검은색 ('k')
    text(k, val_total_norm(k) + (max(val_total_norm)*0.02), label_str, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ... 
        'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');
end

% 결과 저장
saveas(gcf, fullfile(output_folder, 'FINAL_Fig2_HO_Efficiency_Top.png'));

%% ========================================================================
% [Final Figure C] Efficiency Analysis (Breakdown: Essential, UHO, HOPP)
% 수정 사항:
% 1. Wasted Cost 분해: UHO(Red)와 HOPP(Purple)로 나누어 적층 (Stack)
% 2. 데이터 무결성: HOPP는 UHO의 부분집합이므로, 'Pure UHO = Total UHO - HOPP'로 계산
% 3. 시각화: HOPP가 있는 경우(Set 1) 가장 위에 보라색으로 표시하여 눈에 띄게 함
% ========================================================================

figure('Position', [200, 200, 900, 700]);

% 1. 데이터 준비
% comp_indices = 1:7; (기존 인덱스 사용)
% comp_names_short = {'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5', 'Set 6', 'Set 7'};
n_comp = length(comp_indices);

% 정규화 계수 (분당 단말당 횟수)
norm_factor = (1 / (UE_num * TOTAL_TIME)) * 60;

% 데이터 담을 배열 초기화
val_essential_norm = zeros(1, n_comp);
val_uho_pure_norm = zeros(1, n_comp); % HOPP를 제외한 순수 UHO
val_hopp_norm = zeros(1, n_comp);     % HOPP (Ping-Pong)
val_total_norm = zeros(1, n_comp);
val_wasted_total_norm = zeros(1, n_comp); % 텍스트 표기용 (UHO + HOPP)

for k = 1:n_comp
    idx = comp_indices(k);
    
    % 데이터 추출 (Rural: s=1)
    curr_ho_count = sum(ho_data_all{1, idx});
    curr_uho_count = sum(uho_data_all{1, idx});
    curr_hopp_count = sum(hopp_data_all{1, idx}); % HOPP 데이터 추가
    
    % [데이터 분해]
    % 1. Essential (필수): 전체 HO - UHO (UHO 안에 HOPP가 포함되어 있으므로 전체 UHO를 뺌)
    val_essential_norm(k) = (curr_ho_count - curr_uho_count) * norm_factor;
    
    % 2. HOPP (핑퐁): 가장 악성인 낭비
    val_hopp_norm(k) = curr_hopp_count * norm_factor;
    
    % 3. Pure UHO (순수 낭비): 전체 UHO - HOPP (남은 낭비)
    val_uho_pure_norm(k) = (curr_uho_count - curr_hopp_count) * norm_factor;
    
    % Total & Wasted Sum 확인
    val_total_norm(k) = val_essential_norm(k) + val_uho_pure_norm(k) + val_hopp_norm(k);
    val_wasted_total_norm(k) = val_uho_pure_norm(k) + val_hopp_norm(k);
end

% 2. 스택 바 차트 데이터 구성 [Essential, Pure UHO, HOPP]
stacked_data = [val_essential_norm', val_uho_pure_norm', val_hopp_norm'];

% 3. 그래프 그리기
b3 = bar(stacked_data, 'stacked', 'BarWidth', 0.6);

% 4. 색상 지정
b3(1).FaceColor = [0.2 0.6 0.2]; % 녹색: Essential
b3(2).FaceColor = [0.8 0.2 0.2]; % 적색: Pure UHO (일반 낭비)
b3(3).FaceColor = [0.5 0.0 0.5]; % 보라색: HOPP (핑퐁 - 악성 낭비)

% 5. 축 및 라벨 설정
ylabel('Average HOs/UE/min', 'FontSize', 16, 'FontWeight', 'bold');
set(gca, 'XTick', 1:n_comp, 'XTickLabel', comp_names_short, 'FontSize', 15, 'FontWeight', 'bold');
grid on;

% 범례 (HOPP 추가)
legend({'Essential HO (Valid)', 'Wasted HO (UHO)', 'Wasted HO (HOPP)'}, ...
    'Location', 'northeast', 'FontSize', 13);

% Y축 범위 조정
ylim([0, max(val_total_norm) * 1.35]);

% 6. 텍스트 라벨 추가 (막대 위)
for k = 1:n_comp
    % (1) 낭비 비율 계산 (UHO + HOPP 전체 기준)
    if val_total_norm(k) > 0
        waste_pct = (val_wasted_total_norm(k) / val_total_norm(k)) * 100;
    else
        waste_pct = 0;
    end
    
    % (2) 텍스트 표시
    label_str = sprintf('%.1f%% Wasted\n(%.1f)', waste_pct, val_total_norm(k));
    
    if waste_pct == 0
        label_str = sprintf('0%% Wasted\n(%.1f)', val_total_norm(k));
    end

    % 위치: 막대 높이 위 (Top)
    text(k, val_total_norm(k) + (max(val_total_norm)*0.02), label_str, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ... 
        'FontSize', 11, 'Color', 'k', 'FontWeight', 'bold');
end

% 결과 저장
savefig(fullfile(output_folder, 'FINAL_Fig2_HO_Efficiency_HOPP_Stack.fig'));
saveas(gcf, fullfile(output_folder, 'FINAL_Fig2_HO_Efficiency_HOPP_Stack.png'));