clear;
close all;
clc;

%% ========================================================================
% [1] USER CONFIGURATION (여기만 수정하면 모든 그래프가 바뀝니다)
% ========================================================================

% 1.1 기본 시뮬레이션 파라미터
UE_num = 100;
SAMPLE_TIME = 0.2; 
TOTAL_TIME = 173.21 / 7.56; 
output_folder = '_FINAL_RESULTS_FIGURES_AUTO'; % 결과 저장 폴더

% 1.2 데이터 파일 경로 및 시나리오
case_path = 'MasterResults2'; % 데이터 폴더
cases_prefix = 'case 1';      % 파일명 접두사
scenarios = {'Rural'};        % 시나리오 (Rural만 사용 시 하나만 유지)

% 1.3 [전략 풀(Pool) 정의] - 존재하는 모든 파일명과 라벨을 순서대로 적어둡니다.
% 실제 시뮬레이션 결과 파일명에 들어가는 문자열
ALL_STRATEGIES_POOL = { ...
    'Strategy A', ... % Index 1
    'Strategy B', ... % Index 2
    'Strategy C', ... % Index 3
    'Strategy D', ... % Index 4
    'Strategy E', ... % Index 5
    'Strategy F', ... % Index 6
    'Strategy G', ... % Index 7
    'Strategy H', ... % Index 8
    'Strategy J', ... % Index 9
    'Strategy K'  ... % Index 10
};

% 그래프 X축에 표시될 이름 (위 순서와 1:1 대응)
ALL_LABELS_POOL = { ...
    'Set 1', 'Set 2', 'Set 3', 'Set 4', 'Set 5', ...
    'Set 6', 'Set 7', 'Set 8', 'Set 9', 'Set 10' ...
};

% 1.4 [핵심] 분석할 전략 선택 (이 숫자들만 바꾸면 됩니다!)
% 예: 4개 세트 비교 -> [1, 2, 3, 4]
% 예: 특정 전략 비교 -> [1, 4, 7, 8, 9]
TARGET_INDICES = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; 

% 1.5 색상 팔레트 정의 (RGB) - 넉넉하게 정의해둠
FULL_COLOR_MAP = [
    0.000, 0.447, 0.741; % 1. Blue (Set 1)
    0.850, 0.325, 0.098; % 2. Orange (Set 2)
    0.929, 0.694, 0.125; % 3. Yellow (Set 3)
    0.494, 0.184, 0.556; % 4. Purple (Set 4)
    0.466, 0.674, 0.188; % 5. Green (Set 5)
    0.301, 0.745, 0.933; % 6. Cyan (Set 6)
    0.635, 0.078, 0.184; % 7. Red (Set 7)
    0.000, 0.000, 0.000; % 8. Black (Set 8)
    0.500, 0.500, 0.500; % 9. Gray (Set 9)
    0.750, 0.000, 0.750; % 10. Magenta (Set 10)
];

%% ========================================================================
% [2] INITIALIZATION & DYNAMIC SETUP (자동 처리 로직)
% ========================================================================

% 폴더 생성
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 선택된 인덱스로 필터링
active_strategies = ALL_STRATEGIES_POOL(TARGET_INDICES);
display_names     = ALL_LABELS_POOL(TARGET_INDICES);
num_strategies    = length(active_strategies);
num_scenarios     = length(scenarios);

% 색상 맵 자동 조정 (전략 수에 맞춰서 자르거나 반복)
if num_strategies <= size(FULL_COLOR_MAP, 1)
    current_colors = FULL_COLOR_MAP(1:num_strategies, :);
else
    current_colors = repmat(FULL_COLOR_MAP, ceil(num_strategies/size(FULL_COLOR_MAP,1)), 1);
    current_colors = current_colors(1:num_strategies, :);
end

fprintf('--------------------------------------------------\n');
fprintf('Analysis Configuration:\n');
fprintf('Target Strategies (%d): %s\n', num_strategies, strjoin(display_names, ', '));
fprintf('--------------------------------------------------\n');

% 데이터 저장용 Cell 배열 초기화
raw_sinr_data_all = cell(num_scenarios, num_strategies);
sinr_data_all     = cell(num_scenarios, num_strategies);
rlf_data_all      = cell(num_scenarios, num_strategies);
uho_data_all      = cell(num_scenarios, num_strategies);
ho_data_all       = cell(num_scenarios, num_strategies);
hopp_data_all     = cell(num_scenarios, num_strategies);
rbs_data_all      = cell(num_scenarios, num_strategies);
tos_data_all      = cell(num_scenarios, num_strategies);

%% ========================================================================
% [3] DATA LOADING
% ========================================================================
for s = 1:num_scenarios
    for i = 1:num_strategies
        curr_strategy_file = active_strategies{i};
        
        % 파일 경로 생성
        matFileName = [cases_prefix, '_MASTER_RESULTS_', curr_strategy_file, '_', scenarios{s}, '.mat'];
        data_path = fullfile(case_path, matFileName);
        
        if exist(data_path, 'file') == 2
            loaded_data = load(data_path);
            
            % 1. SINR Raw (Boxplot/Violin용)
            if isfield(loaded_data, 'MASTER_RAW_SINR')
                raw_sinr_data_all{s, i} = loaded_data.MASTER_RAW_SINR(:);
            else
                raw_sinr_data_all{s, i} = [];
            end
            
            % 2. SINR Mean (Bar용)
            if isfield(loaded_data, 'MASTER_SINR')
                sinr_data_all{s, i} = loaded_data.MASTER_SINR(:);
            else
                sinr_data_all{s, i} = [];
            end
            
            % 3. KPI Metrics (Mean or Sum)
            % Rural의 경우 보통 전체 합계나 평균을 사용. 여기선 기존 코드 로직 따름.
            uho_data_all{s, i}  = mean(loaded_data.MASTER_UHO, 1);
            ho_data_all{s, i}   = mean(loaded_data.MASTER_HO, 1);
            rlf_data_all{s, i}  = sum(loaded_data.MASTER_RLF, 1); 
            hopp_data_all{s, i} = mean(loaded_data.MASTER_HOPP, 1);
            rbs_data_all{s, i}  = mean(loaded_data.MASTER_RBs, 1);
            
            % 4. ToS
            if isfield(loaded_data, 'MASTER_ToS')
                tos_data_all{s, i} = loaded_data.MASTER_ToS(:);
            else
                tos_data_all{s, i} = [];
            end
        else
            warning('[DATA MISSING] File not found: %s', matFileName);
            % 빈 데이터 채우기 (그래프 오류 방지)
            uho_data_all{s, i} = 0; ho_data_all{s, i} = 0; 
            rlf_data_all{s, i} = 0; hopp_data_all{s, i} = 0; rbs_data_all{s, i} = 0;
            raw_sinr_data_all{s, i} = []; sinr_data_all{s, i} = []; tos_data_all{s, i} = [];
        end
    end
end

% 반올림 처리 (소수점 3자리)
rounder = @(x) round(x, 3);
sinr_data_all = cellfun(rounder, sinr_data_all, 'UniformOutput', false);

%% ========================================================================
% [4] CONSOLE SUMMARY LOG
% ========================================================================
fprintf('\n================== SIMULATION KPI SUMMARY ==================\n');
for i = 1:num_strategies
    % Rural (s=1) 기준
    val_ho   = sum(ho_data_all{1, i});
    val_uho  = sum(uho_data_all{1, i});
    val_hopp = sum(hopp_data_all{1, i});
    val_rlf  = sum(rlf_data_all{1, i});
    
    % Raw SINR 평균
    if ~isempty(raw_sinr_data_all{1, i})
        val_sinr = mean(raw_sinr_data_all{1, i});
    else
        val_sinr = NaN;
    end
    
    fprintf('Set: %-8s | HO: %5d | UHO: %4d | HOPP: %4d | RLF: %4d | Avg SINR: %6.3f dB\n', ...
        display_names{i}, round(val_ho), round(val_uho), round(val_hopp), round(val_rlf), val_sinr);
end
fprintf('============================================================\n\n');

%% ========================================================================
% [5] PLOTTING FIGURES (All logic unified)
% ========================================================================

% 공통 폰트 설정
FONT_AXIS = 16;
FONT_LABEL = 17.5;
FONT_TEXT = 12;

%% [Figure A] RLF Comparison (Bar Chart)
figure('Name', 'RLF Comparison', 'Position', [100, 100, 1000, 800]);

% 데이터 준비 (Rural = 1)
avg_rlf = zeros(num_strategies, 1);
for i = 1:num_strategies
    avg_rlf(i) = mean(rlf_data_all{1, i}); 
end

b = bar(avg_rlf, 'FaceColor', 'flat');
b.CData = current_colors; 

set(gca, 'XTick', 1:num_strategies, 'XTickLabel', display_names, 'FontSize', FONT_AXIS);
ylabel('Average RLF [#operations/UE]', 'FontSize', FONT_LABEL);
grid on; grid minor;
xlim([0.5, num_strategies + 0.5]);
ylim([0, max(avg_rlf) * 1.2 + 0.05]); 

% 수치 표시
xt = get(gca, 'XTick');
for i = 1:num_strategies
    text(xt(i), avg_rlf(i), sprintf('%.2f', avg_rlf(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', FONT_TEXT, 'FontWeight', 'bold');
end
savefig(fullfile(output_folder, 'FIG_A_RLF.fig'));
saveas(gcf, fullfile(output_folder, 'FIG_A_RLF.png'));


%% [Figure B] SINR Boxplot (오류 수정됨)
figure('Name', 'SINR Boxplot', 'Position', [150, 150, 1000, 850]);

sinr_accumulated = [];
group_indices = [];

for i = 1:num_strategies
    current_data = round(raw_sinr_data_all{1, i}, 3); % Rural
    if isempty(current_data), continue; end
    
    sinr_accumulated = [sinr_accumulated; current_data];
    % i는 현재 loop의 인덱스 (1, 2, 3...) -> display_names 순서와 일치
    group_indices = [group_indices; i * ones(length(current_data), 1)];
end

% boxplot의 Labels 개수와 group_indices의 유니크 값 개수가 일치하므로 오류 해결
boxplot(sinr_accumulated, group_indices, 'Labels', display_names, 'Colors', 'k');

% 색상 입히기 (Box 객체 역순 매핑 처리)
h = findobj(gca, 'Tag', 'Box');
num_boxes = length(h);
for j = 1:num_boxes
    idx = num_strategies - j + 1; % 역순 매핑
    if idx > 0 && idx <= num_strategies
        patch(get(h(j), 'XData'), get(h(j), 'YData'), current_colors(idx, :), 'FaceAlpha', 0.5);
    end
end
set(findobj(gca, 'Tag', 'Median'), 'Color', 'k', 'LineWidth', 2);

ylabel('Average DL SINR [dB]', 'FontSize', FONT_LABEL);
set(gca, 'FontSize', FONT_AXIS);
grid on; grid minor;
savefig(fullfile(output_folder, 'FIG_B_SINR_Boxplot.fig'));
saveas(gcf, fullfile(output_folder, 'FIG_B_SINR_Boxplot.png'));


%% [Figure C] SINR Violin Plot
figure('Name', 'SINR Violin', 'Position', [70, 70, 930, 730]);
hold on;

mean_handles = gobjects(1,1);
median_handles = gobjects(1,1);

for i = 1:num_strategies
    y_data = round(sinr_data_all{1, i}, 3); % Rural
    if isempty(y_data), continue; end
    
    % 분포 곡선 (Violin shape)
    [f, xi] = ksdensity(y_data);
    f = f / max(f) * 0.3; 
    fill([i - f, fliplr(i + f)], [xi, fliplr(xi)], current_colors(i, :), ...
        'FaceAlpha', 0.35, 'EdgeColor', 'none');
    
    % 중앙값 (점선)
    median_val = median(y_data);
    median_handles = plot([i - 0.2, i + 0.2], [median_val, median_val], ...
        'k:', 'LineWidth', 2.0);
    
    % 평균 (원)
    mean_val = mean(y_data);
    mean_handles = plot(i, mean_val, 'ko', 'MarkerSize', 7, 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
end

xlim([0.5, num_strategies + 0.5]);
set(gca, 'XTick', 1:num_strategies, 'XTickLabel', display_names, 'FontSize', FONT_AXIS);
ylabel('Average DL SINR [dB]', 'FontSize', FONT_LABEL);
grid on; grid minor;
legend([median_handles, mean_handles], {'Median', 'Mean'}, 'Location', 'southwest', 'FontSize', 13);

savefig(fullfile(output_folder, 'FIG_C_SINR_Violin.fig'));
saveas(gcf, fullfile(output_folder, 'FIG_C_SINR_Violin.png'));


%% [Figure D] Efficiency Stacked Analysis (The most important one)
% (Essential / Pure UHO / HOPP)
figure('Name', 'Efficiency Stack', 'Position', [200, 200, 900, 700]);

% 정규화 계수 (분당 단말당 횟수)
norm_factor = (1 / (UE_num * TOTAL_TIME)) * 60;

val_essential = zeros(1, num_strategies);
val_pure_uho  = zeros(1, num_strategies);
val_hopp      = zeros(1, num_strategies);
val_total     = zeros(1, num_strategies);

for i = 1:num_strategies
    c_ho   = sum(ho_data_all{1, i});
    c_uho  = sum(uho_data_all{1, i});
    c_hopp = sum(hopp_data_all{1, i});
    
    % [논리 분해]
    % Essential = 전체 HO - 전체 UHO (유효한 핸드오버)
    val_essential(i) = (c_ho - c_uho) * norm_factor;
    
    % HOPP = 핑퐁 횟수
    val_hopp(i)      = c_hopp * norm_factor;
    
    % Pure UHO = 전체 UHO - HOPP (핑퐁을 제외한 일반적인 불필요 핸드오버)
    val_pure_uho(i)  = (c_uho - c_hopp) * norm_factor;
    
    val_total(i) = val_essential(i) + val_hopp(i) + val_pure_uho(i);
end

stacked_data = [val_essential', val_pure_uho', val_hopp'];
b3 = bar(stacked_data, 'stacked', 'BarWidth', 0.6);

% 색상 고정 (의미론적 색상)
b3(1).FaceColor = [0.2 0.6 0.2]; % Essential (Green)
b3(2).FaceColor = [0.8 0.2 0.2]; % Pure UHO (Red)
b3(3).FaceColor = [0.5 0.0 0.5]; % HOPP (Purple)

ylabel('Average HOs/UE/min', 'FontSize', FONT_LABEL, 'FontWeight', 'bold');
set(gca, 'XTick', 1:num_strategies, 'XTickLabel', display_names, 'FontSize', FONT_AXIS, 'FontWeight', 'bold');
legend({'Essential HO', 'Wasted (UHO)', 'Wasted (Ping-Pong)'}, 'Location', 'northeast', 'FontSize', 12);
grid on;
ylim([0, max(val_total) * 1.35]); % 텍스트 공간 확보

% 텍스트 라벨 (Wasted %)
for i = 1:num_strategies
    wasted_sum = val_pure_uho(i) + val_hopp(i);
    if val_total(i) > 0
        pct = (wasted_sum / val_total(i)) * 100;
        if pct > 0
            txt_str = sprintf('%.1f%% Waste', pct);
        else
            txt_str = '0% Waste';
        end
        text(i, val_total(i), txt_str, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
            'FontSize', 10, 'FontWeight', 'bold');
    end
end
savefig(fullfile(output_folder, 'FIG_D_Efficiency_Stack.fig'));
saveas(gcf, fullfile(output_folder, 'FIG_D_Efficiency_Stack.png'));


%% [Figure E] Average RB Usage (Bar)
figure('Name', 'RB Usage', 'Position', [250, 250, 1000, 800]);

mean_rbs = zeros(num_strategies, 1);
for i = 1:num_strategies
    % 초당 RB 사용량 계산
    mean_rbs(i) = mean(rbs_data_all{1, i}) / TOTAL_TIME;
end

b = bar(mean_rbs, 'FaceColor', 'flat');
b.CData = current_colors;

ylabel('RBs usage [#/UE/sec]', 'FontSize', FONT_LABEL);
set(gca, 'XTick', 1:num_strategies, 'XTickLabel', display_names, 'FontSize', FONT_AXIS);
grid on; grid minor;
xlim([0.5, num_strategies + 0.5]);
ylim([0, max(mean_rbs) * 1.2]);

% 수치 표시
xt = get(gca, 'XTick');
for i = 1:num_strategies
    text(xt(i), mean_rbs(i), sprintf('%.2f', mean_rbs(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', FONT_TEXT);
end
savefig(fullfile(output_folder, 'FIG_E_RB_Usage.fig'));
saveas(gcf, fullfile(output_folder, 'FIG_E_RB_Usage.png'));


%% [Figure F] Short ToS Ratio (Bar)
figure('Name', 'Short ToS', 'Position', [100, 100, 1000, 800]);

short_tos_ratio = zeros(num_strategies, 1);
for i = 1:num_strategies
    tos_data = tos_data_all{1, i}; % Rural
    if ~isempty(tos_data)
        total_count = length(tos_data);
        short_count = sum(tos_data < 1); % 1초 미만
        short_tos_ratio(i) = (short_count / total_count) * 100;
    end
end

b = bar(short_tos_ratio, 'FaceColor', 'flat');
b.CData = current_colors;

ylabel('Short ToS ratio (%)', 'FontSize', FONT_LABEL);
set(gca, 'XTick', 1:num_strategies, 'XTickLabel', display_names, 'FontSize', FONT_AXIS);
grid on; grid minor;
xlim([0.5, num_strategies + 0.5]);
ylim([0, max(short_tos_ratio) + 5]);

% 수치 표시
xt = get(gca, 'XTick');
for i = 1:num_strategies
    text(xt(i), short_tos_ratio(i) + 0.5, sprintf('%.1f%%', short_tos_ratio(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', FONT_TEXT);
end
savefig(fullfile(output_folder, 'FIG_F_Short_ToS.fig'));
saveas(gcf, fullfile(output_folder, 'FIG_F_Short_ToS.png'));


%% [Figure G] Average ToS (Bar)
figure('Name', 'Average ToS', 'Position', [300, 300, 1000, 800]);

avg_tos = zeros(num_strategies, 1);
for i = 1:num_strategies
    tos_data = tos_data_all{1, i};
    if ~isempty(tos_data)
        avg_tos(i) = mean(tos_data);
    end
end

b = bar(avg_tos, 'FaceColor', 'flat');
b.CData = current_colors;

ylabel('Average Time-of-Stay [s]', 'FontSize', FONT_LABEL);
set(gca, 'XTick', 1:num_strategies, 'XTickLabel', display_names, 'FontSize', FONT_AXIS);
grid on; grid minor;
xlim([0.5, num_strategies + 0.5]);
ylim([0, max(avg_tos) * 1.2]);

xt = get(gca, 'XTick');
for i = 1:num_strategies
    text(xt(i), avg_tos(i), sprintf('%.2f', avg_tos(i)), ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FontSize', FONT_TEXT);
end
savefig(fullfile(output_folder, 'FIG_G_Avg_ToS.fig'));
saveas(gcf, fullfile(output_folder, 'FIG_G_Avg_ToS.png'));

fprintf('\nAll figures generated successfully in folder: %s\n', output_folder);