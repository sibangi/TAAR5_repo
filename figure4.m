% SILVIA MAGGI 18/07/2022
% Script for the analysis of probes trials: compare Mutant and Wild type.
% Figure 4 of Maggi etal., 2022 Scientific Reports

clearvars
close all

run('Training 3vs9 probe\Load_data.m');
t0 = 3;
t1 = 9;
nko = 6; koname = 'KO';
nwt = 6; wtname = 'WT';
homname = '';
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
cmaptime = brewermap(ntype,'Set2'); 
kocmap = brewermap(7,'OrRd');
wtcmap = brewermap(7,'Blues');
fontsize = 7;
axlinewidth = 0.5;

%% *****************
NPTsh = zeros(24,length(Datas));
DPTsh = zeros(24,length(Datas));
SmoothDataSh = zeros(length(Datas),2000);
SmoothDataLg = zeros(length(Datas),2000);

s1_sh = zeros(length(Datas),1); s2_sh = zeros(length(Datas),1);
s1_lg = zeros(length(Datas),1); s2_lg = zeros(length(Datas),1);

X = cell(length(Datas),1); PeaksShortNorm = cell(length(Datas),1);
PeaksLongNorm = cell(length(Datas),1); PP = cell(length(Datas),1);
PL = cell(length(Datas),1); Delay_sh = cell(length(Datas),1);
Delay_lg = cell(length(Datas),1); DurSh = cell(length(Datas),1);
StartHourSh = cell(length(Datas),1); NumNPSh = cell(length(Datas),1);
StartHourLg = cell(length(Datas),1); NumNPLg = cell(length(Datas),1);
InitHSh = cell(length(Datas),1);
for i = 1 : length(Datas)
    [X{i}, PeaksShortNorm{i}, PeaksLongNorm{i}, PP{i}, PL{i}, Delay_sh{i}, ...
        Delay_lg{i},DurSh{i},StartHourSh{i},~,NumNPSh{i},...
        ~,StartHourLg{i},~,NumNPLg{i}] = f_probesShortLong(Datas{i},t0,t1);
    InitHSh{i} = round(rem(nonzeros(StartHourSh{i}),24));

    SmoothDataSh(i,:) = smooth(PeaksShortNorm{i},0.1,'rloess');
    SmoothDataLg(i,:) = smooth(PeaksLongNorm{i},0.1,'rloess');
    
    SmoothDataSh(i,:) = SmoothDataSh(i,:)./max(SmoothDataSh(i,:));
    SmoothDataLg(i,:) = SmoothDataLg(i,:)./max(SmoothDataLg(i,:));
    
    i1 = find(SmoothDataSh(i,:)>=0.5);
    if ~isempty(i1)
        s1_sh(i) = X{i}(i1(1)); s2_sh(i) = X{i}(i1(end));
        idxpeak = find(PeaksShortNorm{i}==max(PeaksShortNorm{i}),1,'first');
        peaks_sh(i) = X{i}(idxpeak);
    end
    
    i2 = find(SmoothDataLg(i,:)>=0.5);
    if ~isempty(i2)
        s1_lg(i) = X{i}(i2(1)); s2_lg(i) = X{i}(i2(end));
        idxpeak = find(PeaksLongNorm{i}==max(PeaksLongNorm{i}),1,'first');
        peaks_lg(i) = X{i}(idxpeak);
    end
    
    % analysis on circadian cycle
    for j = 0:23
        indIn = find(InitHSh{i}==j);
        NPTsh(j+1,i) = length(indIn);
        if isempty(DurSh{i}(indIn))==0
            DPTsh(j+1,i) = median(DurSh{i}(indIn));
        end
    end
end

for tt = 1 %:length(Datas)
    %% Plot NP distribution during short probe for an example subject 
    f_plot_NPprobe(Datas{tt},t0,t1)

    %% plot distributions of NPs during probe trials for an example subject
    figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize1)  
    plot(X{tt},SmoothDataSh(tt,:),'k-'); hold on
    plot(X{tt},SmoothDataLg(tt,:),'k-'); hold on

    plot([t0 t0],[0 max(SmoothDataSh(tt,:))],'--','Color',cmaptime(1,:)); hold on 
    plot([t1 t1],[0 max(SmoothDataSh(tt,:))],'--','Color',cmaptime(2,:)); hold on 
    set(gca,'FontName','Helvetica','FontSize',fontsize);
    set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
    xlabel('Time (sec.)')
    ylabel('Normalized NP distribution')
    title(['Probes ',num2str(tt)])

end

cdf_sh = cumsum(SmoothDataSh,2)./max(cumsum(SmoothDataSh,2),[],2);
cdf_lg = cumsum(SmoothDataLg,2)./max(cumsum(SmoothDataLg,2),[],2);

figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize2)  
subplot(1,2,1)
plot(X{1},cdf_sh(1:nko,:),'-','Color',koc_trasp); hold on
plot(X{1},cdf_sh(1+nko:end,:),'-','Color',wtc_trasp); hold on
plot(X{1},mean(cdf_sh(1:nko,:),'omitnan'),'-','Color',koc,'LineWidth',1.5); hold on
plot(X{1},mean(cdf_sh(1+nko:end,:),'omitnan'),'-','Color',wtc,'LineWidth',1.5); hold on
plot([t0 t0],[0 1],'--','Color',[.6 .6 .6]); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Time (sec.)')
ylabel('CDF NP')
title('Short probe')

subplot(1,2,2)
plot(X{1},cdf_lg(1:nko,:),'-','Color',koc_trasp); hold on
plot(X{1},cdf_lg(1+nko:end,:),'-','Color',wtc_trasp); hold on
plot(X{1},mean(cdf_lg(1:nko,:),'omitnan'),'-','Color',koc,'LineWidth',1.5); hold on
plot(X{1},mean(cdf_lg(1+nko:end,:),'omitnan'),'-','Color',wtc,'LineWidth',1.5); hold on
plot([t1 t1],[0 1],'--','Color',[.6 .6 .6]); hold on
set(gca,'FontName','Helvetica','FontSize',fontsize);
set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
xlabel('Time (sec.)')
title('Long probe')

