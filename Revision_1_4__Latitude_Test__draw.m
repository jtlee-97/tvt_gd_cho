% =========================================================================
% Script: LEO_Overlap_Analysis_RefLat20.m
% Purpose: Analyze beam overlap starting from the seamless design point at 20 deg.
% =========================================================================

clear; clc; close all;

%% 1. System Parameters
h_sat = 600;                % Satellite altitude (km)
Re = 6371;                  % Earth radius (km)
HPBW_deg = 4.4127;          % 3dB Beamwidth (degrees)

% -------------------------------------------------------------------------
% [핵심 수정] 기준 위도(Reference Latitude)를 20도로 변경
% 논리: "3GPP 중위도 구간의 시작점(20도)에서 Seamless Coverage를 형성하도록 설계됨"
% -------------------------------------------------------------------------
ref_lat = 20; 

% 1. 위성 커버리지 지름 (Target ISD)
beam_radius_km = h_sat * tand(HPBW_deg / 2);
sat_coverage_radius_km = 3.0 * beam_radius_km; 
sat_diameter_km = 2 * sat_coverage_radius_km; 

% 2. 기준 위도(20도)에서 필요한 궤도면 개수 역산
circumference_at_ref = 2 * pi * Re * cosd(ref_lat);
Num_Planes = round(circumference_at_ref / sat_diameter_km);

sat_coverage_area_km2 = pi * sat_coverage_radius_km^2;

%% 2. Continuous Calculation (20도 ~ 90도)
latitudes = 20:1:90; % [수정] 저위도(0~19도) 제외하고 20도부터 시작
inter_plane_dists = zeros(size(latitudes));
overlap_ratios = zeros(size(latitudes));

delta_lon_deg = 360 / Num_Planes; 

for i = 1:length(latitudes)
    lat = latitudes(i);
    
    % Physical Inter-plane Distance
    dist_km = (2 * pi * Re * cosd(lat)) * (delta_lon_deg / 360);
    inter_plane_dists(i) = dist_km;
    
    % Overlap Calculation
    R = sat_coverage_radius_km;
    d = dist_km;
    
    if d >= 2*R
        area_overlap = 0; 
    else
        term1 = 2 * R^2 * acos(d / (2 * R));
        term2 = (d / 2) * sqrt(4 * R^2 - d^2);
        area_overlap = term1 - term2;
    end
    
    overlap_ratios(i) = (area_overlap / sat_coverage_area_km2) * 100;
end

%% 3. Visualization
figure('Color', 'w', 'Position', [100, 100, 1000, 500]);

% [Subplot 1] Inter-plane Distance
subplot(1, 2, 1);
plot(latitudes, inter_plane_dists, 'b-', 'LineWidth', 2);
hold on;
yline(sat_diameter_km, 'r--', 'LineWidth', 2, 'Label', 'Ideal ISD (Seamless)');

% 디자인 포인트 강조 (20도)
xline(ref_lat, 'k:', 'LineWidth', 1.5);
text(ref_lat+2, sat_diameter_km - 10, 'Design Point (20^{\circ})', 'FontSize', 10, 'FontWeight', 'bold');

grid on;
xlim([20 90]); % X축 범위를 20도부터 보여줌
xlabel('Latitude (deg)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Inter-Plane Distance (km)', 'FontSize', 12, 'FontWeight', 'bold');
title('Orbital Convergence from Mid-Latitude', 'FontSize', 14);
legend('Physical Distance', 'Coverage Diameter', 'Location', 'southwest');

% [Subplot 2] Overlap Ratio
subplot(1, 2, 2);
plot(latitudes, overlap_ratios, 'r-', 'LineWidth', 2);
grid on;
xlim([20 90]); % X축 범위를 20도부터 보여줌
xlabel('Latitude (deg)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Beam Overlap Ratio (%)', 'FontSize', 12, 'FontWeight', 'bold');
title('Increasing Severity of Overlap', 'FontSize', 14);

% Highlight specific points
idx_ref = find(latitudes == ref_lat);
idx_mid = find(latitudes == 60);
idx_high = find(latitudes == 80);

hold on;
plot(latitudes(idx_ref), overlap_ratios(idx_ref), 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 8);
text(latitudes(idx_ref)+2, overlap_ratios(idx_ref)+2, sprintf('Start(%d^o): 0.0%%', ref_lat));

plot(latitudes(idx_mid), overlap_ratios(idx_mid), 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8);
text(latitudes(idx_mid)-15, overlap_ratios(idx_mid), sprintf('Mid-End(%d^o): %.1f%%', 60, overlap_ratios(idx_mid)));

plot(latitudes(idx_high), overlap_ratios(idx_high), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 8);
text(latitudes(idx_high)-15, overlap_ratios(idx_high), sprintf('Polar(%d^o): %.1f%%', 80, overlap_ratios(idx_high)));

sgtitle('Quantitative Analysis of Beam Overlap (20^{\circ}-90^{\circ})', 'FontSize', 16, 'FontWeight', 'bold');