
function [performance, performance_light, performance_dark] = f_performance(Behav, nargin)

    tstart = floor(Behav(:,1));

    TimeInitday = find(rem(tstart,24)==19);
    ind_daystart = find(diff(TimeInitday)>1);
    TimeInitLight = find(rem(tstart,24)<7);
    ind_lightstart = find(diff(TimeInitLight)>1);

    startday = [TimeInitday(1); TimeInitday(ind_daystart + 1)];
    startlight = [TimeInitLight(1); TimeInitLight(ind_lightstart + 1)];

    performance = zeros(1,length(startday)-1);
    performance_light = zeros(1,length(startday)-1);
    performance_dark = zeros(1,length(startday)-1);
    for sd = 1:length(startday)-1
        if isempty(nargin)
            performance(sd) = sum(Behav(startday(sd):startday(sd+1)-1,3))/...
                length(Behav(startday(sd):startday(sd+1)-1,3)); %(startday(sd+1)-startday(sd));
            if sd == 1
                performance_light(sd) = sum(Behav(1:startday(sd)-1,3))/...
                    length(Behav(1:startday(sd)-1,3)); %(startday(sd)-1);          
            else
                performance_light(sd) = sum(Behav(startlight(sd-1):startday(sd)-1,3))/...
                    length(Behav(startlight(sd-1):startday(sd)-1,3)); %(startday(sd+1)-startlight(sd));
            end
            performance_dark(sd) = sum(Behav(startday(sd):startlight(sd+1)-1,3))/...
                length(Behav(startday(sd):startlight(sd+1)-1,3)); %(startlight(sd)-startday(sd));
        elseif strcmp(nargin, 'Error')
            performance(sd) = sum(Behav(startday(sd):startday(sd+1)-1,3)==0)/...
                length(Behav(startday(sd):startday(sd+1)-1,3)); %(startday(sd+1)-startday(sd));
            if sd == 1
                performance_light(sd) = sum(Behav(1:startday(sd)-1,3)==0)/...
                    length(Behav(1:startday(sd)-1,3)); %(startday(sd)-1);          
            else
                performance_light(sd) = sum(Behav(startlight(sd-1):startday(sd)-1,3)==0)/...
                    length(Behav(startlight(sd-1):startday(sd)-1,3)); %(startday(sd+1)-startlight(sd));
            end
            performance_dark(sd) = sum(Behav(startday(sd):startlight(sd+1)-1,3)==0)/...
                length(Behav(startday(sd):startlight(sd+1)-1,3)); %(startlight(sd)-startday(sd));
        else
            disp('Error:non existent input argument')
            break
        end
    end

return