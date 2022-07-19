% Silvia Maggi
% October 2020
% This analysis is based on the model described in Balci et al., 2007,2009
% Here the code for the simplified and generalized model described in Maggi et al., 2014
% This code analyzes timestamps data and code events extracted from TSE operant boxes.
% data is provided as csv files (first column contains timestamps, second column
% event codes)

% This code reproduce Figure 5 in Maggi et al., 2022, Scientific Reports
%% *****************************
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
barsize = [5 5 6 4];
siz = 3;
lin = 1.5;
cmap = brewermap(ntype,'Set1');
wtc = cmap(2,:); wtc_trasp = [cmap(2,:) 0.3];
koc =  cmap(1,:); koc_trasp = [cmap(1,:) 0.3];
cmaptime = brewermap(ntype,'Set2'); 
kocmap = brewermap(7,'OrRd');
wtcmap = brewermap(7,'Blues');
fontsize = 7;
axlinewidth = 0.5;

%% COMMENT OR UNCOMMENT THE RELEVANT DATASET HERE BELOW
%% WEEK 1
% run('Training 3vs9 probe\Load_data.m');
%% WEEK 2
run('Training 3vs9\Load_data.m');

% definition of short and long time interval
t0 = 3; % short time interval (sec), always in the left hopper
t1 = 9; % long time interval (sec), always in the right hopper

for i = 1 : length(Datas)

    clear data
    data(:,1) = Datas{i}(:,1)/1000; % convert millisec in sec and rename
    data(:,2) = Datas{i}(:,2);

    %% This function extract index of reward, start and stop of every long
    % rewarded trial
    [longTrialReward, longTrialOn, longTrialOff] = f_longRewardedTrial(data);

    %% This function record all the right and left nosepokes for the long 
    % rewarded trials 
    [nosepoke_LongSwitchTrial] = f_nosepokesLongRewTrial(data,longTrialOn,longTrialOff);

    %% This function record all the switch latecies. CHECK before make this a function 

    switchLatencies = NaN(size(nosepoke_LongSwitchTrial,1),1);
    hourStartSwitch = NaN(size(nosepoke_LongSwitchTrial,1),1);

    for trial = 1: size(nosepoke_LongSwitchTrial,1)
        if ~isempty(nosepoke_LongSwitchTrial{trial,1}) && ~isempty(nosepoke_LongSwitchTrial{trial,2})
            clear timeL timeR 
            timeL = nosepoke_LongSwitchTrial{trial,1}; % absolute time of left interval nosepokes
            timeR = nosepoke_LongSwitchTrial{trial,2}; % absolute time of right interval nosepokes

            clear checkSW % clear
            checkSW = find(timeL(:,2)<min(timeR(:,1))); % find all short response offset that occured prior to the first long response onset
            if ~isempty(checkSW)
                %########################################
                    % CHECK THIS. Are there other possible combination
                    % that I'm missing? 
                    switchLatencies(trial) = timeL(max(checkSW),2); % then take the maximum short poke off that is shorter than the minimum long response on
                %########################################

                    % this part only if interested in the circadian analysis
                    startTrialTime = data(longTrialOn(trial),1); % real start time in seconds of long switch trial
                    start_time = f_start_time(data); % start time of the training session
                    hourStartSwitch(trial) = floor((startTrialTime+start_time)/3600); % find the hours of the switch trial from the beginning of the training             
            end
        end
    end
    switchLatencies(isnan(switchLatencies)) = [];
    hourStartSwitch(isnan(hourStartSwitch)) = [];

    %########################################
    % Estimate parameters for switch latencies distribution
    % CHECK THIS. Is the normal distribution the best distribution for the
    % switch latencies? Probably not
    [muHat(i),sigmaHat(i)] = normfit(switchLatencies);
    % fit a mix gaussian model
    GMModel = fitgmdist(switchLatencies,2);
    %########################################
    x = min(switchLatencies):.1:max(switchLatencies);

end

%% build Expected Gain 
% Initialize values
mesh = 600;
cv = linspace(0.05,.5,mesh);
media = linspace(1, 9, mesh);
Ps = 0.5; % probability of short trial
CPsp = 0.2; % conditional probability of short trial
Pl = 0.5; % prob of long tr
CPlp = 0.2; % cond prob of long tr

expG = zeros(length(media),length(cv));
normEG = zeros(length(media),length(cv));
maxRow = zeros(length(cv),1);

for i = 1:length(media)
    %% build the Expected Gain Function for every combination of mu and cv 
    clear phi_S phi_L
    phi_S = normcdf(t0,media(i),cv.*media(i)); 
    phi_L = normcdf(t1,media(i),cv.*media(i)); 

    expG(i,:) = (Ps*(1-CPsp)*(1-phi_S)+Pl*(1-CPlp)*(phi_L));  
end
expG = expG';
for i = 1:length(cv)
    normEG(i,:) = expG(i,:)./max(expG(i,:));
    idx = max(normEG(i,:));
    maxRow(i) = find(normEG(i,:)==idx,1,'first');
end

for i = 1:length(Datas)
    indMu(i) = find(media<=muHat(i),1,'last');
    indCV(i) = find(cv<=sigmaHat(i)/muHat(i),1,'last');
end


figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize)  
imagesc(normEG); hold on
set(gca,'YDir','normal')
shading interp
colormap(gray); colorbar
plot(indMu(1:nko),indCV(1:nko),'o','Color',koc,'MarkerFaceColor',koc,'MarkerEdge','w'); hold on
plot(indMu(1+nko:end),indCV(1+nko:end),'o','Color',wtc,'MarkerFaceColor',wtc,'MarkerEdge','w'); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Accuracy (\mu)'); 
ylabel('Uncertainty (CV)'); 
title('Normalized Expected Gain')
set(gca,'YTick',1:(mesh/10)*2:length(cv))
set(gca,'YTickLabel',round(cv(1:(mesh/10)*2:length(cv)),2))
set(gca,'XTick',1:(mesh/(media(end)-media(1))):length(media))
set(gca,'XTickLabel',round(media(1:(mesh/(media(end)-media(1))):length(media)),1))
plot(maxRow,1:length(cv),'k'); hold on

mu_group = media(indMu);
cv_group = cv(indCV);
group = {koname koname koname koname koname koname wtname wtname wtname wtname wtname wtname};

jit = randn(nko+nwt,1)*.2;
figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize2)  
subplot(1,2,1)
plot(1+jit(1:nko),mu_group(1:nko),'o','Color',koc,'MarkerSize',siz); hold on
plot(2+jit(1+nko:end),mu_group(1+nko:end),'o','Color',wtc,'MarkerSize',siz); hold on
boxplot(mu_group,group,'Color',[.6 .6 .6]); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
ylabel('\mu')
subplot(1,2,2)
plot(1+jit(1:nko),cv_group(1:nko),'o','Color',koc,'MarkerSize',siz); hold on
plot(2+jit(1+nko:end),cv_group(1+nko:end),'o','Color',wtc,'MarkerSize',siz); hold on
boxplot(cv_group,group,'Color',[.6 .6 .6]); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
ylabel('CV')

[h,p] = kstest2(mu_group(1:nko),mu_group(nko+1:end));
[h,p] = kstest2(cv_group(1:nko),cv_group(nko+1:end));
