% ***************************
% SILVIA MAGGI 18/07/2022
% Script to reproduce Figure 1 in Maggi et al., 2022 Scientific Reports

clearvars
close all

barsize1 = [5 5 4.5 4];
barsize2 = [5 5 9 4];
siz = 3;

ntype = 2;
nwt = 6;
nko = 6;

koname = 'KO';
wtname = 'WT';

cmap = brewermap(ntype,'Set1');
wtc = cmap(1,:);
koc =  cmap(2,:);
fontsize = 7;
axlinewidth = 0.5;

%% WEEK 1
run('Training 3vs9\Load_data.m');

%% ***************************
Behav = cell(length(Datas),1);
for i = 1: length(Datas)
    [Behav{i}] = f_startstopcorrecttrials(Datas{i});
end

nday = 5;

performance = NaN(length(Datas),nday);
performance_light = NaN(length(Datas),nday);
performance_dark = NaN(length(Datas),nday);

for i = 1 : length(Datas)    
    [performance(i,:), performance_light(i,:), performance_dark(i,:)] = f_performance(Behav{i},[]);
end

%% panel: plot performance over the days
performance(performance==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
errorbar(mean(performance(1:nwt,1:nday),'omitnan'),std(performance(1:nwt,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc ,'MarkerSize',3); hold on
errorbar(mean(performance(1+nwt:end,1:nday),'omitnan'),std(performance(1+nwt:end,1:nday),'omitnan')./sqrt(nwt),'o-'...
    ,'Color',koc,'MarkerSize',3); hold on
plot([.5 nday+.5],[.5 .5],'k--'); hold on
ylim([0.2 1])
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
% legend(koname,wtname,'location','southeast')
text(1,.4,koname,'Color',wtc,'FontSize',fontsize); hold on
text(1,.3,wtname,'Color',koc,'FontSize',fontsize); hold on
ylabel('Performance')
xlabel('Days')

anova2(performance,nwt,'off');

%% panel: plot performance over the days separately for light and dark phase
performance_light(performance_light ==0)=NaN;
performance_dark(performance_dark==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize2) 
subplot(1,2,1)
errorbar(mean(performance_light(1:nwt,1:nday),'omitnan'),std(performance_light(1:nwt,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc,'MarkerSize',3); hold on
errorbar(mean(performance_light(1+nwt:end,1:nday),'omitnan'),std(performance_light(1+nwt:end,1:nday),'omitnan')./sqrt(nko),'o-'...
    ,'Color',koc,'MarkerSize',3); hold on
plot([.5 nday+.5],[.5 .5],'k--'); hold on
ylim([0.2 1])
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
ylabel('Performance')
xlabel('Days')
title('Light phase')
subplot(1,2,2)
errorbar(mean(performance_dark(1:nwt,1:nday),'omitnan'),std(performance_dark(1:nwt,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc,'MarkerSize',3); hold on
errorbar(mean(performance_dark(1+nwt:end,1:nday),'omitnan'),std(performance_dark(1+nwt:end,1:nday),'omitnan')./sqrt(nko),'o-',...
    'Color',koc,'MarkerSize',3); hold on
plot([.5 nday+.5],[.5 .5],'k--'); hold on
ylim([0.2 1])
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
legend(koname,wtname,'location','southeast')
title('Dark phase')
xlabel('Days')

anova2(performance_dark,nwt,'off');
anova2(performance_light,nwt,'off');

%% ***************************************
% here check the number of trial per day
n_trials = NaN(length(Datas),nday);
n_trials_light = NaN(length(Datas),nday);
n_trials_dark = NaN(length(Datas),nday);

for i = 1 : length(Datas)    
    [n_trials(i,:), n_trials_light(i,:), n_trials_dark(i,:)] = f_trialsXday(Behav{i});
end

%% panel: plot n_trials over the days
n_trials(n_trials==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
errorbar(mean(n_trials(1:nwt,1:nday),'omitnan'),std(n_trials(1:nwt,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc ,'MarkerSize',3); hold on
errorbar(mean(n_trials(1+nwt:end,1:nday),'omitnan'),std(n_trials(1+nwt:end,1:nday),'omitnan')./sqrt(nwt),'o-'...
    ,'Color',koc,'MarkerSize',3); hold on
plot([.5 nday+.5],[.5 .5],'k--'); hold on
% ylim([0 1])
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
legend(koname,wtname,'location','southeast')
ylabel('# trials')
xlabel('Days')

anova2(n_trials,nwt,'off');

%% Compute the number of trials over 24 hour and the correct trials too
nbins = 24;
trial_counts = NaN(length(Datas),nbins);
performance_counts = NaN(length(Datas),nbins);
% te = zeros(length(Datas),24);
for j = 1 : length(Datas) 
    [trial_counts(j,:)] = f_trials(Datas{j});
    [performance_counts(j,:)] = f_performance_24h(Datas{j});
end

%% reorganize trial count per hour with light phase first and dark phase 
% later. From 7 am to 7pm (light phase); from 7 pm to 7 am (dark phase)
trialshour = trial_counts(:, [7:end 1:6]);

% trialslight = mean(trialshour(:,1:12),2,'omitnan');
% trialsdark = mean(trialshour(:,13:end),2,'omitnan');

%% reorganize trials count in intervals of 3 hours each
interv = 3;
trialsinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    trialsinterv(:,t) = mean(trialshour(:,1+3*(t-1):3*t),2,'omitnan');    
end

%% reorganize correct rate per hour with dark phase first and light phase 
% later. From 7 am to 7pm (light phase); from 7 pm to 7 am (dark phase)
perfhour = performance_counts(:, [7:end 1:6]);
%% reorganize performance in intervals of 3 hours each
perfinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    perfinterv(:,t) = mean(perfhour(:,1+3*(t-1):3*t),2,'omitnan');    
end

%% reorganize correct rate per hour
performanceratehour = perfhour./trial_counts(:, [7:end 1:6]);

%% Correct rate per time interval of 3 hours
rateinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    rateinterv(:,t) = mean(performanceratehour(:,1+3*(t-1):3*t),2,'omitnan');    
end

jit_interv = randn(nwt+nko,24/interv).*.08;
jitter_x_axis = repmat([1:8],12,1)+jit_interv;

%% Correct rate distribution along 24 hours (interval of 3 hours)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(rateinterv(1:nwt,:)),std(rateinterv(1:nwt,:))./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
errorbar(mean(rateinterv(1+nwt:end,:)),std(rateinterv(1+nwt:end,:))./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
plot(jitter_x_axis(1:nwt,:),rateinterv(1:nwt,:),'o','Color',wtc,'MarkerSize',siz-1); hold on
plot(jitter_x_axis(1+nwt:end,:),rateinterv(1+nwt:end,:),'o','Color',koc,'MarkerSize',siz-1); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
legend('KO','WT','Location','northwest')
ylabel('Performance')
xlabel('Circadian time interval')
% ylim([0 4200])
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)

[p,tbl,stats] = anova2(rateinterv,6,'off');

%% plot trial count along the 24 hours for interval of length 3 hours
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(trialsinterv(1:nwt,:),'omitnan'),std(trialsinterv(1:nwt,:),'omitnan')./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
errorbar(mean(trialsinterv(1+nwt:end,:),'omitnan'),std(trialsinterv(1+nwt:end,:),'omitnan')./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
plot(jitter_x_axis(1:nwt,:),trialsinterv(1:nwt,:),'o','Color',wtc,'MarkerSize',siz-1); hold on
plot(jitter_x_axis(1+nwt:end,:),trialsinterv(1+nwt:end,:),'o','Color',koc,'MarkerSize',siz-1); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(1,135,koname,'Color',wtc,'FontSize',fontsize); hold on
text(1,120,wtname,'Color',koc,'FontSize',fontsize); hold on
ylabel('Number of trials')
xlabel('Circadian time interval')
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)

anova2(trialsinterv,nwt,'off');


%% WEEK 2
run('Training 3vs9 probe\Load_data.m');
%% ***************************
Behav = cell(length(Datas),1);
for i = 1: length(Datas)
    [Behav{i}] = f_startstopcorrecttrials(Datas{i});
end

performance = NaN(length(Datas),nday);
performance_light = NaN(length(Datas),nday);
performance_dark = NaN(length(Datas),nday);

for i = 1 : length(Datas)    
    [performance(i,:), performance_light(i,:), performance_dark(i,:)] = f_performance(Behav{i},[]);
end

%% panel: plot performance over the days
performance(performance==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
errorbar(mean(performance(1:nwt,1:nday),'omitnan'),std(performance(1:nwt,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc ,'MarkerSize',3); hold on
errorbar(mean(performance(1+nwt:end,1:nday),'omitnan'),std(performance(1+nwt:end,1:nday),'omitnan')./sqrt(nwt),'o-'...
    ,'Color',koc,'MarkerSize',3); hold on
plot([.5 nday+.5],[.5 .5],'k--'); hold on
ylim([0.2 1])
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
% legend(koname,wtname,'location','southeast')
text(1,.4,koname,'Color',wtc,'FontSize',fontsize); hold on
text(1,.3,wtname,'Color',koc,'FontSize',fontsize); hold on
ylabel('Performance')
xlabel('Days')

anova2(performance,nwt,'off');

%% panel: plot performance over the days separately for light and dark phase
% performance_light(performance_light ==0)=NaN;
% performance_dark(performance_dark==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize2) 
subplot(1,2,1)
errorbar(mean(performance_light(1:nwt,1:nday),'omitnan'),std(performance_light(1:nwt,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc,'MarkerSize',3); hold on
errorbar(mean(performance_light(1+nwt:end,1:nday),'omitnan'),std(performance_light(1+nwt:end,1:nday),'omitnan')./sqrt(nko),'o-'...
    ,'Color',koc,'MarkerSize',3); hold on
plot([.5 nday+.5],[.5 .5],'k--'); hold on
ylim([0.2 1])
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
ylabel('Performance')
xlabel('Days')
title('Light phase')
subplot(1,2,2)
errorbar(mean(performance_dark(1:nwt,1:nday),'omitnan'),std(performance_dark(1:nwt,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc,'MarkerSize',3); hold on
errorbar(mean(performance_dark(1+nwt:end,1:nday),'omitnan'),std(performance_dark(1+nwt:end,1:nday),'omitnan')./sqrt(nko),'o-',...
    'Color',koc,'MarkerSize',3); hold on
plot([.5 nday+.5],[.5 .5],'k--'); hold on
ylim([0.2 1])
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
legend(koname,wtname,'location','southeast')
title('Dark phase')
xlabel('Days')

anova2(performance_light,nwt,'off');
anova2(performance_dark,nwt,'off');


%% ***************************************
% here check the number of trial per day
n_trials = NaN(length(Datas),nday);
n_trials_light = NaN(length(Datas),nday);
n_trials_dark = NaN(length(Datas),nday);

for i = 1 : length(Datas)    
    [n_trials(i,:), n_trials_light(i,:), n_trials_dark(i,:)] = f_trialsXday(Behav{i});
end

%% panel: plot n_trials over the days
n_trials(n_trials==0)=NaN;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
errorbar(mean(n_trials(1:nwt,1:nday),'omitnan'),std(n_trials(1:nwt,1:nday),'omitnan')./sqrt(nwt),'o-',...
    'Color',wtc ,'MarkerSize',3); hold on
errorbar(mean(n_trials(1+nwt:end,1:nday),'omitnan'),std(n_trials(1+nwt:end,1:nday),'omitnan')./sqrt(nwt),'o-'...
    ,'Color',koc,'MarkerSize',3); hold on
plot([.5 nday+.5],[.5 .5],'k--'); hold on
% ylim([0 1])
xlim([.5 nday+.5])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
legend(koname,wtname,'location','southeast')
ylabel('# trials')
xlabel('Days')

anova2(n_trials,nwt,'off');

%% Compute the number of trials over 24 hour and the correct trials too
nbins = 24;
trial_counts = NaN(length(Datas),nbins);
performance_counts = NaN(length(Datas),nbins);
te = zeros(length(Datas),24);
for j = 1 : length(Datas) 
    [trial_counts(j,:)] = f_trials(Datas{j});
    [performance_counts(j,:)] = f_performance_24h(Datas{j});
end

%% reorganize trial count per hour with light phase first and dark phase 
% later. From 7 am to 7pm (light phase); from 7 pm to 7 am (dark phase)
trialshour = trial_counts(:, [7:end 1:6]);

trialslight = mean(trialshour(:,1:12),2,'omitnan');
trialsdark = mean(trialshour(:,13:end),2,'omitnan');

%% reorganize trials count in intervals of 3 hours each
interv = 3;
trialsinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    trialsinterv(:,t) = mean(trialshour(:,1+3*(t-1):3*t),2,'omitnan');    
end

%% reorganize correct rate per hour with dark phase first and light phase 
% later. From 7 am to 7pm (light phase); from 7 pm to 7 am (dark phase)
perfhour = performance_counts(:, [7:end 1:6]);
%% reorganize performance in intervals of 3 hours each
perfinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    perfinterv(:,t) = mean(perfhour(:,1+3*(t-1):3*t),2,'omitnan');    
end

%% reorganize correct rate per hour
performanceratehour = perfhour./trial_counts(:, [7:end 1:6]);

%% Correct rate per time interval of 3 hours
rateinterv = NaN(length(Datas),24/interv);
for t = 1:24/interv
    rateinterv(:,t) = mean(performanceratehour(:,1+3*(t-1):3*t),2,'omitnan');    
end

jit_interv = randn(nwt+nko,24/interv).*.08;
jitter_x_axis = repmat([1:8],12,1)+jit_interv;

%% Correct rate distribution along 24 hours (interval of 3 hours)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(rateinterv(1:nwt,:)),std(rateinterv(1:nwt,:))./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
errorbar(mean(rateinterv(1+nwt:end,:)),std(rateinterv(1+nwt:end,:))./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
plot(jitter_x_axis(1:nwt,:),rateinterv(1:nwt,:),'o','Color',wtc,'MarkerSize',siz-1); hold on
plot(jitter_x_axis(1+nwt:end,:),rateinterv(1+nwt:end,:),'o','Color',koc,'MarkerSize',siz-1); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
legend('KO','WT','Location','northwest')
ylabel('Performance')
xlabel('Circadian time interval')
% ylim([0 4200])
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)

[p,tbl,stats] = anova2(rateinterv,6,'off');

%% plot trial count along the 24 hours for interval of length 3 hours
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)
errorbar(mean(trialsinterv(1:nwt,:),'omitnan'),std(trialsinterv(1:nwt,:),'omitnan')./sqrt(nwt),...
    'o-','Color',wtc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',wtc); hold on
errorbar(mean(trialsinterv(1+nwt:end,:),'omitnan'),std(trialsinterv(1+nwt:end,:),'omitnan')./sqrt(nko),...
    'o-','Color',koc,'MarkerSize',siz,'CapSize',0,'MarkerFaceColor',koc); hold on
plot(jitter_x_axis(1:nwt,:),trialsinterv(1:nwt,:),'o','Color',wtc,'MarkerSize',siz-1); hold on
plot(jitter_x_axis(1+nwt:end,:),trialsinterv(1+nwt:end,:),'o','Color',koc,'MarkerSize',siz-1); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
text(1,135,koname,'Color',wtc,'FontSize',fontsize); hold on
text(1,120,wtname,'Color',koc,'FontSize',fontsize); hold on
% legend('KO','WT','Location','northwest')
ylabel('Number of trials')
xlabel('Circadian time interval')
% ylim([0 4200])
xlim([.5 24/interv+.5])
set(gca,'XTick',1:24/interv)
set(gca,'XTickLabel',{'(7-9)','(10-12)','(13-15)','(16-18)','(19-21)',...
    '(22-24)','(1-3)','(4-6)'})
xtickangle(45)

anova2(trialsinterv,nwt,'off');
