% NOTES
% Silvia Maggi
% May 2011
% This code is to analyze Valter's switch data (probes trial).
% Data is provided as csv files
% I assume the short interval was t0 and long interval was t1 sec
% Action time is recorded every 0.01 sec

%% Event Code
%  1    StartMonth
%  2    StartDay
%  3    StartYear
%  4    StartHour
%  5    StartMinute
%  6    StartSecond
%  8    EndMonth
%  9    EndDay
% 10    EndYear
% 15	cHouseLightON
% 16	cHouseLightOFF
% 17	cLeftLightON
% 18	cLeftLightOFF
% 19	cMidLightON
% 20	cMidLightOFF
% 21	cRightLightON
% 22	cRightLightOFF
% 23	cLeftHopperIN
% 24	cLeftHopperOUT
% 25	cMidHopperIN
% 26	cMidHopperOUT
% 27	cRightHopperIN
% 28	cRightHopperOUT
% 29	cGivePelletLeft
% 30	cGivePelletRight
% 33    cEndInterTrialInterval
% 35    cProbesTrial

%%
% load TAAR5_1040_1.csv;
% Datas = TAAR5_1040_1;
% t0 = 3;
% t1 = 6;

function  f_plot_NPprobe(Datas,t0,t1)

    % figure properties
    barsize = [5 5 5 4];
    fontsize = 7;
    axlinewidth = 0.5;
    ntype = 2;
    cmaptime = brewermap(ntype,'Set2'); 
    
    
    hour = find(Datas(:,2)==4,1,'first');
    Hour_start = Datas(hour,1);
    
    Datas(:,1) = Datas(:,1)/1000;
    
    AllTrials = find(Datas(:,2)==19); %All=length(AllTrials)
%     ShortRewarded = find(Datas(:,2)==29); %Short=length(ShortRewarded);
%     LongRewarded = find(Datas(:,2)==30); %Long=length(LongRewarded);
    Probes = find(Datas(:,2)==35);
    EndITI = find(Datas(:,2)==33);
    ProbesLong = []; ProbesShort = [];

    for i = 1:length(Probes)
%         % if last poke is in long location record as long probe trial
%         if Datas(Probes(i)-1,2)==27
%             ProbesLong(end+1) = Probes(i)-1;
%         end
        % if last poke is in short location record as short probe trial
        if Datas(Probes(i)-1,2)==23
            ProbesShort(end+1) = Probes(i)-1;
        end
    end


    RasterLeft = zeros(length(ProbesShort),2000);

    StartTimeSh = zeros(length(ProbesShort),1); EndTimeSh = zeros(length(ProbesShort),1);
    NumNPSh = zeros(length(ProbesShort),1); DurSh = zeros(length(ProbesShort),1); 
    StartHourSh = zeros(length(ProbesShort),1); StopHourSh = zeros(length(ProbesShort),1);
   
    StartProbesShort = zeros(length(ProbesShort),1);
    EndProbesShort = zeros(length(ProbesShort),1);
    TimeLeftOn = cell(length(ProbesShort),1);
    TimeLeftOff = cell(length(ProbesShort),1);    
    % ANALISI DEI SHORT PROBES TRIALS
    for j = 1: length(ProbesShort)
        indStartShort = find(AllTrials<=ProbesShort(j),1,'last');
        % individuo l'indice di inizio dello short probes trial
        StartProbesShort(j) = AllTrials(indStartShort);
        % individuo la "fine" dello short probes trial, la fine corrispondente
        % al codice 33 di fine ITI
        if EndITI(end)>=ProbesShort(j) % stop before the end of last ITI
            indEndShort= find(EndITI>=ProbesShort(j),1,'first');
            EndProbesShort(j) = EndITI(indEndShort);
            temporarydata = Datas(StartProbesShort(j):EndProbesShort(j),:);
            % Analizzo quello che accade nello short probes trial: registro tutti i
            % left nosepokes in e out
            LeftRespOn = find(temporarydata(:,2)==23);  % Left On
            LeftRespOff = find(temporarydata(:,2)==24); % Left Off
            TimeLeftOn{j} = temporarydata(LeftRespOn,1)-temporarydata(1,1);
            TimeLeftOff{j} = temporarydata(LeftRespOff,1)-temporarydata(1,1);
            if length(TimeLeftOn{j})>length(TimeLeftOff{j})
                TimeLeftOn{j}(end) = [];
            end
        end
    end
    
    figure('Units', 'centimeters', 'PaperPositionMode', 'auto','Position',barsize)  
    for j = 1: length(ProbesShort)
        plot([TimeLeftOn{j} TimeLeftOff{j}],[ones(length(TimeLeftOn{j}),1)*j ...
            ones(length(TimeLeftOn{j}),1)*j],'-','Color',[.6 .6 .6]); hold on
    end
    plot([t0 t0],[0 length(ProbesShort)],'-','Color',cmaptime(1,:)); hold on
    plot([t1 t1],[0 length(ProbesShort)],'-','Color',cmaptime(2,:)); hold on
    xlim([0 20])
    ylim([0 length(ProbesShort)])
    set(gca,'FontName','Helvetica','FontSize',fontsize);
    set(gca,'Box','off','TickDir','out','LineWidth',axlinewidth);
    xlabel('Time (sec.)')
    ylabel('Probe trial')
    title('NP over time')


return