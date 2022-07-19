% Silvia Maggi 18/07/2022
% This script reproduce Figure 3 (and Supplementary Fig 3 i,j) of 
% Maggi et al., 2022 Scientific Reports
% ***************************
clearvars
close all

nko = 6;
nwt = 6;
koname = 'KO';
wtname = 'WT';
ntype = 2;

% figure properties
barsize1 = [5 5 4.5 4];
barsize2 = [5 5 9 4];
barsize = [5 5 7 4];
siz = 3;
lin = 1.5;
cmap = brewermap(ntype,'Set1');
wtc = cmap(2,:); wtc_trasp = [cmap(2,:) 0.3];
koc =  cmap(1,:); koc_trasp = [cmap(1,:) 0.3];
kocmap = brewermap(7,'OrRd');
wtcmap = brewermap(7,'Blues');
fontsize = 7;
axlinewidth = 0.5;

%% WEEK 1
run('Training 3vs9\Load_data.m');

%% ***************************
Behav = cell(length(Datas),1);
starttime = zeros(length(Datas),1); endtime = zeros(length(Datas),1);
for i = 1: length(Datas)
    [Behav{i}] = f_startstopcorrecttrials(Datas{i});
    
    starttime(i) = floor(Behav{i}(1,1));
    endtime(i) = floor(Behav{i}(end,1));

end

[initT, idxinit] = min(starttime);
[endT, idxend] = min(endtime);

inizioT = find(Behav{idxinit}(:,1)>=initT,1,'first');
time_duration = floor(Behav{idxinit}(inizioT,1)):floor(endT);
nday = 5;

learnrate = zeros(length(Datas),length(time_duration));
corrate = zeros(length(Datas),length(time_duration));
num_trialXday_dark_light = zeros(length(Datas), 2, nday);

for i = 1 : length(Datas)
    clear tstart
    tstart = floor(Behav{i}(:,1));
    % for each hour of training find learning rate and correct rate. If
    % there are not trial in an hour then the value is set to zero (no
    % increase, no decrease)
    for t = 1:length(time_duration)
        clear ind
        ind = find(tstart==time_duration(t));
        if length(ind)>1
            X = Behav{i}(ind,3);
            X(X==0)=-1;
            learnrate(i,t) = sum(X)/length(ind);
            corrate(i,t) = sum(Behav{i}(ind,3))/length(ind);
        end
    end
    
    % to count number of trial for each phase (light/dark over the days) I
    % need to count the trial between 19.00 and 7.00 for each day. Do not
    % search for single hour because there might not be trials. Start from
    % the first dark phase (19-19+12). the first few hours of light are
    % excluded from this analysis
    for d = 1:nday
        NumTr_dark(d) = length(find((Behav{i}>=19+(d-1)*24) & (Behav{i}<19+12+(d-1)*24)));
        NumTr_light(d) = length(find((Behav{i}>=19+12+(d-1)*24) & (Behav{i}<19+(d)*24)));
        
    end
    num_trialXday_dark_light(i,:,:) = [NumTr_dark; NumTr_light];
    
end

corrate(corrate==0)=NaN;

%% plot cumulative learning rate over time (hour-by-hour)
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize2)  
cumulative_learnrate = cumsum(learnrate,2,'omitnan');
plot(time_duration, mean(cumulative_learnrate(1:nko,:)),'-','Color',koc,'LineWidth',lin); hold on
plot(time_duration, mean(cumulative_learnrate(1+nko:end,:)),'-','Color',wtc,'LineWidth',lin); hold on
for i = 1:length(Datas)
    if i<=nko
        plot(time_duration, cumsum(learnrate(i,:),'omitnan'),'-','Color',koc_trasp); hold on
    else
        plot(time_duration, cumsum(learnrate(i,:),'omitnan'),'-','Color',wtc_trasp); hold on
    end
end
plot([19:12:time_duration(end); 19:12:time_duration(end)],...
    [min(cumulative_learnrate(:)) max(cumulative_learnrate(:))],'--','Color',[.6 .6 .6]); hold on
plot([time_duration(1) time_duration(end)],[0 0],'--','Color',[.7 .7 .7]); hold on
text(20,40,koname,'Color',koc,'FontSize',fontsize);
text(20,25,wtname,'Color',wtc,'FontSize',fontsize);
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
ylabel('Cumulative rate of learning')
xlabel('Hour')


%% plot group average per day of cumulative learning rate around light switch (off)
light = 19:24:time_duration(end);
nbefore = 9; nafter = 12;
x = -nbefore+1:nafter+1;
Y = cell(length(light),1);
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize2)  
for tr = 1:length(light)
    % find index of switch light
    light_switch = find(time_duration==light(tr));
    Y{tr} = cumulative_learnrate(:,light_switch-nbefore:light_switch+nafter)-cumulative_learnrate(:,light_switch-1);
    subplot(1,2,1)
    plot(x, mean(Y{tr}(1:nko,:)),'-','Color',kocmap(tr+1,:)); hold on
    text(-9,3+tr,['Day ',num2str(tr)],'Color',kocmap(tr+1,:),'FontSize',fontsize); hold on
    subplot(1,2,2)
    plot(x, mean(Y{tr}(1+nko:end,:)),'-','Color',wtcmap(tr+1,:)); hold on
    text(-9,3+tr,['Day ',num2str(tr)],'Color',wtcmap(tr+1,:),'FontSize',fontsize); hold on
end
subplot(1,2,1)
plot([0 0],[-2 10],'--','Color',[.6 .6 .6]); hold on
plot([-2 10],[-2 10],'--','Color',[.6 .6 .6]); hold on
ylim([-2 10])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Hour')
ylabel('Cumulative learning rate')
subplot(1,2,2)
plot([0 0],[-2 10],'--','Color',[.6 .6 .6]); hold on
plot([-2 10],[-2 10],'--','Color',[.6 .6 .6]); hold on
ylim([-2 10])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Hour')

%% Quantify the angle between the regression line before and after light 
% switch for each group and each day
xpre = -nbefore:0;
xpost = 0:nafter;
theta = zeros(nko+nwt,length(light));
slope_bef = zeros(nko+nwt,length(light));
slope_aft = zeros(nko+nwt,length(light));
for rat = 1:nko+nwt
    for tr = 1:length(light)
       b_pre = robustfit(xpre,Y{tr}(rat,1:nbefore+1));
       b_post = robustfit(xpost,Y{tr}(rat,nbefore+1:end));
       u_pre = b_pre(1)+b_pre(2)*xpre(1:3);
       u_post = b_post(1)+b_post(2)*xpost(1:3);
       slope_bef(rat,tr) = b_pre(2);
       slope_aft(rat,tr) = b_post(2);
       theta(rat,tr) = atan2(norm(cross(u_pre,u_post)),dot(u_pre,u_post));

    end
end

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize)
subplot(1,2,1)
boxplot(slope_aft(1:nko,:),'Color',koc); hold on
ylim([-0.2 .9])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Day')
ylabel('Rate of improvement (slope)') 
subplot(1,2,2)
boxplot(slope_aft(1+nko:end,:),'Color',wtc); hold on
ylim([-0.2 .9])
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Day')
ylabel('Rate of improvement (slope)') 


[p,tbl,stats] = anova2(slope_aft,nko,'off');
% c = multcompare(stats);


% %% plot group average per day of cumulative learning rate around light switch (on)
% dark = 31:24:time_duration(end);
% % nbefore = 9; nafter = 12;
% % x = -nbefore:nafter;
% Y = cell(length(dark),1);
% figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize2)  
% for tr = 1:length(dark)-1
%     % find index of switch light
%     dark_switch = find(time_duration==dark(tr));
%     Y{tr} = cumulative_learnrate(:,dark_switch-nbefore:dark_switch+nafter)-cumulative_learnrate(:,dark_switch-1);
%     subplot(1,2,1)
%     plot(x, mean(Y{tr}(1:nko,:)),'-','Color',kocmap(tr+1,:)); hold on
%     subplot(1,2,2)
%     plot(x, mean(Y{tr}(1+nko:end,:)),'-','Color',wtcmap(tr+1,:)); hold on
% end
% subplot(1,2,1)
% plot([0 0],[-5 2],'--','Color',[.6 .6 .6]); hold on
% set(gca,'FontName','Helvetica','FontSize',fontsize);
% set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
% xlabel('Hour')
% ylabel('Cumulative learning rate')
% subplot(1,2,2)
% plot([0 0],[-5 2],'--','Color',[.6 .6 .6]); hold on
% set(gca,'FontName','Helvetica','FontSize',fontsize);
% set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
% xlabel('Hour')

%% figure: plot the cumulative distribution of rewarded trials (correct = 
% +1, error = -1)
len = zeros(length(Behav),1);
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize2)  
for i = 1:length(Datas)
    behaviour{i} = Behav{i};
    Behav{i}(Behav{i}(:,3)==0,3)=-1;
    if i <= nko
        plot(cumsum(Behav{i}(:,3)),'Color',koc_trasp); hold on
    else
        plot(cumsum(Behav{i}(:,3)),'Color',wtc_trasp); hold on
    end
    len(i) = size(Behav{i},1);
end
cumulative_correct = zeros(length(Datas),min(len));
for i = 1:length(Datas)
    cumulative_correct(i,:) = cumsum(Behav{i}(1:min(len),3));
end
plot(mean(cumulative_correct(1+nko:end,:)),'Color',wtc,'LineWidth',lin); hold on
plot(mean(cumulative_correct(1:nko,:)),'Color',koc,'LineWidth',lin); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Trials')
ylabel('Cumulative correct trials')
xlim([0 max(len)])

%%*********************************
% Find the learning point as the point of maximum inflection in the 
% learning curve, using sliding window of 50 trials

start = 5;
fine = 5;

lenw = 20; % length window
movw = 5; % moving window of 5 trial
learnTr = cell(length(Datas),1);
deltaslope = cell(length(Datas),1);
for k = 1 :length(Datas)

    learn_slpre_slpost = [];
    window = 1:lenw; n = 1;
    while window(end) < size(Behav{k},1) %ismember(window,1:size(Behav{k},1))
        
        %%*********************************************
        % Define the learning trial if exist a
        % regression line before and after that trial that satisfy:
        % - (slope after - slope before) is also max
        % - slope before>0
        
        clear cumbehav
        cumbehav = cumsum(Behav{k}(window,3));

        pre_post = zeros(length(cumbehav)-(start+fine-1),2);
        for t = start:length(cumbehav)-fine
            xpre = 1:t;
            xpost = t+1:lenw;
            robpre = robustfit(xpre,cumbehav(1:t));
            robpost = robustfit(xpost,cumbehav(t+1:end));
            pre_post(t-(start-1),:) = [robpre(2) robpost(2)];           
        end
        deltasl = pre_post(:,2)-pre_post(:,1);
        % indexes of max delta slope that has slope after > slope before
        idxmaxsl = find((deltasl == max(deltasl)) & deltasl>0);
        
        idx_possl = find(pre_post(idxmaxsl,1)>0,1,'first'); %idx of positive slope before

        if isempty(idx_possl)
            window = window+movw; 
            n = n+1;
        else
            learn_slpre_slpost(n,:) = [window(idxmaxsl(idx_possl)) pre_post(idxmaxsl(idx_possl),:)];
            window = learn_slpre_slpost(end,1)+movw:learn_slpre_slpost(end,1)+lenw+movw-1;
            n = n+1;
        end
    end
    
    learnTr{k} = learn_slpre_slpost(learn_slpre_slpost(:,1)~=0,1);
    deltaslope{k} = learn_slpre_slpost(learn_slpre_slpost(:,1)~=0,3)-learn_slpre_slpost(learn_slpre_slpost(:,1)~=0,2);
end

%% define the time of learning
learningTrials = cell(length(Datas),1);
learnDay = cell(length(Datas),1);
for i = 1:length(Datas)
    learningTrials{i} = rem(Behav{i}(learnTr{i},1),24);
    learnDay{i} = (Behav{i}(learnTr{i},1))./24;
end

%% plot example learning curve around learning trial
learn_before = 15;
learn_after = 30;
x_learn = -learn_before+1:learn_after+1;

sbj=6;
learnCurve = cumsum(Behav{sbj}(learnTr{sbj}(1)-learn_before+1:learnTr{sbj}(1)+learn_after+1,3));

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[5 5 3.5 4])  
plot(x_learn,learnCurve,'-','Color',koc); hold on
plot([0 0],[-2 20],'--','Color',[.6 .6 .6]); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Trial')
ylabel({'Cumulative number', 'of correct trial'}) 
xlim([-learn_before learn_after+1])


learningday = zeros(length(Datas),1);
learningtrial = zeros(length(Datas),1);
for k = 1:length(Datas)
    jit = randn(length(learningTrials{k}),1)*.2;
    if ~isempty(learnDay{k}) && ~isempty(learningTrials{k})
        learningday(k) = learnDay{k}(1);
        learningtrial(k) = learningTrials{k}(1);
    end
end

group(1:nko) = 1;
group(nko+1:nko+nwt) = 2;

jit = randn(nko+nwt,1)*.2;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize)
subplot(1,2,1)
boxplot(learningday,group,'Color',[.6 .6 .6]); hold on
plot(1+jit(1:nko),learningday(1:nko),'o','Color',koc,'MarkerSize',siz); hold on
plot(2+jit(1+nko:end),learningday(1+nko:end),'o','Color',wtc,'MarkerSize',siz); hold on
plot(1+jit(sbj),learningday(sbj),'ko','MarkerSize',siz); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
set(gca,'XTick',1:2)
set(gca,'XTickLabel',{'KO','WT'})
ylabel('Day of learning')
subplot(1,2,2)
boxplot(learningtrial,group,'Color',[.6 .6 .6]); hold on
plot(1+jit(1:nko),learningtrial(1:nko),'o','Color',koc,'MarkerSize',siz); hold on
plot(2+jit(1+nko:end),learningtrial(1+nko:end),'o','Color',wtc,'MarkerSize',siz); hold on
plot(1+jit(sbj),learningtrial(sbj),'ko','MarkerSize',siz); hold on
plot([.5 2.5],[19 19],'--','Color',[.6 .6 .6]); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
set(gca,'XTick',1:2)
set(gca,'XTickLabel',{'KO','WT'})
ylabel('Time of learning')


for k = 1:length(Datas)
    dslope(k) = deltaslope{k}(1);
end

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',[5 5 3.5 4])
plot(1+jit(1:nko),dslope(1:nko),'o','Color',koc,'MarkerSize',siz); hold on
plot(2+jit(1+nko:end),dslope(1+nko:end),'o','Color',wtc,'MarkerSize',siz); hold on
plot(1+jit(sbj),dslope(sbj),'ko','MarkerSize',siz); hold on
boxplot(dslope,group,'Color',[.6 .6 .6]); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
set(gca,'XTick',1:2)
set(gca,'XTickLabel',{'KO','WT'})
ylabel('Learning rate')
