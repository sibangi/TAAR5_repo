%% this script look at the duration of ITI for each subject along the training
clearvars; close all

nko = 6;
nwt = 6;
koname = 'KO';
wtname = 'WT';
ntype = 2;

group(1:nko) = 1;
group(nko+1:nko+nwt) = 2;

interv = 3;

% figure properties
barsize = [5 5 9 4];
barsize1 = [5 5 4.5 4];
barsize2 = barsize;
siz = 3;
cmap = brewermap(ntype,'Set1');
wtc = cmap(2,:);
koc =  cmap(1,:);
fontsize = 7;
axlinewidth = 0.5;
figpath = 'E:\OneDrive - The University of Nottingham\TAAR5\Figure\';

%% WEEK 1 of training
run('Training 3vs9\Load_data.m');
%% ***************************
%% compute ITI duration
starttime = zeros(length(Datas),1); endtime = zeros(length(Datas),1);
for i = 1: length(Datas)
    [ITI{i}] = f_ITIduration(Datas{i});
    
    starttime(i) = floor(ITI{i}(1,1));
    endtime(i) = floor(ITI{i}(end,1));
    
end

%% compute average ITI duration for each hour/day/LD phase
for i = 1:length(Datas)
    startITI = floor(ITI{i}(:,1));
    for t = max(starttime):min(endtime)
        % average ITI duration for each hour of the training
        meanITI(i,t-max(starttime)+1) = mean(ITI{i}(startITI==t,3));
    end
    hourITI = floor(rem(ITI{i}(:,1),24));
    for h = 0:23
        % average ITI duration for each daily hour of training
        idxhour = find(hourITI==h);
        meanhourITI(i,h+1) = mean(ITI{i}(idxhour,3));
        
    end
end

%% reorganize ITI duration per day
for i = 1:length(Datas)
    hourITI = floor(rem(ITI{i}(:,1),24));
    % identify start of the dark phase
    darkvector = zeros(length(hourITI),1);
    darkvector((hourITI < 19) & (hourITI > 7)) = 1;
    idxstartday = find(diff(darkvector)== -1);
    days = idxstartday+1; %length(hourITI)]; 
    
    % identify start of the light phase. Not every subject might have
    % trials at 7. 
    lightvector = zeros(length(hourITI),1);
    lightvector((hourITI < 7) | (hourITI > 19)) = 1;
    % find the gap between before and after 7
    idxstartlight = find(diff(lightvector) == -1);
    lights = [idxstartlight+1];
    
    for t = 1:length(days)-1
        meanITIday(i,t) = nanmean(ITI{i}(days(t):days(t+1),3));
        meanITIlight(i,t) = nanmean(ITI{i}(lights(t):days(t+1),3)); 
        meanITIdark(i,t) = nanmean(ITI{i}(days(t):lights(t),3)); 
    end
end

%% reorganize ITI duration per hour
meanITIhour = meanhourITI(:, [8:end 1:7]);

%% ITI duration per time interval of 3 hours
ITIinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    ITIinterv(:,t) = mean(meanITIhour(:,1+3*(t-1):3*t),2,'omitnan');    
end

%% mean ITI duration for each day of training
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(meanITIday(1:nko,:)),std(meanITIday(1:nko,:))./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
errorbar(mean(meanITIday(1+nko:end,:)),std(meanITIday(1+nko:end,:))./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(1,210,koname,'Color',koc,'FontSize',fontsize)
text(1,185,wtname,'Color',wtc,'FontSize',fontsize)
ylabel('ITI duration (sec)')
xlabel('Day')
xlim([.5 5.5])
ylim([150 380])

% stats
anova2(meanITIday,6,'off');

%% mean ITI duration along 24 hours (interval of 3 hours)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(ITIinterv(1:nko,:)),std(ITIinterv(1:nko,:))./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
errorbar(mean(ITIinterv(1+nko:end,:)),std(ITIinterv(1+nko:end,:))./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(5,1900,koname,'Color',koc,'FontSize',fontsize)
text(5,1600,wtname,'Color',wtc,'FontSize',fontsize)
ylabel('ITI duration (sec)')
xlabel('Circadian time interval')
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)
% stats
anova2(ITIinterv,6,'off');

%% WEEK 2 of training
run('Training 3vs9 probe\Load_data.m');
%% ***************************
%% compute ITI duration
starttime = zeros(length(Datas),1); endtime = zeros(length(Datas),1);
for i = 1: length(Datas)
    [ITI{i}] = f_ITIduration(Datas{i});
    
    starttime(i) = floor(ITI{i}(1,1));
    endtime(i) = floor(ITI{i}(end,1));
    
end

%% compute average ITI duration for each hour/day/LD phase
for i = 1:length(Datas)
    startITI = floor(ITI{i}(:,1));
    for t = max(starttime):min(endtime)
        % average ITI duration for each hour of the training
        meanITI(i,t-max(starttime)+1) = mean(ITI{i}(startITI==t,3));
    end
    hourITI = floor(rem(ITI{i}(:,1),24));
    for h = 0:23
        % average ITI duration for each daily hour of training
        idxhour = find(hourITI==h);
        meanhourITI(i,h+1) = mean(ITI{i}(idxhour,3));
        
    end
end

%% reorganize ITI duration per day
for i = 1:length(Datas)
    hourITI = floor(rem(ITI{i}(:,1),24));
    % identify start of the dark phase
    darkvector = zeros(length(hourITI),1);
    darkvector((hourITI < 19) & (hourITI > 7)) = 1;
    idxstartday = find(diff(darkvector)== -1);
    days = idxstartday+1; %length(hourITI)]; 
    
    % identify start of the light phase. Not every subject might have
    % trials at 7. 
    lightvector = zeros(length(hourITI),1);
    lightvector((hourITI < 7) | (hourITI > 19)) = 1;
    % find the gap between before and after 7
    idxstartlight = find(diff(lightvector) == -1);
    lights = [idxstartlight+1];
    
    for t = 1:length(days)-1
        meanITIday(i,t) = nanmean(ITI{i}(days(t):days(t+1),3));
        meanITIlight(i,t) = nanmean(ITI{i}(lights(t):days(t+1),3)); 
        meanITIdark(i,t) = nanmean(ITI{i}(days(t):lights(t),3)); 
    end
end

%% reorganize ITI duration per hour
meanITIhour = meanhourITI(:, [8:end 1:7]);

%% ITI duration per time interval of 3 hours
ITIinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    ITIinterv(:,t) = mean(meanITIhour(:,1+3*(t-1):3*t),2,'omitnan');    
end

%% mean ITI duration for each day of training
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(meanITIday(1:nko,:)),std(meanITIday(1:nko,:))./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
errorbar(mean(meanITIday(1+nko:end,:)),std(meanITIday(1+nko:end,:))./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(1,210,koname,'Color',koc,'FontSize',fontsize)
text(1,185,wtname,'Color',wtc,'FontSize',fontsize)
ylabel('ITI duration (sec)')
xlabel('Day')
xlim([.5 5.5])
ylim([150 380])

% stats
anova2(meanITIday,6,'off');

%% mean ITI duration along 24 hours (interval of 3 hours)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(ITIinterv(1:nko,:)),std(ITIinterv(1:nko,:))./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
errorbar(mean(ITIinterv(1+nko:end,:)),std(ITIinterv(1+nko:end,:))./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(5,1900,koname,'Color',koc,'FontSize',fontsize)
text(5,1600,wtname,'Color',wtc,'FontSize',fontsize)
ylabel('ITI duration (sec)')
xlabel('Circadian time interval')
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)
% stats
anova2(ITIinterv,6,'off');

