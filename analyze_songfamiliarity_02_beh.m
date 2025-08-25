% Analyze behavioural data for the song familiarity task
% Also determine labels for each note (famuliar, unfamiliar, or
% recognized)

% Author: Cameron Hassall, Department of Psychology, MacEwan University
% email address: hassallc@macewan.ca
% Website: http://www.cameronhassall.com

close all; clear all; clc;

if ispc
    projectFolder = 'C:\Users\chass\OneDrive\Projects\2024_EEG_SongFamiliarity_Hassall';
    dataFolder = 'F:\2024_EEG_SongFamiliarity_Hassall/bids';
else
    projectFolder = '/Users/HassallC/Library/CloudStorage/OneDrive-Personal/Projects/2024_EEG_SongFamiliarity_Hassall';
    dataFolder = '/Volumes/T7 (Data)/2024_EEG_SongFamiliarity_Hassall/bids';
    dataFolder = '../data';
end

% Subjects to exclude
% sub-08: No EEG
% Subjects to include
subjs = {'sub-01','sub-02','sub-03','sub-04','sub-05','sub-06' ,'sub-07','sub-09','sub-10','sub-11','sub-12','sub-13','sub-14','sub-15','sub-16','sub-17','sub-18','sub-19','sub-20','sub-21','sub-22','sub-23','sub-24','sub-25','sub-26','sub-27','sub-28','sub-29','sub-30'};

% Variables
allNumFamiliar = [];
allRTs = [];
fRTs = [];
rRTs = [];
uNumNotes = [];
rNumNotes = [];
fNumNotes = [];
allAccuracy = [];
allNumNotes = [];
allFastRTs = [];
allSlowRTs = [];
numID = [];
numMC = [];

% Load note onset times
load('note_onsets.mat','allOnsets');

for i = 1:length(subjs)

    % Load behavioural data
    thisFile = fullfile(dataFolder,subjs{i},'beh',[subjs{i} '_task-songfamiliarity_beh.tsv']);
    if i == 1
        opts = detectImportOptions(thisFile, "FileType","text",'Delimiter', '\t');
    end
    allTrialData = readtable(thisFile, opts);    
    rts = allTrialData.rt;
    responded = allTrialData.responded;

    blankResponse = strcmp(allTrialData.reply,'n/a') | strcmp(allTrialData.reply,'') | strcmp(allTrialData.reply,' ');
    uCondition = ~responded; % Unfamiliar
    fCondition = responded & blankResponse; % Familiar
    rCondition = responded & ~blankResponse; % Familiar and recognized
    iCondition = ~responded & ~blankResponse; % Invalid (do not count)

    % Variables of interest
    numID(i,:) = [sum(~responded & ~blankResponse)/sum(~responded)  sum(responded & ~blankResponse)/sum(responded)];
    numMC(i,:) = [sum(allTrialData.outcomeMC(~responded))/sum(~responded) sum(allTrialData.outcomeMC(responded==1))/sum(responded)];
    allAccuracy(i,:) = [mean(allTrialData.outcomeMC(uCondition)) mean(allTrialData.outcomeMC(fCondition)) mean(allTrialData.outcomeMC(rCondition))];
    invalid = ~uCondition & ~fCondition & ~rCondition;
    disp(['num invalid: ' num2str(sum(invalid))]);
    allNumFamiliar(i,:) = [sum(uCondition) sum(fCondition)+sum(rCondition)];


    % For each condition (u,f,r), indicate the order of notes (1 = just prior to response, 2 = 2-back, etc.)
    noteTypes = {};
    % Keep a total of the number of notes for each participant
    tempU = 0;
    tempF = 0;
    tempR = 0;
    
    for j = 1:size(allTrialData,1)
        
        if uCondition(j)
            noteTypes{j,1} = 'u';
            rtTypes{j,1} = 'u';
        elseif fCondition(j)
            noteTypes{j,1} = 'f';
        elseif rCondition(j)
            noteTypes{j,1} = 'r';
        elseif iCondition(j)
            noteTypes{j,1} = 'i'; 
            rtTypes{j,1} = 'i';
        else
            error('unrecognized note condition');
        end

        thisSongNum = allTrialData.songNumber(j);
        theseOnsets = allOnsets{thisSongNum} .* (1/22050); % Convert to real time
        
        if responded(j)
            thisRT = rts(j);
            thisNumNotes = find (thisRT > theseOnsets,1,'last');
            % allNumNotes = [allNumNotes; thisNumNotes];
            noteTypes{j,2} = thisNumNotes:-1:1;
            if fCondition(j)
                fNumNotes = [fNumNotes thisNumNotes];
                tempF = tempF + thisNumNotes;
            elseif rCondition(j)
                rNumNotes = [rNumNotes thisNumNotes];
                tempR = tempR + thisNumNotes;
            end
        else
            noteTypes{j,2} = zeros(1,length(theseOnsets));
            uNumNotes = [uNumNotes length(theseOnsets)];
            tempU = tempU + length(theseOnsets);
        end

    end

    allNumNotes(i,:) = [tempU tempF+tempR];

    if length(noteTypes) ~= length(rtTypes)
        error('trial number mismatch');
    end

    thisAudioFolder = fullfile(dataFolder,subjs{i},'derivatives','audio');
    % Save note types
    if ~exist(thisAudioFolder)
        mkdir(thisAudioFolder);
    end
    save(fullfile(thisAudioFolder,[subjs{i} '_task-songfamiliarity_notetypes.mat']),'noteTypes','rtTypes');
end

save(fullfile(projectFolder,'analysis','results','beh_results.mat'));