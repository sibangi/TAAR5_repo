% SILVIA MAGGI 18/07/2022
% This script reproduce Figure 2 a-h of Maggi et al., 2022 Scieitific Reports 

clearvars
close all

nko = 6; koname = 'KO';
nwt = 6; wtname = 'WT';
ntype = 2;
nbins = 24;

% figure properties
barsize1 = [5 5 4.5 4];
barsize2 = [5 5 9 4];
siz = 3;
cmap = brewermap(ntype,'Set1');
wtc = cmap(2,:);
koc =  cmap(1,:);
fontsize = 7;
axlinewidth = 0.5;

%% WEEK 1
run('Training 3vs9\Load_data.m');

trial_counts = NaN(length(Datas),nbins);
timeout_counts = NaN(length(Datas),nbins);
error_counts = NaN(length(Datas),nbins);

hours_timeouttrials = cell(length(Datas),1);
dailyhours_timeouttrials = cell(length(Datas),1);
for j = 1: length(Datas) 
    
    [trial_counts(j,:)] = f_trials(Datas{j});
    [timeout_counts(j,:),hours_timeouttrials{j},dailyhours_timeouttrials{j}] = f_timeout_trials(Datas{j});
    [error_counts(j,:)] = f_error_trials_wrongresponse(Datas{j});
end

interv = 3;
nday = 5;
%% reorganize timeout trials and error response trial per hour with light phase first and dark phase 
% later. From 7 am to 7pm (light phase); from 7 pm to 7 am (dark phase)
timeouthour = timeout_counts(:, [7:end 1:6]);

errorhour = error_counts(:, [7:end 1:6]);
%% reorganize in intervals of 3 hours each
timeoutinterv = NaN(length(Datas),24/interv);
errorinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    timeoutinterv(:,t) = mean(timeouthour(:,1+3*(t-1):3*t),2,'omitnan');  
    errorinterv(:,t) = mean(errorhour(:,1+3*(t-1):3*t),2,'omitnan');  
end
%% reorganize rate per hour
timeoutratehour = timeouthour./trial_counts(:, [7:end 1:6]);
timeoutratehour(timeoutratehour==Inf) = NaN;
%% Reward rate per time interval of 3 hours
timeoutrateinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    timeoutrateinterv(:,t) = mean(timeoutratehour(:,1+3*(t-1):3*t),2,'omitnan');    
end

errorratehour = errorhour./trial_counts(:, [7:end 1:6]);
errorratehour(errorratehour==Inf) = NaN;
%% Reward rate per time interval of 3 hours
errorrateinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    errorrateinterv(:,t) = mean(errorratehour(:,1+3*(t-1):3*t),2,'omitnan');    
end

%% ***************************
Behav = cell(length(Datas),1);
for i = 1: length(Datas)
    [Behav{i}] = f_startstoptimeouttrials(Datas{i});
end
perf_timeout = NaN(length(Datas),nday);
perf_timeout_light = NaN(length(Datas),nday);
perf_timeout_dark = NaN(length(Datas),nday);

for i = 1 : length(Datas)    
    [perf_timeout(i,:), perf_timeout_light(i,:), perf_timeout_dark(i,:)] = f_performance(Behav{i},[]);
end

%% ***************************
Behav = cell(length(Datas),1);
for i = 1: length(Datas)
    [Behav{i}] = f_startstopwrongtrials(Datas{i});
end
perf_wrong = NaN(length(Datas),nday);
perf_wrong_light = NaN(length(Datas),nday);
perf_wrong_dark = NaN(length(Datas),nday);

for i = 1 : length(Datas)    
    [perf_wrong(i,:), perf_wrong_light(i,:), perf_wrong_dark(i,:)] = f_performance(Behav{i},[]);
end

groupLight = {koname,koname,koname,koname,koname,koname,wtname,wtname,wtname,...
wtname,wtname,wtname};

%% FIGURES
%% panel: plot perf_timeout over the days
perf_timeout(perf_timeout==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
errorbar(mean(perf_timeout(1:nko,1:nday),'omitnan'),std(perf_timeout(1:nko,1:nday),'omitnan')./sqrt(nko),'o-'...
    ,'Color',koc,'MarkerSize',3); hold on
errorbar(mean(perf_timeout(1+nko:end,1:nday),'omitnan'),std(perf_timeout(1+nko:end,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc ,'MarkerSize',3); hold on
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(3.5,.18,wtname,'Color',wtc,'FontSize',fontsize); hold on
text(3.5,.16,koname,'Color',koc,'FontSize',fontsize); hold on
ylabel('Time-out rate')
xlabel('Days')

anova2(perf_timeout,nwt,'off');

%% panel: plot perf_timeout over the days
perf_wrong(perf_wrong==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
errorbar(mean(perf_wrong(1:nko,1:nday),'omitnan'),std(perf_wrong(1:nko,1:nday),'omitnan')./sqrt(nko),'o-',...
    'Color',koc ,'MarkerSize',3); hold on
errorbar(mean(perf_wrong(1+nko:end,1:nday),'omitnan'),std(perf_wrong(1+nko:end,1:nday),'omitnan')./sqrt(nwt),'o-'...
    ,'Color',wtc,'MarkerSize',3); hold on
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(3,.34,koname,'Color',koc,'FontSize',fontsize); hold on
text(3,.3,wtname,'Color',wtc,'FontSize',fontsize); hold on
ylabel('Timing error rate')
xlabel('Days')

anova2(perf_wrong,nwt,'off');

%% plot timeout rate along the 24 hours for interval of length 3 hours
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(timeoutinterv(1:nko,:),'omitnan'),std(timeoutinterv(1:nko,:),'omitnan')./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
errorbar(mean(timeoutinterv(1+nko:end,:),'omitnan'),std(timeoutinterv(1+nko:end,:),'omitnan')./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(5,11,koname,'Color',koc,'FontSize',fontsize);
text(5,10,wtname,'Color',wtc,'FontSize',fontsize);
ylabel('Time-out trials')
xlabel('Circadian time interval')
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)

anova2(timeoutinterv,6,'off');

%% plot timeout rate along the 24 hours for interval of length 3 hours
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(errorinterv(1:nko,:),'omitnan'),std(errorinterv(1:nko,:),'omitnan')./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
errorbar(mean(errorinterv(1+nko:end,:),'omitnan'),std(errorinterv(1+nko:end,:),'omitnan')./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(5,11,koname,'Color',koc,'FontSize',fontsize);
text(5,10,wtname,'Color',wtc,'FontSize',fontsize);
ylabel('Timing error trials')
xlabel('Circadian time interval')
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)

anova2(errorinterv,6,'off');

%% ########################################################################
%% WEEK 2
run('Training 3vs9 probe\Load_data.m');

trial_counts = NaN(length(Datas),nbins);
timeout_counts = NaN(length(Datas),nbins);
error_counts = NaN(length(Datas),nbins);

hours_timeouttrials = cell(length(Datas),1);
dailyhours_timeouttrials = cell(length(Datas),1);
for j = 1: length(Datas) 
    
    [trial_counts(j,:)] = f_trials(Datas{j});
    [timeout_counts(j,:),hours_timeouttrials{j},dailyhours_timeouttrials{j}] = f_timeout_trials(Datas{j});
    [error_counts(j,:)] = f_error_trials_wrongresponse(Datas{j});
end

interv = 3;
nday = 5;
%% reorganize timeout trials and error response trial per hour with light phase first and dark phase 
% later. From 7 am to 7pm (light phase); from 7 pm to 7 am (dark phase)
timeouthour = timeout_counts(:, [7:end 1:6]);
timeoutlight = mean(timeouthour(:,1:12),2,'omitnan');
timeoutdark = mean(timeouthour(:,13:end),2,'omitnan');

errorhour = error_counts(:, [7:end 1:6]);
errorlight = mean(errorhour(:,1:12),2,'omitnan');
errordark = mean(errorhour(:,13:end),2,'omitnan');
%% reorganize in intervals of 3 hours each
timeoutinterv = NaN(length(Datas),24/interv);
errorinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    timeoutinterv(:,t) = mean(timeouthour(:,1+3*(t-1):3*t),2,'omitnan');  
    errorinterv(:,t) = mean(errorhour(:,1+3*(t-1):3*t),2,'omitnan');  
end
%% reorganize rate per hour
timeoutratehour = timeouthour./trial_counts(:, [7:end 1:6]);
timeoutratehour(timeoutratehour==Inf) = NaN;
%% Reward rate per time interval of 3 hours
timeoutrateinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    timeoutrateinterv(:,t) = mean(timeoutratehour(:,1+3*(t-1):3*t),2,'omitnan');    
end

errorratehour = errorhour./trial_counts(:, [7:end 1:6]);
errorratehour(errorratehour==Inf) = NaN;
%% Reward rate per time interval of 3 hours
errorrateinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    errorrateinterv(:,t) = mean(errorratehour(:,1+3*(t-1):3*t),2,'omitnan');    
end

%% ***************************
Behav = cell(length(Datas),1);
for i = 1: length(Datas)
    [Behav{i}] = f_startstoptimeouttrials(Datas{i});
end
perf_timeout = NaN(length(Datas),nday);
perf_timeout_light = NaN(length(Datas),nday);
perf_timeout_dark = NaN(length(Datas),nday);

for i = 1 : length(Datas)    
    [perf_timeout(i,:), perf_timeout_light(i,:), perf_timeout_dark(i,:)] = f_performance(Behav{i},[]);
end

%% ***************************
Behav = cell(length(Datas),1);
for i = 1: length(Datas)
    [Behav{i}] = f_startstopwrongtrials(Datas{i});
end
perf_wrong = NaN(length(Datas),nday);
perf_wrong_light = NaN(length(Datas),nday);
perf_wrong_dark = NaN(length(Datas),nday);

for i = 1 : length(Datas)    
    [perf_wrong(i,:), perf_wrong_light(i,:), perf_wrong_dark(i,:)] = f_performance(Behav{i},[]);
end

groupLight = {koname,koname,koname,koname,koname,koname,wtname,wtname,wtname,...
wtname,wtname,wtname};

%% FIGURES
%% panel: plot perf_timeout over the days
perf_timeout(perf_timeout==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
errorbar(mean(perf_timeout(1:nko,1:nday),'omitnan'),std(perf_timeout(1:nko,1:nday),'omitnan')./sqrt(nko),'o-'...
    ,'Color',koc,'MarkerSize',3); hold on
errorbar(mean(perf_timeout(1+nko:end,1:nday),'omitnan'),std(perf_timeout(1+nko:end,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc ,'MarkerSize',3); hold on

xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(3.5,.18,wtname,'Color',wtc,'FontSize',fontsize); hold on
text(3.5,.16,koname,'Color',koc,'FontSize',fontsize); hold on
ylabel('Time-out rate')
xlabel('Days')

anova2(perf_timeout,nwt,'off');

%% panel: plot perf_timeout over the days
perf_wrong(perf_wrong==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
errorbar(mean(perf_wrong(1:nko,1:nday),'omitnan'),std(perf_wrong(1:nko,1:nday),'omitnan')./sqrt(nko),'o-',...
    'Color',koc ,'MarkerSize',3); hold on
errorbar(mean(perf_wrong(1+nko:end,1:nday),'omitnan'),std(perf_wrong(1+nko:end,1:nday),'omitnan')./sqrt(nwt),'o-'...
    ,'Color',wtc,'MarkerSize',3); hold on
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(3,.34,koname,'Color',koc,'FontSize',fontsize); hold on
text(3,.3,wtname,'Color',wtc,'FontSize',fontsize); hold on
ylabel('Timing error rate')
xlabel('Days')

anova2(perf_wrong,nwt,'off');

%% plot timeout rate along the 24 hours for interval of length 3 hours

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(timeoutinterv(1:nko,:),'omitnan'),std(timeoutinterv(1:nko,:),'omitnan')./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
errorbar(mean(timeoutinterv(1+nko:end,:),'omitnan'),std(timeoutinterv(1+nko:end,:),'omitnan')./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(5,11,koname,'Color',koc,'FontSize',fontsize);
text(5,10,wtname,'Color',wtc,'FontSize',fontsize);
ylabel('Time-out trials')
xlabel('Circadian time interval')
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)

anova2(timeoutinterv,6,'off');

%% plot timeout rate along the 24 hours for interval of length 3 hours
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(errorinterv(1:nko,:),'omitnan'),std(errorinterv(1:nko,:),'omitnan')./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
errorbar(mean(errorinterv(1+nko:end,:),'omitnan'),std(errorinterv(1+nko:end,:),'omitnan')./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(5,11,koname,'Color',koc,'FontSize',fontsize);
text(5,10,wtname,'Color',wtc,'FontSize',fontsize);
ylabel('Timing error trials')
xlabel('Circadian time interval')
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)

anova2(errorinterv,6,'off');
