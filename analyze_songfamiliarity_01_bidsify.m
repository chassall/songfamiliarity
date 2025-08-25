% Load source EEG data and convert to BIDS format
%
% Project: Song Familiarity
% Other m-files required: EEGLAB with bids-matlab-tools extensions
% bids-matlab toolbox (https://github.com/bids-standard/bids-matlab)
% Other files required: dmlab32.locs

% Author: Cameron Hassall, Department of Psychology, MacEwan University
% email address: hassallc@macewan.ca
% Website: http://www.cameronhassall.com
% August 2025

% Folders
% 1. rawFolder: raw EEG and behavioural, not in BIDS format
% 2. eeglabFolder: EEG in BIDS-friendly .set files
% 3. bidsFolder: the BIDS folder containing EEG, behavioural, and (eventually) derivatives (this will be uploaded to OpenNeuro)
% 4. stimFolder: the stimulus folder containing the songs 

% Participants to include
ps = {'01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30'}; % No EEG for 08

% Folder locations (change as needed)
rawFolder = 'F:\2024_EEG_SongFamiliarity_Hassall\raw';
eeglabFolder = 'F:\2024_EEG_SongFamiliarity_Hassall\eeglab';
bidsFolder = 'F:\2024_EEG_SongFamiliarity_Hassall\bids';
stimFolder = 'C:\Users\chass\OneDrive\Projects\2024_EEG_SongFamiliarity_Hassall\stimuli\all';

%% Make and save all necessary BIDS files using bids_export()

% Set data file names 
for p = 1:length(ps)
    data(p).file = {fullfile(eeglabFolder, ['sub-' ps{p}], 'eeg', ['sub-' ps{p} '_task-songfamiliarity_eeg.set'])};
end

% dataset_description.json
generalInfo.Name = 'Song Familiarity';
generalInfo.Authors = {'Jared R. Girard', 'Aaron M. Bishop', 'Cameron D. Hassall'};
generalInfo.License = 'CC0';
generalInfo.DatasetType = 'raw';
generalInfo.DatasetDOI = '';

% participants.tsv 
pInfo = {'participant_id', 'datetime', 'age', 'sex', 'handedness', 'cch';
    'sub-01', '03-Apr-2024 12:49:04', '24', 'M',  'L', 'N';
    'sub-02', '26-Apr-2024 10:02:41', '27', 'M',  'R', 'N';
    'sub-03', '02-May-2024 10:30:25', '44' , 'M',  'R', 'N';
    'sub-04', '13-May-2024 10:20:51', '23', 'F',  'R', 'N';
    'sub-05', '14-May-2024 10:31:23', '18', 'F',  'R', 'N';
    'sub-06', '15-May-2024 10:13:38', '18', 'F',  'R', 'N';
    'sub-07', '17-May-2024 11:21:13', '23', 'F',  'R', 'N';
    'sub-09', '17-May-2024 14:30:02', '18', 'F',  'L', 'N';
    'sub-10', '21-May-2024 11:08:17', '18', 'M',  'R', 'Y';
    'sub-11', '22-May-2024 11:07:27', '18', 'F',  'R', 'N';
    'sub-12', '22-May-2024 14:41:35', '24', 'M',  'R', 'N';
    'sub-13', '23-May-2024 11:27:37', '29', 'F',  'R', 'N';
    'sub-14', '24-May-2024 11:21:53', '18', 'F',  'R', 'Y';
    'sub-15', '27-May-2024 11:36:19', '18', 'F',  'R', 'N';
    'sub-16', '28-May-2024 11:20:32', '23', 'M',  'R', 'N';
    'sub-17', '29-May-2024 10:38:08', '19', 'F',  'R', 'N';
    'sub-18', '29-May-2024 13:18:30', '19', 'M',  'R', 'N';
    'sub-19', '30-May-2024 11:16:53', '24', 'F',  'R', 'N';
    'sub-20', '31-May-2024 10:49:15', '24', 'F',  'R', 'N';
    'sub-21', '03-Jun-2024 11:13:46', '24', 'M',  'R', 'N';
    'sub-22', '03-Jun-2024 14:10:24', '20', 'F',  'L', 'N';
    'sub-23', '04-Jun-2024 13:29:31', '21', 'F',  'LR', 'N';
    'sub-24', '05-Jun-2024 10:42:19', '28', 'F',  'R', 'N';
    'sub-25', '24-Jun-2022 10:33:12', '26', 'M',  'R', 'N';
    'sub-26', '06-Jun-2024 10:49:14', '29', 'F',  'R', 'Y';
    'sub-27', '10-Jun-2024 10:52:37', '18', 'F',  'R', 'N';
    'sub-28', '12-Jun-2024 11:26:40', '20', 'F',  'R', 'Y';
    'sub-29', '20-Jun-2024 10:08:13', '21', 'F',  'R', 'N';
    'sub-30', '21-Jun-2024 10:42:51', '24', 'M',  'R', 'N'};

% participants.json
pInfoDesc.participant_id.Description = 'participant number';
pInfoDesc.datetime.Description = 'date and time at start of task';
pInfoDesc.age.Description = 'self-reported age of participant';
pInfoDesc.sex.Description = 'self-reported sex of participant';
pInfoDesc.cch.Description = 'coarse and curly hair type';
pInfoDesc.sex.Levels.M = 'male';
pInfoDesc.sex.Levels.F = 'female';
pInfoDesc.handedness.Description = 'self-reported handedness of participant';
pInfoDesc.handedness.Levels.L = 'left-handed';
pInfoDesc.handedness.Levels.R = 'right-handed';
pInfoDesc.handedness.Levels.LR = 'ambidextrous';
pInfoDesc.cch.Levels.Y = 'yes';
pInfoDesc.cch.Levels.N = 'no';

% task-temporalscaling_events.json
eInfoDesc.type.Description = 'Event value';
eInfoDesc.type.Levels.x1 = 'Start of trial';
eInfoDesc.type.Levels.x2 = 'Response (spacebar)';
eInfoDesc.type.Levels.x3 = 'Onset of song identification prompt';
eInfoDesc.type.Levels.x4 = 'Song identification prompt response (enter key)';
eInfoDesc.type.Levels.x5 = 'Onset of multiple choice text';
eInfoDesc.type.Levels.x6 = 'Multiple choice response (1-4)';
eInfoDesc.type.Levels.x7 = 'Onset of multiple choice outome (correct)';
eInfoDesc.type.Levels.x8 = 'Onset of multiple choice outcome (incorrect)';
eInfoDesc.type.Levels.noteOnset = 'Onset of note';

eInfoDesc.latency.Description = 'Event onset';
eInfoDesc.latency.Units = 'samples';

eInfoDesc.duration.Description = 'Event duration';
eInfoDesc.duration.Units = 'samples';

eInfoDesc.stim_file.Description = 'Stimulus file';

% README
README = sprintf('# Song Familiarity\n\nTwenty-nine participants listened to song melodies and responded as soon as the song felt familiar. Participants were then asked to identify the song, if possible (title, artist, or lyrics). Next, participants were shown a multiple choice display with four song titles, selected a song title, and were given visual feedback (correct: selected option turned green and a checkmark appeared next to the title; incorrect: selected option turned red and an x appeared next to the title.)\n\nSong stimuli are taken from Kostic and Cleary (2009): https://supp.apa.org/psycarticles/supplemental/a0014584/a0014584_supp.html\n\nAn audio file with a reconstruction of what each participant heard throughout the experiment can be found in /derivatives. The audio file has been synchronized with the EEG recording.');

% We won't do a CHANGES file because this will be generated by OpenNeuro

% sub-XX_task-temporalscaling_eeg.json
tInfo.InstitutionAddress = '10700 104 Ave NW, Edmonton, AB';
tInfo.InstitutionName = 'MacEwan University';
tInfo.InstitutionalDepartmentName = 'Department of Psychology';
tInfo.PowerLineFrequency = 60;
tInfo.ManufacturersModelName = 'actiCHamp';

% Run bids_export
bids_export(data, 'targetdir', bidsFolder, 'taskName', 'songfamiliarity', 'gInfo', generalInfo, 'pInfo', pInfo, 'pInfoDesc', pInfoDesc, 'eInfoDesc', eInfoDesc, 'README', README,'tInfo', tInfo);

%% Load the behavioural files and save as TSVs
stimDir = dir(fullfile(stimFolder,'*.wav'));
stimNames = {stimDir.name};
for p = 1:length(ps)

    % Load behavioural data from rawFolder/beh
    pBIDSString = ['sub-' ps{p}];

    thisFolder = dir(fullfile(rawFolder,pBIDSString,'beh'));
    if ismember('edited',{thisFolder.name}) % These behavioural files were edited by hand to remove invalid entries
        thisDir = dir(fullfile(rawFolder,pBIDSString,'beh','edited','*.mat'));
        thisFile = fullfile(thisDir.folder, thisDir.name);
    else
        thisDir = dir(fullfile(rawFolder,pBIDSString,'beh','*.mat'));
        thisFile = fullfile(thisDir.folder, thisDir.name);
    end

    loadedData = load(thisFile,'allTrialData');
    thisData = loadedData.allTrialData;

    % Missed recording the first trial
    % Remove behavioural trial here
    if strcmp(pBIDSString, 'sub-01')
        thisData(1,:) = [];
        thisData.trialNum = [1:length(thisData.trialNum)]';
    end

    % Make a struct out of the behavioural data
    beh.trialNum = thisData.trialNum;
    beh.songNumber = thisData.songNumber;
    beh.songFileName = {stimNames{thisData.songNumber}};
    beh.songDur = thisData.songDur; 
    beh.fixTime = thisData.fixTime; 
    beh.responded = thisData.responded; 
    beh.rt = thisData.rt; 
    beh.postMusicTime = thisData.postMusicTime; 
    beh.reply = cellstr(thisData.reply); 
    beh.promptRT = thisData.promptRT; 
    beh.choicesMC = num2str(thisData.choicesMC); 
    beh.respMC = thisData.respMC; 
    beh.rtMC = thisData.rtMC; 
    beh.outcomeMC = thisData.outcomeMC; 
    beh.preFeedbackTime = thisData.preFeedbackTime;

    % Make /beh folder for this participant
    behFolder = fullfile(bidsFolder,pBIDSString,'beh');
    if ~exist(behFolder)
        mkdir(behFolder);
    end

    behFile = [pBIDSString '_task-songfamiliarity_beh.tsv'];
    bids.util.tsvwrite(fullfile(behFolder,behFile), beh);
end

%% write beh json for each participant
    
    bInfoDesc.block.Description = 'Trial number (integer)';

    bInfoDesc.songNumber.Description = 'Song number (integer)';

    bInfoDesc.songFileName.Description = 'Song file name (string)';

    bInfoDesc.songDur.Description = 'Song duration (float)';
    bInfoDesc.songDur.Units = 'seconds';

    bInfoDesc.fixTime.Description = 'Duration of fixation cross (float)'; 
    bInfoDesc.fixTime.Units = 'seconds';

    bInfoDesc.responded.Description = 'Whether or not there was a response (boolean)';
    bInfoDesc.Levels.x0 = 'No response';
    bInfoDesc.Levels.x1 = 'Response';

    bInfoDesc.rt.Description = 'Response time (float)';
    bInfoDesc.rt.Units = 'seconds';

    bInfoDesc.postMusicTime.Description = 'Delay after button press, but before prompt (float)'; 
    bInfoDesc.postMusicTime.Units = 'seconds';

    bInfoDesc.reply.Description = 'Participant response to song prompt (string)';

    bInfoDesc.promptRT.Description = 'Duration from start of prompt to return-button press (float)';
    bInfoDesc.promptRT.Units = 'seconds';

    bInfoDesc.choicesMC.Description = 'Multiple choice song numbers (string)';

    bInfoDesc.respMC.Description = 'Multiple choice response (integer)';
    bInfoDesc.respMC.Levels.x1 = 'First option';
    bInfoDesc.respMC.Levels.x2 = 'Second option';
    bInfoDesc.respMC.Levels.x3 = 'Third option';
    bInfoDesc.respMC.Levels.x4 = 'Fourth option';

    bInfoDesc.rtMC.Description = 'Multiple choice response time (float)';
    bInfoDesc.rtMC.Units = 'seconds';

    bInfoDesc.outcomeMC.Description = 'Multiple choice outcome (integer)';
    bInfoDesc.outcomeMC.Levels.x0 = 'Incorrect choice';
    bInfoDesc.outcomeMC.Levels.x1 = 'Correct choice';

    bInfoDesc.preFeedbackTime.Description = 'Duration from multiple choice response to feedback (float)';
    bInfoDesc.preFeedbackTime.Units = 'seconds';


for p = 1:length(ps)
pString = ['sub-' ps{p}];
behJSONFile = fullfile(bidsFolder, pString,'beh',[pString '_task-songfamiliarity_beh.json']);
options.indent = '  '; % Adds white space, easier to read
bids.util.jsonwrite(behJSONFile,bInfoDesc,options);
end

%% Manual steps after running this script
% - move stimuli into /bids/stimuli
% - move this script and task scipt into /bids/code
% - move reconstructed audio files into /bids/derivatives

% Delete *_channels.tsv
% Delete *_coordsystem.json
% Delete *_electrodes.tsv

chanDir = dir(fullfile(bidsFolder,'**','*_channels.tsv'));
for i = 1:length(chanDir)
    delete(fullfile(chanDir(i).folder,chanDir(i).name));
end

coordDir = dir(fullfile(bidsFolder,'**','*_coordsystem.json'));
for i = 1:length(coordDir)
    delete(fullfile(coordDir(i).folder,coordDir(i).name));
end

electrodesDir = dir(fullfile(bidsFolder,'**','*_electrodes.tsv'));
for i = 1:length(electrodesDir)
    delete(fullfile(electrodesDir(i).folder,electrodesDir(i).name));
end