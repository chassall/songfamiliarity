% Open the preprocessed EEG files and label the note events

% Other m-files required: 
% EEGLAB toolbox https://github.com/sccn/eeglab

% Author: Cameron Hassall, Department of Psychology, MacEwan University
% email address: hassallc@macewan.ca
% Website: http://www.cameronhassall.com

% Folders
if ispc
    projectFolder = 'C:\Users\chass\OneDrive\Projects\2024_EEG_SongFamiliarity_Hassall\';
    sourceFolder = 'F:\2024_EEG_SongFamiliarity_Hassall\bids';
else
    projectFolder = '/Users/HassallC/Library/CloudStorage/OneDrive-Personal/Projects/2024_EEG_SongFamiliarity_Hassall';
    sourceFolder = '/Volumes/T7 (Data)/2024_EEG_SongFamiliarity_Hassall/bids';
end
audioFolder = fullfile(projectFolder,'data','derivatives','audio');
rlFolder = fullfile(projectFolder,'data','derivatives','eegrelabel');

% Subjects to include
subjStrs = {'sub-01','sub-02','sub-03','sub-04','sub-05','sub-06' ,'sub-07','sub-09','sub-10','sub-11','sub-12','sub-13','sub-14','sub-15','sub-16','sub-17','sub-18','sub-19','sub-20','sub-21','sub-22','sub-23','sub-24','sub-25','sub-26','sub-27','sub-28','sub-29','sub-30'};

for i = 1:length(subjStrs)
    
    % Load behavioural data
    thisFile = fullfile(sourceFolder,subjStrs{i},'beh',[subjStrs{i} '_task-songfamiliarity_beh.tsv']);
    if i == 1
        opts = detectImportOptions(thisFile, "FileType","text",'Delimiter', '\t');
    end
    allTrialData = readtable(thisFile, opts);    
    
    % Load preprocessed EEG
    thisPrepFile = fullfile(sourceFolder,subjStrs{i},'derivatives','eegprep',[subjStrs{i} '_task-songfamiliarity_eegprep.mat']);
    load(thisPrepFile,'EEG');
    
    % Load note types
    thisAudioFile = fullfile(sourceFolder,subjStrs{i},'derivatives','audio',[subjStrs{i} '_task-songfamiliarity_notetypes.mat']);
    load(thisAudioFile,'noteTypes','rtTypes');

    % Remove any note events that happened after or just before a button press ('2') until
    % the next start of song ('1'):
    eventsToRemove = zeros(1,length(EEG.event));
    j = 1;
    trialNum = 0;
    while j <= length(EEG.event)

        if strcmp(EEG.event(j).type,'2')
            % % Look backward; if there was a noteOnset within 8 ms (2 sample
            % % points), remove it
            % if j > 1 && strcmp(EEG.event(j-1).type,'noteOnset') && (EEG.event(j).latency - EEG.event(j-1).latency < 9)
            %     eventsToRemove(j-1) = 1;
            % end

            % Look forward for ones until we get to the next song ('1'), or
            % we run out of events

            doneLooking = 0;
            currentI = j;
            while ~doneLooking && currentI<length(EEG.event)
                currentI = currentI + 1;
                if strcmp(EEG.event(currentI).type,'noteOnset')
                    eventsToRemove(currentI) = 1;
                elseif strcmp(EEG.event(currentI).type,'1')
                    doneLooking = 1;
                end
            end
            j = currentI+1;
        else
            j = j + 1;
        end

    end

    EEG.event(eventsToRemove==1) = [];
    EEG = eeg_checkset(EEG,'eventconsistency');

    % Relabel note events as familiar or unfamiliar
    j = 1;
    k = 1;
    trialNumber = 0;
    toRemove = [];
    while j <= length(EEG.event)
       

        if strcmp(EEG.event(j).type,'1')
                
            trialNumber = trialNumber + 1;
            thisCond = noteTypes{trialNumber,1};
            
            thisRTCond = rtTypes{trialNumber};
            theseNoteTypes = noteTypes{trialNumber,2};
            
            thisCond = [thisRTCond thisCond];

            % Look ahead for a '2' or a '3' to determine condition
            whichTrials = [];
            currentTrial = j;
            newType = '';
            noteIndex = 0;
            while 1
                
                if strcmp(EEG.event(currentTrial+1).type,'2')
                    EEG.event(currentTrial+1).pos = length(theseNoteTypes); % The number of preceding notes
                    break;
                elseif strcmp(EEG.event(currentTrial+1).type,'3')
                    break;
                end

                currentTrial = currentTrial + 1;
                noteIndex= noteIndex + 1;

                if noteIndex <= length(theseNoteTypes)
                    % EEG.event(currentTrial).type = [thisCond num2str(theseNoteTypes(noteIndex))];
                    EEG.event(currentTrial).type = thisCond;
                    EEG.event(currentTrial).pos = -theseNoteTypes(noteIndex);
                else
                    toRemove = [toRemove currentTrial]; % "Extra" notes
                end
               
            end
            j = currentTrial;
        else
            j = j + 1;
        end
    end

    EEG.event(toRemove) = [];
    EEG = eeg_checkset(EEG,'eventconsistency');

    % Add response time to the EEG events in case we want to look at RT
    % regressor
    rts = allTrialData.rt;
    isResponse = strcmp(rtTypes,'e') | strcmp(rtTypes,'l'); 
    k = 0;
    j = 1;
    numEvents = length(EEG.event);
    while j <= numEvents
        if strcmp(EEG.event(j).type,'1')
            k = k + 1;
            thisRT = rts(k);
            
            % Go forward and add in the RT for this trial
            EEG.event(j).rt = thisRT;

            done = 0;
            while ~done && j <= numEvents
                
                j = j + 1;
                EEG.event(j).rt = thisRT;

                if strcmp(EEG.event(j).type,'7') || strcmp(EEG.event(j).type,'8')
                    done = 1;
                end
            end
        else
            j = j + 1;
        end
    end
    thisRLFile = fullfile(sourceFolder,subjStrs{i},'derivatives','eegprep',[subjStrs{i} '_task-songfamiliarity_eegpreprelabel.mat']);
    save(thisRLFile,'EEG');
end

