% % =================================================================
% % Winner LAB, Ajou University
% % Distance-based HO Parameter Optimization Protocol Code
% % Prototype    : MTD_A3_CHO.m
% % Type         : MATLAB function Code
% % Author       : Jongtae Lee
% % Revision     : v1.0   2024.06.04
% % Modified     : 2024.06.04
% % =================================================================

% function ue = MTD_A3_CHO_rev(ue, Offset_A3, TTT, current_time)
%     handover = ue.handover;
%     PD = (600000 / 3e8);  % 빛의 속도(m/s)를 기준으로 한 1-way 전파 지연 시간(0.02, 2 ms)
% 
%     % Entering conditions: RSRP_FILTERED 기반 핸드오버 결정
%     cond1_enter = ue.RSRP_FILTERED(ue.SERV_SITE_IDX) + Offset_A3 < ue.RSRP_FILTERED;
%     cond2_t_enter = false;
% 
%     if handover.targ_idx > 0
%         cond2_t_enter = ue.RSRP_FILTERED(ue.SERV_SITE_IDX) + Offset_A3 < ue.RSRP_FILTERED(handover.targ_idx);
%     end
% 
%     % Handover decision algorithm
%     if ~handover.preparation_state && ~handover.execution_state
%         if any(cond1_enter)
%             ue.RBs = ue.RBs + 1; % MR에 대한 RB 추가
%             % 조건이 처음으로 만족되면 TTT 체크 변수 생성
%             if handover.TTT_check == 0
%                 ue.handover.TTT_check = current_time;
%             end
% 
%             % 가장 높은 RSRP_FILTERED 값을 가진 후보 셀 선택
%             valid_indices = find(cond1_enter);
%             [~, max_idx] = max(ue.RSRP_FILTERED(valid_indices));
%             new_site_idx = valid_indices(max_idx);
% 
%             if new_site_idx ~= ue.SERV_SITE_IDX
%                 % TTT 조건 충족 시 핸드오버 준비
%                 if current_time - ue.handover.TTT_check >= TTT
%                     ue.handover = handover.initiate_preparation(current_time, new_site_idx);
%                     ue.RBs = ue.RBs + 2; % CMD에 대한 RB 추가
%                     if ue.RSRP_FILTERED(ue.SERV_SITE_IDX) < -120  % 임계값 예시
%                         ue.RLF = ue.RLF + 1; % RLF 증가
%                     end
%                 end
%             end
%         else
%             ue.handover.TTT_check = 0;
%         end
% 
%     elseif handover.preparation_state && ~handover.execution_state
%         if cond2_t_enter
%             if handover.exec_TTT_check == 0
%                 ue.handover.exec_TTT_check = current_time;
%             end
%             if current_time - ue.handover.exec_TTT_check >= 0
%                 % 핸드오버 실행
%                 ue.handover = handover.initiate_execution(current_time);
%                 ue.SERV_SITE_IDX = handover.targ_idx;
%                 ue.HO = ue.HO + 1;
%                 ue.RBs = ue.RBs + 6; % RA에 대한 RB 추가
%                 ue.RBs = ue.RBs + 1; % CF에 대한 RB 추가
%                 ue.handover = handover.reset(handover.targ_idx);
%             end
%         else
%             % 조건 불충분 시 리셋
%             ue.handover.exec_TTT_check = 0;
%             ue.handover = handover.reset(handover.targ_idx);
%         end
%     end
% end



% % function ue = MTD_A3_CHO_rev(ue, Offset_A3, TTT, current_time)
% %     handover = ue.handover;
% %     PD = (600000 / 3e8);  % 전파 지연 시간 (2ms)
% % 
% %     % Entering condition
% %     cond1_enter = ue.RSRP_dBm(ue.SERV_SITE_IDX) + Offset_A3 < ue.RSRP_dBm;
% % 
% %     % 조건식 업데이트
% %     cond2_t_enter = false;
% %     if handover.targ_idx > 0
% %         cond2_t_enter = ue.RSRP_dBm(ue.SERV_SITE_IDX) + Offset_A3 < ue.RSRP_dBm(handover.targ_idx);
% %     end
% % 
% %     % Handover decision algorithm
% %     if ~handover.preparation_state && ~handover.execution_state
% %         % Preparation 단계: 후보 셀 저장
% %         if any(cond1_enter)
% %             valid_indices = find(cond1_enter);
% %             valid_indices(valid_indices == ue.SERV_SITE_IDX) = [];  % 서빙 셀 제외
% %             ue.handover = handover.update_valid_indices(valid_indices);  % valid_indices 저장
% % 
% %             % TTT 체크 변수 생성
% %             if handover.TTT_check == 0
% %                 ue.handover.TTT_check = current_time;  % TTT 체크 시작
% %             end
% %         else
% %             % 조건이 만족되지 않으면 TTT 체크 초기화
% %             ue.handover.TTT_check = 0;
% %         end
% % 
% %     elseif handover.preparation_state && ~handover.execution_state
% %         % Preparation 이후, execution 상태로 진입
% % 
% %         % 저장된 valid_indices를 불러오기
% %         valid_indices = handover.valid_indices;
% % 
% %         % 다시 조건이 맞는지 확인
% %         cond1_enter = ue.RSRP_dBm(valid_indices) > ue.RSRP_dBm(ue.SERV_SITE_IDX) + Offset_A3;
% %         valid_indices = valid_indices(cond1_enter);  % 조건을 만족하지 않는 셀 제외
% % 
% %         if ~isempty(valid_indices)
% %             % 가장 좋은 셀 선택 (RSRP가 가장 큰 셀 선택)
% %             [~, max_idx] = max(ue.RSRP_dBm(valid_indices));
% %             new_site_idx = valid_indices(max_idx);
% % 
% %             if new_site_idx ~= ue.SERV_SITE_IDX
% %                 % TTT 조건이 만족되면 핸드오버 실행
% %                 if current_time - ue.handover.TTT_check >= TTT
% %                     ue.handover = handover.initiate_preparation(current_time, new_site_idx);
% %                 end
% %             end
% %         else
% %             % 조건이 만족되지 않으면 TTT 체크 초기화
% %             ue.handover.TTT_check = 0;
% %             ue.handover = handover.reset_valid_indices();  % 후보 셀 초기화
% %         end
% % 
% %         % 핸드오버 조건 확인 및 실행
% %         if cond2_t_enter
% %             if handover.exec_TTT_check == 0
% %                 ue.handover.exec_TTT_check = current_time;
% %             end
% %             if current_time - ue.handover.exec_TTT_check >= 0
% %                 % 핸드오버 실행
% %                 ue.handover = handover.initiate_execution(current_time);
% %                 ue.SERV_SITE_IDX = handover.targ_idx;  % 실제 핸드오버 수행
% %                 ue.HO = ue.HO + 1;  % HO 횟수 증가
% %                 ue.handover = handover.reset(handover.targ_idx);  % 핸드오버 상태 리셋
% %             end
% %         else
% %             % 조건이 만족되지 않으면 exec_TTT_check 초기화 및 상태 리셋
% %             ue.handover.exec_TTT_check = 0;
% %             ue.handover = handover.reset(handover.targ_idx);
% %             if ue.SINR < -6
% %                 ue.RLF = ue.RLF + 1;  % RLF 증가
% %             end
% %         end
% %     end
% % end
% 
% 
% % %% A3-based HO in EMC
% % function ue = MTD_A3_CHO_rev(ue, Offset_A3, TTT, current_time)
% %     handover = ue.handover;
% %     % prep_delay = 5 * 0.002;
% %     % exec_delay = 3 * 0.002;
% %     PD = (600000 / 3e8);  % 빛의 속도(m/s)를 기준으로 한 1-way 전파 지연 시간(0.02, 2 ms)
% % 
% %     % Entering conditions
% %     cond1_enter = ue.RSRP_dBm(ue.SERV_SITE_IDX) < ue.RSRP_dBm;
% %     cond2_t_enter = false;
% % 
% %     if handover.targ_idx > 0
% %         cond2_t_enter = ue.RSRP_dBm(ue.SERV_SITE_IDX) + Offset_A3 < ue.RSRP_dBm(handover.targ_idx);
% %     end
% % 
% %     % Handover decision algorithm
% %     if ~handover.preparation_state && ~handover.execution_state
% %         if any(ue.RSRP_dBm(ue.SERV_SITE_IDX) < ue.RSRP_dBm)
% %             ue.RBs = ue.RBs + 1; % MR에 대한 RB 추가
% %             % 조건이 처음으로 만족되면 TTT 체크 변수 생성
% %             if handover.TTT_check == 0
% %                 ue.handover.TTT_check = current_time; % 수정: ue.handover로 접근
% %             end
% %             % Find the RSRP_dBm index with the highest value satisfying the condition
% %             valid_indices = find(ue.RSRP_dBm(ue.SERV_SITE_IDX) < ue.RSRP_dBm);
% %             [~, max_idx] = max(ue.RSRP_dBm(valid_indices));
% %             new_site_idx = valid_indices(max_idx);
% % 
% %             if new_site_idx ~= ue.SERV_SITE_IDX
% %                 % Check if the conditions are satisfied for TTT
% %                 if current_time - ue.handover.TTT_check >= TTT
% %                     ue.handover = handover.initiate_preparation(current_time, new_site_idx);
% %                     ue.RBs = ue.RBs + 2; % CMD에 대한 RB 추가
% %                     if ue.SINR < -8
% %                         ue.RLF = ue.RLF + 1;
% %                     end
% %                 end
% %             end
% %         else
% %             % 조건이 만족되지 않으면 TTT 체크 변수 초기화 및 RLF 증가
% %             ue.handover.TTT_check = 0; % 수정: ue.handover로 접근
% %         end
% % 
% %     elseif handover.preparation_state && ~handover.execution_state
% %         if cond2_t_enter
% %             if handover.exec_TTT_check == 0
% %                 ue.handover.exec_TTT_check = current_time; % 수정: ue.handover로 접근
% %             end
% %             if current_time - ue.handover.exec_TTT_check >= 0
% %                 ue.handover = handover.initiate_execution(current_time);
% %                 ue.SERV_SITE_IDX = handover.targ_idx;  % Perform the handover
% %                 ue.HO = ue.HO + 1;
% %                 % ue.RBs = ue.RBs + 2; % CMD에 대한 RB 추가
% %                 ue.RBs = ue.RBs + 6; % RA에 대한 RB 추가
% %                 ue.RBs = ue.RBs + 1; % CF에 대한 RB 추가
% %                 ue.handover = handover.reset(handover.targ_idx);  % Reset the handover state
% %             end
% %         else
% %             % 조건이 만족되지 않으면 exec_TTT_check 변수 초기화 및 RLF 증가
% %             ue.handover.exec_TTT_check = 0; % 수정: ue.handover로 접근
% %             ue.handover = handover.reset(handover.targ_idx);  % Reset the handover state
% %             if ue.SINR < -6
% %                 ue.RLF = ue.RLF + 1;
% %             end
% %         end
% %     end
% % end
% 
%% A3-based HO in EMC (SINR, RSRP)
function ue = MTD_A3_CHO_rev(ue, Offset_A3, TTT, current_time)
    handover = ue.handover;
    % prep_delay = 5 * 0.002;
    % exec_delay = 3 * 0.002;
    PD = (600000 / 3e8);  % 빛의 속도(m/s)를 기준으로 한 1-way 전파 지연 시간(0.02, 2 ms)

    % Entering conditions (RSRP_FILTERD 버전)
    cond1_enter = ue.RSRP_FILTERED(ue.SERV_SITE_IDX) + Offset_A3 < ue.RSRP_FILTERED;
    cond2_t_enter = false;

    if handover.targ_idx > 0
        cond2_t_enter = ue.RSRP_FILTERED(ue.SERV_SITE_IDX) + Offset_A3 < ue.RSRP_FILTERED(handover.targ_idx);
    end
    
    % % Entering conditions (SINR 버전)
    % % cond1_enter = ue.SINR(ue.SERV_SITE_IDX) < ue.SINR; % K-filter 사용 X
    % cond1_enter = ue.SINR_AVG(ue.SERV_SITE_IDX) < ue.SINR_AVG; % K-filter 사용 시 
    % 
    % cond2_t_enter = false;
    % 
    % if handover.targ_idx > 0
    %     cond2_t_enter = ue.SINR(ue.SERV_SITE_IDX) + Offset_A3 < ue.SINR(handover.targ_idx);
    % end

    % Handover decision algorithm
    if ~handover.preparation_state && ~handover.execution_state
        %if any(ue.SINR(ue.SERV_SITE_IDX) < ue.SINR)
        if any(ue.RSRP_FILTERED(ue.SERV_SITE_IDX) < ue.RSRP_FILTERED)
            ue.RBs = ue.RBs + 1; % MR에 대한 RB 추가
            % 조건이 처음으로 만족되면 TTT 체크 변수 생성
            if handover.TTT_check == 0
                ue.handover.TTT_check = current_time; % 수정: ue.handover로 접근
            end
            % Find the RSRP_dBm index with the highest value satisfying the condition
            % valid_indices = find(ue.SINR(ue.SERV_SITE_IDX) < ue.SINR);
            valid_indices = find(ue.RSRP_FILTERED(ue.SERV_SITE_IDX) < ue.RSRP_FILTERED);
            %[~, max_idx] = max(ue.SINR(valid_indices));
            [~, max_idx] = max(ue.RSRP_FILTERED(valid_indices));
            new_site_idx = valid_indices(max_idx);

            if new_site_idx ~= ue.SERV_SITE_IDX
                % Check if the conditions are satisfied for TTT
                if current_time - ue.handover.TTT_check >= TTT
                    ue.handover = handover.initiate_preparation(current_time, new_site_idx);
                    ue.RBs = ue.RBs + 2; % CMD에 대한 RB 추가
                    if ue.SINR(ue.SERV_SITE_IDX) < -8
                        ue.RLF = ue.RLF + 1;
                    end
                end
            end
        else
            % 조건이 만족되지 않으면 TTT 체크 변수 초기화 및 RLF 증가
            ue.handover.TTT_check = 0; % 수정: ue.handover로 접근
        end

    elseif handover.preparation_state && ~handover.execution_state
        if cond2_t_enter
            if handover.exec_TTT_check == 0
                ue.handover.exec_TTT_check = current_time; % 수정: ue.handover로 접근
            end
            if current_time - ue.handover.exec_TTT_check >= 0
                ue.handover = handover.initiate_execution(current_time);
                ue.SERV_SITE_IDX = handover.targ_idx;  % Perform the handover
                ue.HO = ue.HO + 1;
                % ue.RBs = ue.RBs + 2; % CMD에 대한 RB 추가
                ue.RBs = ue.RBs + 6; % RA에 대한 RB 추가
                ue.RBs = ue.RBs + 1; % CF에 대한 RB 추가
                ue.handover = handover.reset(handover.targ_idx);  % Reset the handover state
            end
        else
            % 조건이 만족되지 않으면 exec_TTT_check 변수 초기화 및 RLF 증가
            ue.handover.exec_TTT_check = 0; % 수정: ue.handover로 접근
            ue.handover = handover.reset(handover.targ_idx);  % Reset the handover state
            % if ue.SINR(ue.SERV_SITE_IDX) < -6
            %     ue.RLF = ue.RLF + 1;
            % end
        end
    end
end