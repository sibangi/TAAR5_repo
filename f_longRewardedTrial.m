% Silvia Maggi 
% October 2020
% this function extract information about long rewarded trials in the
% switch task

function [longTrialReward, longTrialOn, longTrialOff] = f_longRewardedTrial(Data)

    trialOnset = find(Data(:,2)==19);  % Middle Light On. This codes for trial onset
    trialOffset = find(Data(:,2)==36); % End of ITI (33). Event code 36 is the start of ITI.

    % If the session ends without finalizing the trial then the last trial onset 
    % will be cleared to meet the same number of rows 
    if length(trialOnset)>length(trialOffset)
        trialOnset(end,:)=[];
    end

    %% ANALYSIS OF LONG TRIALS
    % identify long rewarded trials
    longTrialReward = find(Data(:,2)==30); % find long rewarded trials
    longTrialOn = zeros(size(longTrialReward)); % initialize beginning of long trials
    longTrialOff = zeros(size(longTrialReward)); % initialize beginning of long trials
    % find beginning of long trials
    for i = 1:length(longTrialReward)
        % among the trial onsets the beginning of a long rewarded trial is the 
        % last trialOnset before the longTrialOffset
        indLgOn = find(trialOnset<longTrialReward(i),1,'last');
        longTrialOn(i) = trialOnset(indLgOn);
        % identify the long rewarded trial offset
        indLgOff = find(trialOffset>longTrialReward(i),1,'first');
        longTrialOff(i) = trialOffset(indLgOff);
    end
return
