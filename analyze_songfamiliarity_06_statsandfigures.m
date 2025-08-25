% Stats and figures

% Other m-files required: 
% EEGLAB toolbox: https://github.com/sccn/eeglab
% /private/doPermTest2.m
% /private/formatNBP.m
% /private/makefigure.m
% /private/subtightplot.m
% /private/figset.m

% Author: Cameron Hassall, Department of Psychology, MacEwan University
% email address: hassallc@macewan.ca
% Website: http://www.cameronhassall.com

%% Fig. 1 Behavioural
close all; clear all; figset;

% Input arguments (defaults exist):
%   gap- two elements vector [vertical,horizontal] defining the gap between neighbouring axes. Default value
%            is 0.01. Note this vale will cause titles legends and labels to collide with the subplots, while presenting
%            relatively large axis. 
%   marg_h  margins in height in nxormalized units (0...1)
%            or [lower uppper] for different lower and upper margins 
%   marg_w  margins in width in normalized units (0...1)
%            or [left right] for different left and right margins 
gap = [0.01 0.08];
marg_h = [0.35 0.15];
marg_w = [0.06 0.01];
subplot = @(m,n,i) subtightplot (m, n, i, gap, marg_h, marg_w);

load(fullfile(resultsFolder,'beh_results.mat'));

% Remove additional participants here
% sub-11: only one familiar and one familiar recognized
% sub-18: no familiar songs
% sub-30: more than 3 interpolated electrodes
toRemove = {'sub-11','sub-18','sub-30'};
toRemoveI = find(contains(subjs,toRemove));
subjs(toRemoveI) = [];
allNumFamiliar(toRemoveI,:) = [];
allNumNotes(toRemoveI,:) = [];
numID(toRemoveI,:) = [];
numMC(toRemoveI,:) = [];

makefigure(18,6);

subplot(1,4,1);
disp('Number of songs');
[h,stats]  = notBoxPlot(allNumFamiliar,'interval','tinterval');
disp([stats.mu]);
disp([stats.mu] - [stats.interval]);
disp([stats.mu] + [stats.interval]);
formatNBP(h, plotLineColours([5 1],:));
ax = gca;
ax.XTickLabel = {'unfamiliar','familiar'};
ax.XTickLabelRotation = 45;
ylabel('Number of songs');
set(gca,'Box','off');
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
text(-0.9,125,'(a)','FontWeight','bold');

%
subplot(1,4,2);
disp('Number of notes');
[h,stats] = notBoxPlot(allNumNotes);
disp([stats.mu]);
disp([stats.mu] - [stats.interval]);
disp([stats.mu] + [stats.interval]);
formatNBP(h, plotLineColours([5 1],:));
ax = gca;
ax.XTickLabel = {'unfamiliar','familiar'};
ax.XTickLabelRotation = 45;
ylabel('Number of notes');
set(gca,'Box','off');
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
text(-0.9,2000*1.25,'(b)','FontWeight','bold');

%
subplot(1,4,3);

disp('Proportion identified - Text');
[h,stats] = notBoxPlot([numID(:,1) numID(:,2)]);
disp([stats.mu]);
disp([stats.mu] - [stats.interval]);
disp([stats.mu] + [stats.interval]);
formatNBP(h,plotLineColours([5 1],:));
ax = gca;
ax.XTickLabel = {'unfamiliar','familiar'};
ax.XTickLabelRotation = 45;
ax.YLim = [0,1];
ylabel('Proportion identified - Text');
set(gca,'Box','off');
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
text(-0.9,1.25,'(c)','FontWeight','bold');

%
subplot(1,4,4);

disp('Proportion identifined - MC');
[h,stats] = notBoxPlot(numMC);
hold on;
yline(0.25,'LineStyle',':');
disp([stats.mu]);
disp([stats.mu] - [stats.interval]);
disp([stats.mu] + [stats.interval]);
formatNBP(h, plotLineColours([5 1],:));
ax = gca;
ax.XTickLabel = {'unfamiliar','familiar', 'familiar'};
ax.XTickLabelRotation = 45;
ylabel('Proportion identified - MC');
text(-0.9,1.25,'(d)','FontWeight','bold');
% ylim([0 50]);

set(gca,'Box','off');
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');

print(fullfile(figuresFolder,'fig_02.tiff'),'-dtiff','-r600');

%% Fig. 2: EEG Analysis 1
close all; clear all; figset;

% Input arguments (defaults exist):
%   gap- two elements vector [vertical,horizontal] defining the gap between neighbouring axes. Default value
%            is 0.01. Note this vale will cause titles legends and labels to collide with the subplots, while presenting
%            relatively large axis. 
%   marg_h  margins in height in normalized units (0...1)
%            or [lower uppper] for different lower and upper margins 
%   marg_w  margins in width in normalized units (0...1)
%            or [left right] for different left and right margins 
% gap = [0.04 0.06];
% marg_h = [0.02 0.05];
% marg_w = [0.06 0.02];
% subplot = @(m,n,i) subtightplot (m, n, i, gap, marg_h, marg_w);
load(fullfile(resultsFolder,'results_1_1.mat'));

% Remove additional participants here
% sub-11: only one familiar and one familiar recognized
% sub-30: more than 3 interpolated electrodes
toRemove = {'sub-11','sub-30'};
toRemoveI = find(contains(subjStrs,toRemove));
subjStrs(toRemoveI) = [];
allBeta(toRemoveI,:,:) = [];

% Check the lambdas
regPar(toRemoveI) = [];
sum(regPar == 10000)
sum(regPar == 100000)

times = EEG.unfold.times;

winSec = [.252 0.472]';
noteWindow = [-0.2 0.8];
noteBL = [-0.2 0];

unfamiliar = allBeta(:,:,1:breakpoints(1));
familiar = allBeta(:,:,(breakpoints(1)+1):breakpoints(2));
noteBLPts = dsearchn(times',noteBL');
unfamiliarBL = unfamiliar - mean(unfamiliar(:,:,noteBLPts(1):noteBLPts(2)),3);
familiarBL = familiar - mean(familiar(:,:,noteBLPts(1):noteBLPts(2)),3);
diffBL =  familiarBL - unfamiliarBL;

% Stats - Uncomment to run
% rng(2025)
% clusterWindow = [0 0.6];
% clusterPnts = dsearchn(times',clusterWindow');
% [clusterInfo] = doPermTest2(diffBL(:,:,clusterPnts(1):clusterPnts(2)),.05,neighbours,EEG);
% Result: No clusters found

unfamiliarM = squeeze(mean(unfamiliarBL,1));
familiarM = squeeze(mean(familiarBL,1));
differenceM = familiarM-unfamiliarM;
difference = familiarBL - unfamiliarBL;

makefigure(8.5,5.5);
channelS = 'FCz';
channelI = eeg_chaninds(EEG,channelS);
uMean = squeeze(mean(mean(unfamiliarBL(:,channelI,:),2),1));
fMean = squeeze(mean(mean(familiarBL(:,channelI,:),2),1));
plot(times,uMean,'Color',plotLineColours(1,:),'LineWidth',lineWidth); hold on;
plot(times,fMean,'Color',plotLineColours(2,:),'LineWidth',lineWidth);
channelS = 'CPz';
channelI = eeg_chaninds(EEG,channelS);
uMean = squeeze(mean(mean(unfamiliarBL(:,channelI,:),2),1));
fMean = squeeze(mean(mean(familiarBL(:,channelI,:),2),1));
plot(times,uMean,'Color',plotLineColours(1,:),'LineStyle','--','LineWidth',lineWidth);
plot(times,fMean,'Color',plotLineColours(2,:),'LineStyle','--','LineWidth',lineWidth);
xlim(noteWindow);
%ylim([-0.8 0.5]);
xlabel('Time (s)');
ylabel('Voltage (\muV) ')
l = legend({'unfamiliar (FCz)','familiar (FCz)','unfamiliar (CPz)','familiar (CPz)'},'Location','southwest','Box','off');
set(gca,'Box','off');
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
print(fullfile(figuresFolder,'fig_03b.tiff'),'-dtiff','-r600');

% * * * Response-locked Analysis * * *

% Settings
respWindow = [-1 0.1];
winSec = [-0.364 0.1]';
respBL = [-1.2 -1.0];
respBLPts = dsearchn(times',respBL');

% Baseline correction
response = allBeta(:,:,(breakpoints(2)+1):end);
responseBL = response - mean(response(:,:,respBLPts(1):respBLPts(2)),3);
responseM = squeeze(mean(responseBL,1));

% Stats - Uncomment to run
% rng(2025);
% clusterWindow = [-1 0.1];
% clusterPnts = dsearchn(times',clusterWindow');
% [clusterInfo] = doPermTest2(responseBL(:,:,clusterPnts(1):clusterPnts(2)),.05,neighbours,EEG);
% timeStart =  times((clusterPnts(1) + (160-1)))
% timeEnd =  times((clusterPnts(1) + (276-1)))
% %Result 1: O1, -.364 to .100, p = = .0017, Cohen's d = 0.71;

makefigure(8.5,5.5);
channelS = 'O1';
channelI = find(strcmp({EEG.chanlocs.labels},channelS));

neighbI = find(strcmp(channelS,{neighbours.label}));
channelIs = [channelI eeg_chaninds(EEG,neighbours(neighbI).neighblabel)];

thisERP = squeeze(responseBL(:,channelI,:));
thisMean = squeeze(mean(responseBL(:,channelI,:),1));
thisSD = squeeze(std(responseBL(:,channelI,:),[],1));
tval = tinv(0.025,length(subjStrs)-1);
thisCI = tval * thisSD ./sqrt(length(subjStrs));
plot(times,thisMean,'Color',plotLineColours(3,:),'LineWidth',lineWidth); hold on;
areaAlpha = 0.25;
plot(winSec,[0.1 0.1],'Color',[0,0,0,areaAlpha],'LineWidth',3);
xlim(respWindow);
ylim([0 1.5]);
text(-1,1.5,'  O1,Oz','FontSize',8);
%title('Response-locked','FontWeight','normal');
xlabel('Time (s)');
ylabel('Voltage (\muV) ')
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');;
print(fullfile(figuresFolder,'fig_03c.tiff'),'-dtiff','-r600');

makefigure(6,3);
winPnt = dsearchn(times',winSec);
topo = mean(responseM(:,winPnt(1):winPnt(2)),2);
% tp = topoplot(topo,chanlocs,'maplimits',[-respScale,respScale],'electrodes','off','headrad','rim','shading','interp','whitebk','on','style','fill');
tp = topoplot(topo,chanlocs,'electrodes','off','headrad','rim','whitebk','on','style','fill');
tp.Parent.XLim = [-0.6 0.6];
tp.Parent.YLim = [-0.6 0.6];
colormap(myColormap);
c = colorbar();
c.Label.String = 'Voltage (\muV)';
c.Label.FontName = fontName;
c.Label.FontSize = fontSize;
c.Location = 'eastoutside';
% c.Position(2) = c.Position(2)-0.15;
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
 % exportgraphics(gca,fullfile(figuresFolder,'fig_03c_inset.pdf'), 'BackgroundColor','none','ContentType','vector','Resolution',600);
print(fullfile(figuresFolder,'fig_03c_inset.tiff'),'-dtiff','-r600');

%% EEG Analysis 2
close all; clear all; figset;

% Input arguments (defaults exist):
%   gap- two elements vector [vertical,horizontal] defining the gap between neighbouring axes. Default value
%            is 0.01. Note this vale will cause titles legends and labels to collide with the subplots, while presenting
%            relatively large axis. 
%   marg_h  margins in height in normalized units (0...1)
%            or [lower uppper] for different lower and upper margins 
%   marg_w  margins in width in normalized units (0...1)
%            or [left right] for different left and right margins 
gap = [0.18 0.12];
marg_h = [0.1 0.05];
marg_w = [0.08 0.02];
subplot = @(m,n,i) subtightplot (m, n, i, gap, marg_h, marg_w);
load(fullfile(resultsFolder,'results_2_1.mat')); % Switch to 'results_3_1.mat' to exclude identified trials

% Remove additional participants here
% sub-11: only one familiar and one familiar recognized
% sub-30: noisy EEG
toRemove = {'sub-11','sub-30'};
toRemoveI = find(contains(subjStrs,toRemove));
subjStrs(toRemoveI) = [];
allBeta(toRemoveI,:,:) = [];

times = EEG.unfold.times;
 
noteWindow = [-0.2 0.8];
noteBL = [-0.2 0];
respWindow = [-1 0.1];
respBL = [-1.2 -1];

times = EEG.unfold.times;

familiar = allBeta(:,:,1:breakpoints(1));
familiarPos = allBeta(:,:,(breakpoints(1)+1):breakpoints(2));
response = allBeta(:,:,(breakpoints(2)+1):end);

% Baseline correction;
noteBLPts = dsearchn(times',noteBL');
respBLPts = dsearchn(times',respBL');
familiarBL = familiar - mean(familiar(:,:,noteBLPts(1):noteBLPts(2)),3);
familiarRTBL = familiarPos - mean(familiarPos(:,:,noteBLPts(1):noteBLPts(2)),3);
responseBL = response - mean(response(:,:,respBLPts(1):respBLPts(2)),3);

% Stats - uncomment to run
% rng(2025);
% clusterWindow = [0 0.6];
% clusterPnts = dsearchn(times',clusterWindow');
% [clusterInfo] = doPermTest2(familiarRTBL(:,:,clusterPnts(1):clusterPnts(2)),.05,neighbours,EEG)
% timeStart =  times((clusterPnts(1) + (118-1)))
% timeEnd =  times((clusterPnts(1) + (123-1)))
% % Result 1: Cluster around FC1 from 308-600 ms, p < .001, d = 1.28
% % Result 2 (Exclude recognized songs): Cluster around F4 from 468-488 ms,
% % p = .014, d = 0.66

% Response-locked stats - uncomment to run
% rng(2025)
% clusterWindow = respWindow;
% clusterPnts = dsearchn(times',clusterWindow');
% [clusterInfo] = doPermTest2(responseBL(:,:,clusterPnts(1):clusterPnts(2)),.05,neighbours,EEG)
% timeStart =  times((clusterPnts(1) + (222-1)))
% timeEnd =  times((clusterPnts(1) + (276-1)))
% Result 1: Cluster around O1 from -0.348 to 0.1, p = .0021, d = 0.65 
% Result 2 (Exclude recognized songs): Cluster around O1 from -0.116 to
% 0.1, p = .005, d = 0.68.

channelS = 'FC1';
channelI = find(strcmp({EEG.chanlocs.labels},channelS));
neighbI = find(strcmp(channelS,{neighbours.label}));
channelIs = [channelI eeg_chaninds(EEG,neighbours(neighbI).neighblabel)];
winSec = [0.308 0.660];
winPnt = dsearchn(times',winSec');

meanBeta = squeeze(mean(allBeta,1,'omitnan'));
familiarM = squeeze(mean(mean(familiarBL(:,channelIs,:),2),1));
familiarSD = squeeze(std(mean(familiarBL(:,channelIs,:),2),[],1));
tval = tinv(0.025,length(subjStrs)-1);
familiarCI = tval * familiarSD ./sqrt(length(subjStrs));


familiarRTM = squeeze(mean(mean(familiarRTBL(:,channelIs,:),2),1));
familiarRTSD = squeeze(std(mean(familiarRTBL(:,channelIs,:),2),[],1));
tval = tinv(0.025,length(subjStrs)-1);
familiarRTCI = tval * familiarRTSD ./sqrt(length(subjStrs));


makefigure(5.7,3.7);
plot(times,familiarM,'Color',plotLineColours(1,:),'LineWidth',lineWidth); 
xlim(noteWindow);
ylim([-0.6 0.7]);
xlabel('Time (s)');
ylabel('Beta weight (\muV)');
text(-0.2,0.7,'  FC1,F3,FCz,C3,Cz,Fz','FontSize',8);
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
print(fullfile(figuresFolder,'fig_04b.tiff'),'-dtiff','-r600');

makefigure(5.7,3.7);
plot(times,familiarRTM,'Color',plotLineColours(2,:),'LineWidth',lineWidth); hold on;
xlim(noteWindow);
ylim([-0.05 0.14]);
areaAlpha = 0.25;
plot(winSec,[0 0],'Color',[0,0,0,areaAlpha],'LineWidth',3);
xlabel('Time (s)');
ylabel('Beta weight (\muV/position)');
text(-0.2,0.14,'  FC1,F3,FCz,C3,Cz,Fz','FontSize',8);
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
print(fullfile(figuresFolder,'fig_04c.tiff'),'-dtiff','-r600');

% Note position topo
makefigure(3.33,5);
lTopo = mean(mean(familiarRTBL(:,:,winPnt(1):winPnt(2)),1),3);
tp = topoplot(lTopo,chanlocs,'electrodes','off','headrad','rim','shading','interp','whitebk','on','style','fill');
tp.Parent.XLim = [-0.6 0.6];
tp.Parent.YLim = [-0.6 0.6];
colormap(myColormap);
c = colorbar();
c.Label.String = 'Beta weight (\muV/position)';
c.Label.FontName = fontName;
c.Label.FontSize = fontSize;
c.Location = 'southoutside';
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
print(fullfile(figuresFolder,'fig_04e.tiff'),'-dtiff','-r600');

% Reconstructed EEG
makefigure(8,4.5);
theseColours = brewermap(5,'Purples');
reconstructedERP10 = familiarM - 10*familiarRTM;
reconstructedERP07 = familiarM - 7*familiarRTM;
reconstructedERP04 = familiarM - 4*familiarRTM;
reconstructedERP01 = familiarM - 1*familiarRTM;
plot(times,reconstructedERP01,'Color',theseColours(5,:),'LineWidth',lineWidth); hold on;
plot(times,reconstructedERP04,'Color',theseColours(4,:),'LineWidth',lineWidth); 
plot(times,reconstructedERP07,'Color',theseColours(3,:),'LineWidth',lineWidth); 
plot(times,reconstructedERP10,'Color',theseColours(2,:),'LineWidth',lineWidth);
xlim(noteWindow);
xlabel('Time (s)');
ylabel('Voltage (\muV)');
text(-0.2,1,'  FC1,F3,FCz,C3,Cz,Fz','FontSize',8);
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
legend('position -1','position -4','position -7','position -10','Box','off');
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
print(fullfile(figuresFolder,'fig_05b.tiff'),'-dtiff','-r600');

% Response-locked 
channelS = 'O1';
channelI = find(strcmp({EEG.chanlocs.labels},channelS));
neighbI = find(strcmp(channelS,{neighbours.label}));
channelIs = [channelI eeg_chaninds(EEG,neighbours(neighbI).neighblabel)];
winSec = [-0.348 0.1];
winPnt = dsearchn(times',winSec');
responseM = squeeze(mean(mean(responseBL(:,channelIs,:),2),1));
makefigure(5.7,3.7);
plot(times,responseM,'Color',plotLineColours(3,:),'LineWidth',lineWidth); hold on;
xlim(respWindow);
areaAlpha = 0.25;
plot(winSec,[0 0],'Color',[0,0,0,areaAlpha],'LineWidth',3);
xlabel('Time (s)');
ylabel('Beta weight (\muV)');
text(-1,1.5,'  O1,Oz','FontSize',8);
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
print(fullfile(figuresFolder,'fig_04d.tiff'),'-dtiff','-r600');

% Response topo
makefigure(3.33,5);
rTopo = mean(mean(responseBL(:,:,winPnt(1):winPnt(2)),1),3);
% tp = topoplot(rTopo,chanlocs,'maplimits',[-0.1,0.1],'electrodes','off','headrad','rim','shading','interp','whitebk','on','style','fill');
tp = topoplot(rTopo,chanlocs,'electrodes','off','headrad','rim','shading','interp','whitebk','on','style','fill');
tp.Parent.XLim = [-0.6 0.6];
tp.Parent.YLim = [-0.6 0.6];
colormap(myColormap);
c = colorbar();
c.Label.String = 'Beta weight (\muV)';
c.Label.FontName = fontName;
c.Label.FontSize = fontSize;
c.Location = 'southoutside';
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
print(fullfile(figuresFolder,'fig_04f.tiff'),'-dtiff','-r600');

%% Exploratory Analysis: Note position as a regressor, but split by ID/NonID
close all; clear all; figset;

% Analysis windows
noteWindow = [-0.2 0.8];
noteBL = [-0.2 0];
respWindow = [-1 0.1];
respBL = [-1.2 -1];

load(fullfile(resultsFolder,'results_4_1.mat'));
times = EEG.unfold.times;

% Remove additional participants here
% % sub-30: noisy EEG
% Others: 5 or fewer responses in a condition
toRemove = {'sub-06','sub-07','sub-11','sub-18','sub-20','sub-21','sub-23','sub-24','sub-25','sub-27','sub-30'};
toRemoveI = find(contains(subjStrs,toRemove));
subjStrs(toRemoveI) = [];
allBeta(toRemoveI,:,:) = [];

% Assign ERPs
familiar = allBeta(:,:,1:breakpoints(1));
familiarPos = allBeta(:,:,(breakpoints(1)+1):breakpoints(2));
familiarID = allBeta(:,:,(breakpoints(2)+1):breakpoints(3));
familiarIDPos = allBeta(:,:,(breakpoints(3)+1):breakpoints(4));
response = allBeta(:,:,(breakpoints(4)+1):breakpoints(5));
responseID = allBeta(:,:,(breakpoints(5)+1):end);

% Baseline correction;
noteBLPts = dsearchn(times',noteBL');
respBLPts = dsearchn(times',respBL');
familiarBL = familiar - mean(familiar(:,:,noteBLPts(1):noteBLPts(2)),3);
familiarRTBL = familiarPos - mean(familiarPos(:,:,noteBLPts(1):noteBLPts(2)),3);
responseBL = response - mean(response(:,:,respBLPts(1):respBLPts(2)),3);
familiarIDBL = familiarID - mean(familiarID(:,:,noteBLPts(1):noteBLPts(2)),3);
familiarIDRTBL = familiarIDPos - mean(familiarIDPos(:,:,noteBLPts(1):noteBLPts(2)),3);
responseIDBL = responseID - mean(responseID(:,:,respBLPts(1):respBLPts(2)),3);

% Frontal plots
channelS = 'FC1';
channelI = find(strcmp({EEG.chanlocs.labels},channelS));
neighbI = find(strcmp(channelS,{neighbours.label}));
channelIs = [channelI eeg_chaninds(EEG,neighbours(neighbI).neighblabel)];
winSec = [0.308 0.600];
winPnt = dsearchn(times',winSec');

% Mean across participants
familiarM = squeeze(mean(mean(familiarBL(:,channelIs,:),2),1));
familiarIDM = squeeze(mean(mean(familiarIDBL(:,channelIs,:),2),1));
familiarRTM = squeeze(mean(mean(familiarRTBL(:,channelIs,:),2),1));
familiarIDRTM = squeeze(mean(mean(familiarIDRTBL(:,channelIs,:),2),1));

makefigure(7,4.5);
plot(times,familiarRTM,'Color',plotLineColours(2,:),'LineWidth',lineWidth); hold on;
plot(times,familiarIDRTM,'Color',plotLineColours(2,:),'LineStyle',':','LineWidth',lineWidth);
xlim(noteWindow);
ylim([-0.18 0.14]);
areaAlpha = 0.25;
plot(winSec,[0 0],'Color',[0,0,0,areaAlpha],'LineWidth',3);
xlabel('Time (s)');
ylabel('Beta weight (\muV/position)');
text(-0.2,0.14,'  FC1,F3,FCz,C3,Cz,Fz','FontSize',8);
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
legend('unidentified', 'identified','Box','off','Location','SouthEast');
print(fullfile(figuresFolder,'fig_06a.tiff'),'-dtiff','-r600');

% Stim-locked Stats
meanFamiliar = squeeze(mean(mean(familiarBL(:,channelIs,winPnt(1):winPnt(2)),2),3));
meanFamiliarID = squeeze(mean(mean(familiarIDBL(:,channelIs,winPnt(1):winPnt(2)),2),3));
[h,p,ci,stats] = ttest(meanFamiliarID - meanFamiliar)
d = mean(meanFamiliarID - meanFamiliar) / std(meanFamiliarID - meanFamiliar)

% Response-locked plots
channelS = 'O1';
channelI = find(strcmp({EEG.chanlocs.labels},channelS));
neighbI = find(strcmp(channelS,{neighbours.label}));
channelIs = [channelI eeg_chaninds(EEG,neighbours(neighbI).neighblabel)];
winSec = [-0.348 0.1];
winPnt = dsearchn(times',winSec');
responseM = squeeze(mean(mean(responseBL(:,channelIs,:),2),1));
responseIDM = squeeze(mean(mean(responseIDBL(:,channelIs,:),2),1));
makefigure(7,4.5);
plot(times,responseM,'Color',plotLineColours(3,:),'LineWidth',lineWidth); hold on;
plot(times,responseIDM,'Color',plotLineColours(3,:),'LineStyle',':','LineWidth',lineWidth);
xlim(respWindow);
areaAlpha = 0.25;
plot(winSec,[0 0],'Color',[0,0,0,areaAlpha],'LineWidth',3);
xlabel('Time (s)');
ylabel('Beta weight (\muV)');
text(-1,2,'  O1,Oz','FontSize',8);
set(gca,'FontSize',fontSize);
set(gca,'FontName',fontName);
set(gca,'Box','off');
legend('unidentified', 'identified','Box','off','Location','NorthWest');
print(fullfile(figuresFolder,'fig_06b.tiff'),'-dtiff','-r600');

% Response-locked Stats
meanResp = squeeze(mean(mean(responseBL(:,channelIs,winPnt(1):winPnt(2)),2),3));
meanRespID = squeeze(mean(mean(responseIDBL(:,channelIs,winPnt(1):winPnt(2)),2),3));
[h,p,ci,stats] = ttest(meanRespID - meanResp)
d = mean(meanRespID - meanResp) / std(meanRespID - meanResp)
