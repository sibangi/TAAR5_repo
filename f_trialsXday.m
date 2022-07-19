
function [n_trials, n_trials_light, n_trials_dark] = f_trialsXday(Behav)
%% Behav is a 3 column matrix containing start time, end time and outcome 
% for each trial
% this function returns the absolute number of trials per day and for each
% phase light and dark

    tstart = floor(Behav(:,1));

    TimeInitday = find(rem(tstart,24)==19);
    ind_daystart = find(diff(TimeInitday)>1);
    TimeInitLight = find(rem(tstart,24)<7);
    ind_lightstart = find(diff(TimeInitLight)>1);

    startday = [TimeInitday(1); TimeInitday(ind_daystart + 1)];
    startlight = [TimeInitLight(1); TimeInitLight(ind_lightstart + 1)];

    n_trials = zeros(1,length(startday)-1);
    n_trials_light = zeros(1,length(startday)-1);
    n_trials_dark = zeros(1,length(startday)-1);
    for sd = 1:length(startday)-1
        n_trials(sd) = length(Behav(startday(sd):startday(sd+1)-1,3)); %(startday(sd+1)-startday(sd));
        if sd == 1
            n_trials_light(sd) = length(Behav(1:startday(sd)-1,3)); %(startday(sd)-1);          
        else
            n_trials_light(sd) = length(Behav(startlight(sd-1):startday(sd)-1,3)); %(startday(sd+1)-startlight(sd));
        end
        n_trials_dark(sd) = length(Behav(startday(sd):startlight(sd+1)-1,3)); %(startlight(sd)-startday(sd));
    end

return