% =================================================================
% Winner LAB, Ajou University
% Distance-based HO Parameter Optimization Protocol Code
% Prototype    : class_SAT.m
% Type         : MATLAB Class
% Author       : Jongtae Lee
% Revision     : v1.0   2024.06.04
% Modified     : 2024.07.01
% =================================================================
classdef class_SAT
    properties
        BORE_X
        BORE_Y
        cond_BORE_X
        cond_BORE_Y
        
        % 군집 위성 추가
        Sat1_X
        Sat1_Y
        Sat2_X
        Sat2_Y

        OFFSET_SAT1_X = 0;
        OFFSET_SAT1_Y = 0;
        OFFSET_SAT2_X = -15000;
        OFFSET_SAT2_Y = 0;

        ALTITUDE_SAT1 = 600000;
        ALTITUDE_SAT2 = 700000;

        TX_GAIN                 % dBi [Set1-600: Tx antenna max gain]
        APERATURE               % meter [Set1-600: Antenna Aperture]
        EIRP                    % dBW/MHz [Set1-600: EIRP density]
        ALTITUDE                % 600 km [Altitude]
       
        HPBW_3 = 4.4127;        % degree [Half Power Beamwidth 3 dB angle]
        SAT_SPEED = 7560;       % Satellite Speed (7.56 km/s)
        TXPW_dBm                % Transmit Power [dBm]
        TXPW_watt               % Transmit Power [W]
        TXPW_mwatt              % Transmit Power [mW]
    end
    
    methods
        function obj = class_SAT()
            % Load parameters from system_parameter.m
            run('system_parameter.m');
            
            % Assign values to properties
            obj.TX_GAIN = Tx_g;
            obj.APERATURE = AP;
            obj.EIRP = eirp;
            % obj.ALTITUDE = altit;

            % Initialize BORE_X and BORE_Y with values from system_61_site.m
            obj = obj.reset_SAT();

            % Satellite Power Calculation
            obj.TXPW_dBm = obj.EIRP + 30 + 10 * log10(20) - 30;   % LTE based on a 20MHz bandwidth [dBm]
            obj.TXPW_watt = 1 * 10^(obj.TXPW_dBm / 10) / 1000;    % convert dBm to watt [W]
            obj.TXPW_mwatt = 10^(obj.TXPW_dBm / 10);              % convert dBm to mili watt [mW]
        end

        function obj = reset_SAT(obj)
            % Re-load parameters from system_parameter.m
            run('system_parameter.m');
            
            % Re-assign values to properties
            obj.TX_GAIN = Tx_g;
            obj.APERATURE = AP;
            obj.EIRP = eirp;
            % obj.ALTITUDE = altit;

            % Reset BORE_X and BORE_Y with values from system_61_site.m
            run("system_61_site.m");

            obj.Sat1_X = x' + obj.OFFSET_SAT1_X;
            obj.Sat1_Y = y' + obj.OFFSET_SAT1_Y;

            obj.Sat2_X = x' + obj.OFFSET_SAT2_X;
            obj.Sat2_Y = y' + obj.OFFSET_SAT2_Y;

            obj.BORE_X = [obj.Sat1_X, obj.Sat2_X];
            obj.BORE_Y = [obj.Sat2_X, obj.Sat2_Y];

            alt_vec1 = repmat(obj.ALTITUDE_SAT1, 1, length(obj.Sat1_X));
            alt_vec2 = repmat(obj.ALTITUDE_SAT2, 1, length(obj.Sat2_X));

            obj.ALTITUDE = [alt_vec1, alt_vec2];
        end

        % === [중요] 위성 이동 함수 (시뮬레이션 루프에서 호출) ===
        function obj = move_satellites(obj, move_distance)
            % 군집 1: Y축 방향으로 이동
            obj.Sat1_Y = obj.Sat1_Y + move_distance;

            % 군집 2: X축 방향으로 이동 (Cross-orbit)
            obj.Sat2_Y = obj.Sat2_Y + move_distance;

            % 이동 후 전체 좌표 업데이트
            obj.BORE_X = [obj.Sat1_X, obj.Sat2_X];
            obj.BORE_Y = [obj.Sat1_Y, obj.Sat2_Y];
        end

    end
end
