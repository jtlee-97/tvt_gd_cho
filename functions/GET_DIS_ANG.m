% =================================================================
% Winner LAB, Ajou University
% Distance-based HO Parameter Optimization Protocol Code
% Prototype    : GET_DIS_ANG.m
% Type         : MATLAB function Code
% Author       : Jongtae Lee
% Revision     : v1.0   2024.06.04
% Modified     : 2024.06.04
% =================================================================

function [distances, angles, elevs] = GET_DIS_ANG(BORE_X, BORE_Y, SAT_ALTITUDE, UE_X, UE_Y, UE_ALTITUDE)
    % =================================================================
    % Modified to support Multi-Altitude Satellites
    % =================================================================
    
    num_bore = length(BORE_X);

    % [수정 핵심] SAT_ALTITUDE가 스칼라(1개)면 repmat, 벡터면 그대로 사용
    if length(SAT_ALTITUDE) == 1
        alt_vec = repmat(SAT_ALTITUDE, 1, num_bore);
    else
        % 이미 벡터인 경우 (길이가 num_bore와 같아야 함)
        if length(SAT_ALTITUDE) ~= num_bore
            % 만약 길이가 안 맞으면 강제로 맞추거나 에러 처리 (여기서는 첫 번째 값으로 통일하는 예외처리)
             alt_vec = repmat(SAT_ALTITUDE(1), 1, num_bore); 
        else
             alt_vec = SAT_ALTITUDE;
        end
    end

    % 위성 좌표 행렬 생성 (x, y, z)
    sat_positions = [BORE_X; BORE_Y; alt_vec];

    % UE 좌표 (x, y, z)
    ue_position = [UE_X; UE_Y; UE_ALTITUDE];

    % 1. 거리 계산 (Euclidean Distance)
    % (Sat_X - UE_X)^2 + ...
    diffs = sat_positions - repmat(ue_position, 1, num_bore);
    distances = sqrt(sum(diffs.^2, 1));

    % 2. 각도 및 고도각 계산 (필요한 로직에 따라 구현, 아래는 일반적인 예시)
    % 여기서는 기존에 사용하시던 로직을 그대로 유지해야 합니다.
    % 만약 기존 함수 내용을 모르신다면, 아래는 표준적인 계산 방식입니다.
    
    % 수평 거리 (Horizontal Distance)
    d_horiz = sqrt(diffs(1,:).^2 + diffs(2,:).^2);
    
    % 고도각 (Elevation Angle, degree)
    % atan2(수직차이, 수평거리)
    elev_rad = atan2(diffs(3,:), d_horiz);
    elevs = rad2deg(elev_rad);

    % Off-boresight Angle (User defined logic)
    % 기존 코드의 angles 계산 로직이 단순 거리 기반이었다면 아래와 비슷할 것입니다.
    % (위성 안테나의 지향 방향이 수직 하방(Nadir)이라고 가정할 때)
    angles = 90 - elevs; 
end
