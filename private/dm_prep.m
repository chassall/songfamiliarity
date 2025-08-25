function dm_prep(dataFolder,subName,taskName,icaTriggers,icaWindow,filters,reference,badChannels,appendString,exportAsBV)

%DM_PREP Preprocess DM lab data
%   dataFolder: high-level BIDS folder
%   subName: subject name, e.g. 'sub-01'
%   taskName: task name, e.g. 'cooltask'
%   icaTriggers: the triggers around which to train the ICA
%   icaWindow: window to train ICA
%   filters: low/high, e.g [0.1 30]
%   reference: e.g. {'TP9','TP10'};
%   badChannels: array of bad channels to remove, e.g.  {'T7','T8'};
%   appendString: = string to append to output file, e.g. 'test'

% Requires: EEGLAB, uf_continuousArtifactDetect

if nargin < 7
    filters = [0.1 30];
    reference = {'TP9','TP10'};
    badChannels = {};
    appendString = '';
    exportAsBV = 0;
end

%% Load data
rawFolder = fullfile(dataFolder,subName,'eeg');
headerFile = [subName '_task-' taskName '_eeg.set'];
EEG = pop_loadset(fullfile(rawFolder, headerFile));

%% Add reference
EEG.data = [EEG.data; zeros(1,size(EEG.data,2))];
EEG.nbchan = EEG.nbchan + 1;
%EEG.chanlocs(length(EEG.chanlocs)+1) =  EEG.chanlocs(end);
%EEG.chanlocs(end).labels = 'Fz';

%% Channel locations
eegLocs = readlocs('dmlab33.locs');
EEG.chanlocs = eegLocs;

%% Downsample to 250 Hz.
EEG = pop_resample(EEG, 250);

%% Apply a bandpass filter
EEG = pop_eegfiltnew(EEG, filters(1), filters(2));

%% 60 Hz Notch filter
EEG = pop_eegfiltnew(EEG, 58, 62,[],1);

%% Re-reference to the average of the left and right mastoids and remove them from the analysis.
EEG = pop_reref(EEG, reference,'keepref', 'off');

%% Set channel locations
eegLocs = readlocs('dmlab31.locs');
EEG.chanlocs = eegLocs;

%% Remove bad channels
fullLocs = EEG.chanlocs;
EEG = pop_select(EEG,'nochannel',badChannels);

%% Isolate some data on which to run the ICA
if ~isempty(icaTriggers)
    icaEEG = pop_epoch(EEG,icaTriggers,icaWindow);
else
    icaEEG = EEG;
end

%% 1 Hz high-pass filter for the ICA as per Makoto's pipeline 
icaEEG = pop_eegfiltnew(icaEEG,1);

%% Remove bad trials from icaEEG (max - min sample > 500 uV)
if ~isempty(icaTriggers)
    isArtifactsCT = abs((max(icaEEG.data,[],2) -  min(icaEEG.data,[],2))) > 500; % size: channels X 1 X epochs
    isArtifact = logical(squeeze(any(isArtifactsCT,1))); % size: epochs X 1
    icaEEG = pop_select(icaEEG,'notrial',isArtifact);
else
    [WinRej, chanrej] = uf_continuousArtifactDetect(icaEEG,'amplitudeThreshold',[-500 500],'windowsize',2000,'stepsize',100,'combineSegments',1);
    icaEEG = pop_select(icaEEG,'rmpoint',WinRej);
end

%% Run ICA and get the results.
icaEEG = pop_runica(icaEEG,'runica'); % Possible algorithms: 'binica','fastica','runica'.
icaact = icaEEG.icaact;
icachansind = icaEEG.icachansind;
icasphere = icaEEG.icasphere;
icasplinefile = icaEEG.icasplinefile;
icaweights = icaEEG.icaweights;
icawinv = icaEEG.icawinv;

%% Transfer the ICA results from icaEEG to EEG
EEG.icaact = icaact;
EEG.icachansind = icachansind;
EEG.icasphere = icasphere;
EEG.icasplinefile = icasplinefile;
EEG.icaweights = icaweights;
EEG.icawinv = icawinv;

%% Perform IC rejection using the ICLabel EEGLAB extension.
EEG = iclabel(EEG, 'default');

%% Ocular correction
eyeLabel = find(strcmp(EEG.etc.ic_classification.ICLabel.classes,'Eye'));
nonEye = EEG.etc.ic_classification.ICLabel.classifications;
nonEye(:,eyeLabel) = [];
nonEye = sum(nonEye,2);
eyeI = EEG.etc.ic_classification.ICLabel.classifications(:,eyeLabel)  > nonEye;
whichOnesEye = find(eyeI);

% muscleLabel = find(strcmp(EEG.etc.ic_classification.ICLabel.classes,'Muscle'));
% nonMuscle= EEG.etc.ic_classification.ICLabel.classifications;
% nonMuscle(:,muscleLabel) = [];
% nonMuscle = sum(nonMuscle,2);
% muscleI = EEG.etc.ic_classification.ICLabel.classifications(:,muscleLabel)  > nonMuscle;
% whichOnesMuscle = find(muscleI);

% Remove ocular components
EEG = pop_subcomp(EEG,whichOnesEye,0);
EEG.numOcular = sum(eyeI);
%EEG.numMuscular = sum(muscleI);
disp(['removing ' num2str(EEG.numOcular) ' ocular components']);
%disp(['removing ' num2str(EEG.numMuscular) ' muscular components']);

% Interpolate
EEG = pop_interp(EEG,fullLocs);

%% Save preprocessed EEG
prepFile = [subName '_task-' taskName '_eegprep' appendString '.mat'];
prepFolder =  fullfile(dataFolder,subName, 'derivatives','eegprep');
if ~isfolder(prepFolder)
    mkdir(prepFolder);
end
save(fullfile(prepFolder,prepFile),'EEG');
end

