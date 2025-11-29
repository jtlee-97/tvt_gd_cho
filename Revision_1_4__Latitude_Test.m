% % =========================================================================
% % Verification Script: Geometric Validity Check
% % =========================================================================
% clear; clc; close all;
% 
% %% 1. 물리 파라미터 입력 (User Paper & 3GPP)
% h_sat = 600;              % 고도 (km)
% Re = 6371;                % 지구 반지름 (km)
% HPBW_deg = 4.4127;        % 빔폭 (도)
% Num_Planes = 72;          % 궤도면 개수 (Mega-constellation 가정)
% 
% %% 2. 셀 크기(Cell Size) 계산 및 검증
% % Nadir 빔의 물리적 반지름 계산 (삼각함수)
% beam_radius_km = h_sat * tand(HPBW_deg / 2);
% fprintf('------------------------------------------------\n');
% fprintf('[검증 1] 셀 크기 계산\n');
% fprintf('  - 입력 빔폭: %.4f 도\n', HPBW_deg);
% fprintf('  - 계산된 빔 반지름: %.2f km\n', beam_radius_km);
% fprintf('  - 계산된 빔 지름: %.2f km (사용자 가정 50km와 일치)\n', beam_radius_km * 2);
% 
% % 위성 전체 커버리지 (19개 빔, 3-tier 구조)
% % 중심 빔 + 2바퀴 두름 -> 대략 빔 반지름의 3배가 전체 커버리지 반경
% sat_coverage_radius_km = 3.0 * beam_radius_km; 
% fprintf('  - 위성 1기 전체 커버리지 지름: 약 %.2f km\n', sat_coverage_radius_km * 2);
% fprintf('------------------------------------------------\n');
% 
% %% 3. 궤도 간격(Inter-plane Dist) 계산 및 중첩 여부 판단
% lat_low = 0;   % 적도
% lat_high = 60; % 고위도
% 
% % 궤도면 간 경도 차이 (360도 / 72개)
% delta_lon = 360 / Num_Planes;
% 
% % 구면 기하학에 따른 물리적 거리 계산
% dist_low = (2 * pi * Re * cosd(lat_low)) * (delta_lon / 360);
% dist_high = (2 * pi * Re * cosd(lat_high)) * (delta_lon / 360);
% 
% fprintf('[검증 2] 위도별 궤도 간격 변화 (물리적 거리)\n');
% fprintf('  - 적도(0도) 궤도 간격: %.2f km\n', dist_low);
% fprintf('  - 고위도(60도) 궤도 간격: %.2f km (코사인 법칙에 의해 감소)\n', dist_high);
% fprintf('------------------------------------------------\n');
% 
% %% 4. 결론: 겹치는가?
% fprintf('[검증 3] 중첩(Overlap) 발생 여부 판정\n');
% limit_dist = sat_coverage_radius_km * 2; % 두 위성 커버리지가 딱 붙는 거리
% 
% if dist_low > limit_dist
%     fprintf('  - 적도: 궤도 간격(%.0f) > 커버리지 합(%.0f) -> [안 겹침/여유]\n', dist_low, limit_dist);
% else
%     fprintf('  - 적도: [겹침]\n');
% end
% 
% if dist_high > limit_dist
%     fprintf('  - 고위도: 궤도 간격(%.0f) > 커버리지 합(%.0f) -> [안 겹침]\n', dist_high, limit_dist);
% else
%     fprintf('  - 고위도: 궤도 간격(%.0f) < 커버리지 합(%.0f) -> [★심각하게 겹침★]\n', dist_high, limit_dist);
%     overlap_amount = limit_dist - dist_high;
%     fprintf('  --> 약 %.2f km 만큼 서로 파고듦 (Ambiguity 발생)\n', overlap_amount);
% end
% fprintf('------------------------------------------------\n');
% 
% %% 5. 시각화 (Topology Plot)
% % 위 계산 결과를 눈으로 확인
% figure('Color','w', 'Position', [100 100 1000 400]);
% 
% % [적도]
% subplot(1,2,1); hold on; axis equal; box on;
% viscircles([0,0], sat_coverage_radius_km, 'Color','b'); % 위성 1
% viscircles([dist_low,0], sat_coverage_radius_km, 'Color','r'); % 위성 2
% title(sprintf('Low Latitude (0deg)\nDist: %.0f km (No Overlap)', dist_low));
% xlim([-200, dist_low+200]);
% 
% % [고위도]
% subplot(1,2,2); hold on; axis equal; box on;
% viscircles([0,0], sat_coverage_radius_km, 'Color','b'); % 위성 1
% viscircles([dist_high,0], sat_coverage_radius_km, 'Color','r'); % 위성 2
% % 겹치는 구간 표시
% x_overlap_start = dist_high - sat_coverage_radius_km;
% x_overlap_end = sat_coverage_radius_km;
% if x_overlap_start < x_overlap_end
%    fill([x_overlap_start, x_overlap_end, x_overlap_end, x_overlap_start], ...
%         [-50, -50, 50, 50], 'y', 'FaceAlpha', 0.5, 'EdgeColor','none');
%    text((x_overlap_start+x_overlap_end)/2, 0, 'OVERLAP', 'Horiz','center');
% end
% title(sprintf('High Latitude (60deg)\nDist: %.0f km (Overlap!)', dist_high));
% xlim([-200, dist_low+200]); % 스케일 비교를 위해 적도와 같은 x축 범위 사용
% 
% sgtitle('Mathematical Verification of Beam Overlap', 'FontSize', 14, 'FontWeight','bold');

% % =========================================================================
% % Script: LEO_Continuous_Overlap_Analysis_Fixed.m
% % Purpose: To quantitatively demonstrate the increasing beam overlap ratio
% %          as a function of latitude in Mega-Constellation LEO networks.
% % =========================================================================
% 
% clear; clc; close all;
% 
% %% 1. System Parameters (Based on your paper & Mega-constellation)
% h_sat = 600;                % Satellite altitude (km)
% Re = 6371;                  % Earth radius (km)
% HPBW_deg = 4.4127;          % 3dB Beamwidth (degrees)
% Num_Planes = 72;            % Number of orbital planes (Critical for density)
% 
% % Calculate Beam & Cell Radius
% % Note: Using the coverage radius of the entire satellite (approx. 3x beam radius)
% beam_radius_km = h_sat * tand(HPBW_deg / 2);
% sat_coverage_radius_km = 3.0 * beam_radius_km; 
% sat_coverage_area_km2 = pi * sat_coverage_radius_km^2;
% 
% %% 2. Continuous Calculation across Latitudes
% latitudes = 0:1:80; % Latitude range from 0 to 80 degrees (Step: 1 deg)
% inter_plane_dists = zeros(size(latitudes));
% overlap_ratios = zeros(size(latitudes));
% 
% delta_lon_deg = 360 / Num_Planes; % Longitude separation
% 
% for i = 1:length(latitudes)
%     lat = latitudes(i);
% 
%     % 1. Calculate Physical Inter-plane Distance at this Latitude
%     % Dist = 2*pi*Re * cos(lat) * (delta_lon / 360)
%     dist_km = (2 * pi * Re * cosd(lat)) * (delta_lon_deg / 360);
%     inter_plane_dists(i) = dist_km;
% 
%     % 2. Calculate Overlap Area (Circle Intersection)
%     % Two circles with radius R, separated by distance d
%     R = sat_coverage_radius_km;
%     d = dist_km;
% 
%     if d >= 2*R
%         area_overlap = 0; % No overlap
%     else
%         % Formula for area of intersection between two equal circles
%         % A = 2 * R^2 * acos(d / 2R) - (d / 2) * sqrt(4R^2 - d^2)
%         term1 = 2 * R^2 * acos(d / (2 * R));
%         term2 = (d / 2) * sqrt(4 * R^2 - d^2);
%         area_overlap = term1 - term2;
%     end
% 
%     % 3. Calculate Overlap Ratio (%)
%     % Ratio of overlap area to the total area of one satellite coverage
%     overlap_ratios(i) = (area_overlap / sat_coverage_area_km2) * 100;
% end
% 
% %% 3. Visualization
% figure('Color', 'w', 'Position', [100, 100, 1000, 500]);
% 
% % [Subplot 1] Inter-plane Distance
% subplot(1, 2, 1);
% plot(latitudes, inter_plane_dists, 'b-', 'LineWidth', 2);
% grid on;
% hold on;
% yline(2 * sat_coverage_radius_km, 'r--', 'LineWidth', 2, 'Label', 'Collision Threshold (2*R)');
% xlabel('Latitude (deg)', 'FontSize', 12, 'FontWeight', 'bold');
% ylabel('Inter-Plane Distance (km)', 'FontSize', 12, 'FontWeight', 'bold');
% title('Orbital Convergence', 'FontSize', 14);
% legend('Inter-Plane Distance', 'Overlap Start Threshold', 'Location', 'southwest');
% 
% % [Subplot 2] Overlap Ratio (%)
% subplot(1, 2, 2);
% plot(latitudes, overlap_ratios, 'r-', 'LineWidth', 2);
% grid on;
% xlabel('Latitude (deg)', 'FontSize', 12, 'FontWeight', 'bold');
% ylabel('Beam Overlap Ratio (%)', 'FontSize', 12, 'FontWeight', 'bold');
% title('Severity of Beam Overlap', 'FontSize', 14);
% ylim([0 100]);
% 
% % Highlight specific points for the Response Letter
% idx_mid = find(latitudes == 45);
% idx_high = find(latitudes == 60);
% idx_polar = find(latitudes == 75);
% 
% hold on;
% % 45도: Yellow ('y')
% plot(latitudes(idx_mid), overlap_ratios(idx_mid), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
% text(latitudes(idx_mid), overlap_ratios(idx_mid)+5, sprintf('45deg: %.1f%%', overlap_ratios(idx_mid)));
% 
% % 60도: Orange (RGB: [1 0.5 0]) - 수정됨
% plot(latitudes(idx_high), overlap_ratios(idx_high), 'ko', 'MarkerFaceColor', [1 0.5 0], 'MarkerSize', 8);
% text(latitudes(idx_high), overlap_ratios(idx_high)+5, sprintf('60deg: %.1f%%', overlap_ratios(idx_high)));
% 
% % 75도: Red ('r')
% plot(latitudes(idx_polar), overlap_ratios(idx_polar), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
% text(latitudes(idx_polar), overlap_ratios(idx_polar)+5, sprintf('75deg: %.1f%%', overlap_ratios(idx_polar)));
% 
% sgtitle('Quantitative Analysis of High-Latitude Beam Overlap', 'FontSize', 16, 'FontWeight', 'bold');

% =========================================================================
% Script: LEO_Overlap_Seamless_Coverage_Analysis.m
% Purpose: To demonstrate beam overlap increasing from the mid-latitude
%          assuming a 'Seamless Coverage' system model design.
% =========================================================================

clear; clc; close all;

%% 1. System Parameters (논문 파라미터)
h_sat = 600;                % Satellite altitude (km)
Re = 6371;                  % Earth radius (km)
HPBW_deg = 4.4127;          % 3dB Beamwidth (degrees)

% -------------------------------------------------------------------------
% [핵심 수정] 궤도면 개수 자동 계산 (Auto-Calibration)
% 사용자 의도: "중위도 지역에서 이미 셀이 ISD 간격으로 딱 맞게 되어 있어야 함"
% 따라서, 기준 위도(Reference Latitude, 예: 30도)에서
% '궤도 간 거리' == '위성 커버리지 지름'이 되도록 Num_Planes를 역산합니다.
% -------------------------------------------------------------------------
ref_lat = 30; % 기준 위도 (이곳에서 Seamless Coverage 형성)

% 1. 위성 1개의 커버리지 지름 계산
% (Beam 반지름 * 3배 가정 -> 위성 전체 커버리지)
beam_radius_km = h_sat * tand(HPBW_deg / 2);
sat_coverage_radius_km = 3.0 * beam_radius_km; 
sat_diameter_km = 2 * sat_coverage_radius_km; % 이것이 목표 ISD

% 2. 기준 위도에서의 지구 둘레
circumference_at_ref = 2 * pi * Re * cosd(ref_lat);

% 3. 필요한 궤도면 개수 역산 (빈틈없이 채우기 위해)
Num_Planes = round(circumference_at_ref / sat_diameter_km);

fprintf('------------------------------------------------\n');
fprintf('System Design Auto-Calibration:\n');
fprintf('  - Target Coverage Diameter: %.2f km\n', sat_diameter_km);
fprintf('  - Designed for Seamless Coverage at Lat: %d deg\n', ref_lat);
fprintf('  - Calculated Required Orbital Planes: %d planes\n', Num_Planes);
fprintf('------------------------------------------------\n');

sat_coverage_area_km2 = pi * sat_coverage_radius_km^2;

%% 2. Continuous Calculation across Latitudes
latitudes = 0:1:80; 
inter_plane_dists = zeros(size(latitudes));
overlap_ratios = zeros(size(latitudes));

delta_lon_deg = 360 / Num_Planes; 

for i = 1:length(latitudes)
    lat = latitudes(i);
    
    % 1. Calculate Physical Inter-plane Distance
    dist_km = (2 * pi * Re * cosd(lat)) * (delta_lon_deg / 360);
    inter_plane_dists(i) = dist_km;
    
    % 2. Calculate Overlap Area
    R = sat_coverage_radius_km;
    d = dist_km;
    
    if d >= 2*R
        area_overlap = 0; 
    else
        % Overlap Formula
        term1 = 2 * R^2 * acos(d / (2 * R));
        term2 = (d / 2) * sqrt(4 * R^2 - d^2);
        area_overlap = term1 - term2;
    end
    
    % 3. Calculate Overlap Ratio (%)
    overlap_ratios(i) = (area_overlap / sat_coverage_area_km2) * 100;
end

%% 3. Visualization
figure('Color', 'w', 'Position', [100, 100, 1000, 500]);

% [Subplot 1] Inter-plane Distance vs Coverage Threshold
subplot(1, 2, 1);
plot(latitudes, inter_plane_dists, 'b-', 'LineWidth', 2);
hold on;
yline(sat_diameter_km, 'r--', 'LineWidth', 2, 'Label', 'Ideal ISD (2*R)');

% 기준 위도 표시
xline(ref_lat, 'k:', 'LineWidth', 1.5);
text(ref_lat+2, sat_diameter_km + 20, 'Design Point (Seamless)', 'FontSize', 10);

grid on;
xlabel('Latitude (deg)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Inter-Plane Distance (km)', 'FontSize', 12, 'FontWeight', 'bold');
title('ISD Reduction due to Orbital Convergence', 'FontSize', 14);
legend('Physical Distance', 'Coverage Diameter', 'Location', 'southwest');

% [Subplot 2] Overlap Ratio (%)
subplot(1, 2, 2);
plot(latitudes, overlap_ratios, 'r-', 'LineWidth', 2);
grid on;
xlabel('Latitude (deg)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Beam Overlap Ratio (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('Increasing Severity of Overlap', 'FontSize', 14);
ylim([0 60]); % 범위 조정

% Highlight specific points
idx_ref = find(latitudes == ref_lat);
idx_mid = find(latitudes == 60);
idx_high = find(latitudes == 80);

hold on;
plot(latitudes(idx_ref), overlap_ratios(idx_ref), 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
text(latitudes(idx_ref), overlap_ratios(idx_ref)+3, sprintf('Ref(%d^o): %.1f%%', ref_lat, overlap_ratios(idx_ref)));

plot(latitudes(idx_mid), overlap_ratios(idx_mid), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
text(latitudes(idx_mid), overlap_ratios(idx_mid)+3, sprintf('High(%d^o): %.1f%%', 60, overlap_ratios(idx_mid)));

plot(latitudes(idx_high), overlap_ratios(idx_high), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
text(latitudes(idx_high), overlap_ratios(idx_high)+3, sprintf('Polar(%d^o): %.1f%%', 80, overlap_ratios(idx_high)));

sgtitle('Impact of Latitude on Optimized NTN Constellation', 'FontSize', 16, 'FontWeight', 'bold');
