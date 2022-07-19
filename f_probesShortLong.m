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
% t0 = 3;
% t1 = 6;

function [X,PeaksShortNorm,PeaksLongNorm,PP,PL,Delay_short,Delay_long,...
    DurSh,StartHourSh,StopHourSh,NumNPSh,DurLg,StartHourLg,StopHourLg,NumNPLg] = f_probesShortLong(Datas,t0,t1)

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
        % if last poke is in long location record as long probe trial
        if Datas(Probes(i)-1,2)==27
            ProbesLong(end+1) = Probes(i)-1;
        end
        % if last poke is in short location record as short probe trial
        if Datas(Probes(i)-1,2)==23
            ProbesShort(end+1) = Probes(i)-1;
        end
    end

%     PercProbesLong = length(ProbesLong)/(length(ProbesLong)+Long);
%     PercProbesShort = length(ProbesShort)/(length(ProbesShort)+Short);

    RasterLeft = zeros(length(ProbesShort),2000);

    StartTimeSh = zeros(length(ProbesShort),1); EndTimeSh = zeros(length(ProbesShort),1);
    NumNPSh = zeros(length(ProbesShort),1); DurSh = zeros(length(ProbesShort),1); 
    StartHourSh = zeros(length(ProbesShort),1); StopHourSh = zeros(length(ProbesShort),1);
   
    StartProbesShort = zeros(length(ProbesShort),1);
    EndProbesShort = zeros(length(ProbesShort),1);
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
            TimeLeftOn = temporarydata(LeftRespOn,1)-temporarydata(1,1);
            TimeLeftOff = temporarydata(LeftRespOff,1)-temporarydata(1,1);
            if length(TimeLeftOn)>length(TimeLeftOff)
                TimeLeftOn(end) = [];
            end
            StartTimeSh(j) = temporarydata(LeftRespOn(1),1)-temporarydata(1,1);
            EndTimeSh(j) = temporarydata(LeftRespOff(end),1)-temporarydata(1,1);
            NumNPSh(j) = length(TimeLeftOn);
            DurSh(j) = EndTimeSh(j)-StartTimeSh(j); % time interval from first NP and last NP in short probe
            % times from beginning of training of first and last NP in
            % short location for short probe
            StartHourSh(j) = temporarydata(LeftRespOn(1),1)/3600 + Hour_start;
            StopHourSh(j) = temporarydata(LeftRespOff(end),1)/3600 + Hour_start;

            RL = zeros(length(TimeLeftOff),2000);
            for k = 1:length(TimeLeftOff)
                for i = 1:2000
                    if (((i-1)/100)>=TimeLeftOn(k)) && (((i-1)/100)<=TimeLeftOff(k))
                        RL(k,i) = 1;
                    else
                        RL(k,i) = 0;
                    end
                end
            end
            if size(RL,1)==1
                RasterLeft(j,:) = RL;
            else
                RasterLeft(j,:) = sum(RL);
            end
        end
    end
    
    Peaks = zeros(size(RasterLeft,2),1);
    for t = 1:size(RasterLeft,2)
        Peaks(t) = sum(RasterLeft(:,t));
    end
    X = 1:0.0095009:20;
    PP = find(Peaks==max(Peaks),1,'first');
    Delay_short = (X(PP)-(t0));
    
    PeaksShort = Peaks;

    % **********************************************

    RasterRight = zeros(length(ProbesLong),2000);
    StartTimeLg = zeros(length(ProbesShort),1); EndTimeLg = zeros(length(ProbesShort),1); 
    NumNPLg = zeros(length(ProbesShort),1); DurLg = zeros(length(ProbesShort),1); 
    StartHourLg = zeros(length(ProbesShort),1); StopHourLg = zeros(length(ProbesShort),1);

    StartProbesLong = zeros(length(ProbesShort),1);
    EndProbesLong = zeros(length(ProbesShort),1);

    % ANALISI DEI LONG PROBES TRIALS
    for j = 1: length(ProbesLong)
        clear RightRespOn
        clear RightRespOff
        IndStartLong = find(AllTrials<=ProbesLong(j),1,'last');
        % individuo l'indice di inizio del long probes trial
        StartProbesLong(j) = AllTrials(IndStartLong);
        % individuo la "fine" del long probes trial, la fine corrispondente
        % al codice 33 di fine ITI
        if EndITI(end)>= ProbesLong(j)
            IndEndLong = find(EndITI>=ProbesLong(j),1,'first');
            EndProbesLong(j) = EndITI(IndEndLong);
            temporarydata = Datas(StartProbesLong(j):EndProbesLong(j),:);
            % Analizzo quello che accade nello short probes trial: registro tutti i
            % left nosepokes in e out
            RightRespOn_old = find(temporarydata(:,2)==27);  % Right On
            RightRespOff_old = find(temporarydata(:,2)==28); % Right Off
            RightRespOn = RightRespOn_old;
            RightRespOff = RightRespOff_old;
            if length(RightRespOn)>length(RightRespOff)
                for t = 1:length(RightRespOff_old)-1
                    if (RightRespOn(t+1)<RightRespOff(t))
                        RightRespOn(t+1)=[];
                    end
                end
            end

            if length(RightRespOn)>length(RightRespOff)
                RightRespOn(end) = [];
            end
            if (length(RightRespOn)-length(RightRespOff))>0
                continue
            end
            if isempty(RightRespOn)==0
                TimeRightOn = temporarydata(RightRespOn,1)-temporarydata(1,1);
                TimeRightOff = temporarydata(RightRespOff,1)-temporarydata(1,1);
                
                StartTimeLg(j) = temporarydata(RightRespOn(1),1)-temporarydata(1,1);
                EndTimeLg(j) = temporarydata(RightRespOff(end),1)-temporarydata(1,1);
                NumNPLg(j) = length(TimeRightOn);
                DurLg(j) = EndTimeLg(j)-StartTimeLg(j);
                StartHourLg(j) = temporarydata(RightRespOn(1),1)/3600 + Hour_start;
                StopHourLg(j) = temporarydata(RightRespOff(end),1)/3600 + Hour_start;        
            
                RR = zeros(length(TimeRightOff),2000);
                for k = 1:length(TimeRightOff)
                    for i = 1:2000
                        if (((i-1)/100)>=TimeRightOn(k)) && (((i-1)/100)<=TimeRightOff(k))
                            RR(k,i) = 1;
                        else
                            RR(k,i) = 0;
                        end
                    end
                end
                if size(RR,1)==1
                    RasterRight(j,:) = RR;
                else
                    RasterRight(j,:) = sum(RR);
                end
            end
        end
    end

    Peaks = zeros(size(RasterRight,2),1);
    for t = 1:size(RasterRight,2)
        Peaks(t) = sum(RasterRight(:,t));
    end
    X = [1:0.0095009:20];
    PL = find(Peaks==max(Peaks),1,'first');
    Delay_long = (X(PL)-(t1));
   
    PeaksLong = Peaks;
    
%     % ANALISI DEGLI START AND STOP PER I SHORT PROBES TRIALS
%     if length(ProbesShort)>10
%         ShStartFit = robustfit(1:length(ProbesShort), StartTimeSh);
%         ShStopFit = robustfit(1:length(ProbesShort), EndTimeSh);
%     end
%         
%     % ANALISI DEGLI START AND STOP PER I LONG PROBES TRIALS
%     if length(ProbesLong)>10
%         LgStartFit = robustfit(1:length(ProbesLong), StartTimeLg);
%         LgStopFit = robustfit(1:length(ProbesLong), EndTimeLg);
%     end
    
    % NORMALIZZO LE CURVE DI PEAKS PROCEDURE
    PeaksShortNorm = PeaksShort(:)/max(PeaksShort);
    PeaksLongNorm = PeaksLong(:)/max(PeaksLong);
    
return