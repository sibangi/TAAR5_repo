% This function compute the ITI duration and record start and stop of each
% ITI

% load Cage_2_Matlab_M2C57m.csv;
% Datas = Cage_2_Matlab_M2C57m;
% t0=3;
% t1=6;

function [ITI] = f_ITIduration(Datas)

    second = find(Datas(:,2)==6,1,'first');
    Minute = find(Datas(:,2)==5,1,'first');
    hour = find(Datas(:,2)==4,1,'first');
    Second_start = Datas(second,1);
    Minute_start = Datas(Minute,1);
    Hour_start = Datas(hour,1);
    Start_time = (Hour_start*3600)+(Minute_start*60)+Second_start; 

    Data(:,1) = Datas(:,1)/1000;
    Data(:,2) = Datas(:,2);

    TrialOnset = find(Data(:,2)==19);
    TrialOffset = find(Data(:,2)==33);
    
%     % If the session ends without finalizing the trial then the last 
%     % trial onset will be cleared to meet the same number of rows
%     if length(TrialOnset)>length(TrialOffset)
%         TrialOnset(end,:)=[];
%     end

    hourStartAll = zeros(length(TrialOffset)-1,1); 
    hourEndAll = zeros(length(TrialOffset)-1,1); 
    ITIduration = zeros(length(TrialOffset)-1,1); 
%     reward = zeros(length(TrialOnset),1);
    for tr = 2:length(TrialOnset)
        % collect the start time for all the trials (regardless outcome)
        InTr = Data(TrialOffset(tr-1),1);
        hourStartAll(tr-1) = (InTr+Start_time)/3600;
        % collect the stop time for all the trials (regardless outcome)
        EndTr = Data(TrialOnset(tr),1);
        hourEndAll(tr-1) = (EndTr+Start_time)/3600;
%         ITIduration(tr) = hourEndAll(tr)-hourStartAll(tr);
        ITIduration(tr-1) = EndTr-InTr;
%         % check if that trial is rewarded or not
%         clear ind_rew
%         ind_rew = find((Data(TrialOnset(tr):TrialOffset(tr),2)==29) | ...
%             (Data(TrialOnset(tr):TrialOffset(tr),2)==30) | (Data(TrialOnset(tr):TrialOffset(tr),2)==35));
%         if length(ind_rew)>1
%             return
%         elseif length(ind_rew)==1
%             Reward(tr) = 1;
%         elseif isempty(ind_rew)
%             Reward(tr) = 0;
%         end
        
%         if find(Data(TrialOnset(tr):TrialOffset(tr),2)==35)
%             print('Probe trials')
%         end

    end

    ITI = [hourStartAll hourEndAll ITIduration];
    
    return
    