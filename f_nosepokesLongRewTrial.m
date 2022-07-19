% Silvia Maggi
% October 2020
% This function return the right and left nosepokes only for the long 
% rewarded trials with nosepokes in both location.

function [nosepoke_LongSwitchTrial] = f_nosepokesLongRewTrial(Data,longTrialOn,longTrialOff)

    nosepoke_LongSwitchTrial = cell(length(longTrialOn),2);

    for lg = 1:length(longTrialOn)
        % get all the data within the selected trial
        temporarydata = Data(longTrialOn(lg):longTrialOff(lg),:);

        % Record of the Left nose pokes (short location)
        leftRespOn = find(temporarydata(:,2)==23);  % Left On
        leftRespOff = find(temporarydata(:,2)==24); % Left Off
        % Record of the Right nose pokes (long location)
        rightRespOn = find(temporarydata(:,2)==27);   % Right On  
        rightRespOff = find(temporarydata(:,2)==28);  % Right Off

        % record left (short location) NP for every long rewarded trial.
        % If len(NP in)>len(NP out), the animal poked out after the end of the 
        % trial. Add one NP out at the end of the trial  
        if length(leftRespOn)>length(leftRespOff)
            leftRespOff(end+1)=length(temporarydata); 
        end
        plotLeftOn = temporarydata(leftRespOn,1)-temporarydata(1,1);   % Normalize the times with the trial onset
        plotLeftOff = temporarydata(leftRespOff,1)-temporarydata(1,1); % Ditto

        % record right (long location) NP for every long rewarded trial.
        if length(rightRespOn)>length(rightRespOff)
           rightRespOff(end+1) = length(temporarydata); 
        elseif length(rightRespOff)>length(rightRespOn)
           rightRespOn(2:end+1) = rightRespOn;
           rightRespOn(1)=1;  % If the subject was poking right prior to the trial onset (which is impossible) then replace with 1
        end
        plotRightOn = temporarydata(rightRespOn,1)-temporarydata(1,1);
        plotRightOff = temporarydata(rightRespOff,1)-temporarydata(1,1);

        if (isempty(plotLeftOn)==0 && isempty(plotRightOn)==0)
            nosepoke_LongSwitchTrial{lg,1} = [plotLeftOn plotLeftOff];
            nosepoke_LongSwitchTrial{lg,2} = [plotRightOn plotRightOff];
        end

    end
return