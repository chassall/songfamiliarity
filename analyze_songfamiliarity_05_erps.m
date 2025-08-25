% Compute the the regression ERPs

% Other m-files required: 
% EEGLAB toolbox: https://github.com/sccn/eeglab
% Unfold toolbox: https://github.com/unfoldtoolbox/unfold

% Author: Cameron Hassall, Department of Psychology, MacEwan University
% email address: hassallc@macewan.ca
% Website: http://www.cameronhassall.com


init_unfold();

% Folders
if ispc
    projectFolder = 'C:\Users\chass\OneDrive\Projects\2024_EEG_SongFamiliarity_Hassall\';
    dataFolder = 'F:\2024_EEG_SongFamiliarity_Hassall\bids';
else
    projectFolder = '/Users/HassallC/Library/CloudStorage/OneDrive-Personal/Projects/2024_EEG_SongFamiliarity_Hassall';
    dataFolder = '/Volumes/T7 (Data)/2024_EEG_SongFamiliarity_Hassall/bids';
end
resultsFolder = fullfile(projectFolder,'analysis','results');

% Set this flag to determine the analysis
% whichAnalysis flag
% 1: Note events for unfamiliar and familiar unrecognized. Response events.
% 2: Note position as a parametric regressor
% 3: Same as 2, but exclude songs that were recognized
% 4: Same as 2, but split by ID'd and NonID'd
% sufficient trial numbers)
whichAnalysis = 2; % Analysis flag

% Set this flag to determine whether we do cross validation (we do this
% once to determine hyperparameters, which we use for all analyses)
doCV = 0; % Cross-validation flag

% Set this flag to determine whether we do regularization (should be set to
% 1)
doReg = 1; % Regularization flag

% Excluded participants
% sub-08: No EEG recorded
% sub-18: No familiar songs

% Included participants
subjStrs = {'sub-01','sub-02','sub-03','sub-04','sub-05','sub-06' ,'sub-07','sub-09','sub-10','sub-11','sub-12','sub-13','sub-14','sub-15','sub-16','sub-17','sub-19','sub-20','sub-21','sub-22','sub-23','sub-24','sub-25','sub-26','sub-27','sub-28','sub-29','sub-30'};

% Remove additional participants if they are unable to be analyzed
if whichAnalysis == 3
    % sub-21: no "familiar unrecognized" notes
    % sub-23: no "familiar unrecognized" notes
    toRemove = {'sub-21','sub-23'};
    toRemoveI = find(contains(subjStrs,toRemove));
    subjStrs(toRemoveI) = [];
end

if whichAnalysis == 4
    % sub-20: no "recognized" notes
    % sub-21: no "familiar unrecognized" notes
    % sub-23: no "familiar unrecognized" notes
    toRemove = {'sub-20','sub-21','sub-23'};
    toRemoveI = find(contains(subjStrs,toRemove));
    subjStrs(toRemoveI) = [];
end

% Deal with cross-validation and regularization flags
if doCV
    regPar = [];
elseif doReg
    load(fullfile(resultsFolder,['regPar_1.mat']),'regPar');
else
    regPar = zeros(size(subjStrs));
end

% Result variables
allBeta = [];
allERP = [];
numEventTypes = [];
allBadChannels = {};
allArtifactProp = [];

for i = 1:length(subjStrs)

    % Load EEG
    thisPrepFolder = fullfile(dataFolder,subjStrs{i},'derivatives','eegprep');
    thisPrepFile = [subjStrs{i} '_task-songfamiliarity_eegpreprelabel.mat'];
    load(fullfile(thisPrepFolder, thisPrepFile),'EEG');

    if doCV
        EEG = pop_resample(EEG,100); % For speed
    end

    % sub-01 recording started a bit late, so remove these events
    if strcmp(subjStrs{i},'sub-01')
        EEG.event(1:6) = [];
    end

    % Relabel notes
    % 'f' = familiar but not recognized
    % 'r' = familiar and recognized
    % 'u' = unfamiliar
    % '2' = response
    for j = 1:length(EEG.event)
        if contains(EEG.event(j).type,'u')
            EEG.event(j).type = 'u';
        elseif contains(EEG.event(j).type,'f')
            EEG.event(j).type = 'f';
        elseif contains(EEG.event(j).type,'r') && whichAnalysis ~= 3 && whichAnalysis ~= 4
            EEG.event(j).type = 'f'; % Count these as familiar
        elseif contains(EEG.event(j).type,'r') && whichAnalysis == 4
            EEG.event(j).type = 'r'; % Keep these as a seprate condition ('recognized familiar');
        elseif strcmp(EEG.event(j).type,'2') && whichAnalysis == 4 % Split responses by condition
            if contains(EEG.event(j-1).type,'f')
                EEG.event(j).type = '2f'; 
            elseif contains(EEG.event(j-1).type,'r')
                EEG.event(j).type = '2r';
            end
        end
    end

   % Remove "type" from chanlocs so we don't confuse uf_continuousArtifactDetect()
   for j = 1:31
        EEG.chanlocs(j).type = [];
    end

    % Construct design matrix
    switch whichAnalysis
        case 1
            EEG = uf_designmat(EEG,'eventtypes',{'u','f','2'},'formula',{'y ~ 1','y ~ 1','y ~ 1'});
        case {2,3}
            EEG = uf_designmat(EEG,'eventtypes',{'f','2'},'formula',{'y ~ 1+pos','y ~ 1'});
        case {4}
            EEG = uf_designmat(EEG,'eventtypes',{'f','r','2f','2r'},'formula',{'y ~ 1+pos','y ~ 1+pos','y ~ 1','y ~ 1'});
    end

    % Define time window
    ufTime = [-1.5 1.5];

    % Make design matrix
    EEG = uf_timeexpandDesignmat(EEG,'timelimits',ufTime);

    % Flag zero rows
    nonZero = any(EEG.unfold.Xdc,2);
    isZero = ~nonZero;

    % Artifact detection
    [winrej, chanrej, rejProp] = uf_continuousArtifactDetect(EEG,'amplitudeThreshold',75,'windowsize',1000,'stepsize',100,'combineSegments',[]);
    isArtifact = zeros(size(isZero));
    isArtifactByChannel = zeros(size(isZero,1),EEG.nbchan);
    toRemove = [];
    for j = 1:size(winrej,1)
        toRemove = [toRemove winrej(j,1):winrej(j,2)];
        isArtifactByChannel(winrej(j,1):winrej(j,2),chanrej(j,:)==1) = 1;
    end
    isArtifact(toRemove) = 1;

    % Reject by channel
    artifactPropByChannel = mean(isArtifactByChannel(~isZero,:),1);

    isBad = artifactPropByChannel > 0.10;
    badChannels = {EEG.chanlocs(isBad).labels};
    allBadChannels{i} = badChannels;

    % Number of artifact as a proportion of samples of interest
    allArtifactProp(i) = mean(isArtifact & ~isZero);

    % Remove artifacts and non-zero rows
    EEG.unfold.Xdc(isArtifact | isZero,:) = [];
    EEG.data(:,isArtifact | isZero) = [];
    EEG.pnts = size(EEG.data,2);

    % Determine where the breaks between rERPs are (Unfold smooshes
    % everything together)
    numPoints = (ufTime(2)-ufTime(1))*EEG.srate;
    switch whichAnalysis
        case 1
            breakpoints = int32([numPoints 2*numPoints]);
        case {2,3}
            breakpoints = int32([numPoints 2*numPoints]);
        case {4}
            breakpoints = int32([numPoints 2*numPoints 3*numPoints 4*numPoints 5*numPoints]);
    end

    % Do cross-validation
    if doCV
        regtype = 'onediff';
        lambdas = [0 1E1 1E2 1E3 1E4 1E5 1E6 1E7 1E8];
        k = 10;
        [allErrors,bestBeta] = doRegCV(EEG.data,EEG.unfold.Xdc,regtype,{1:size(EEG.unfold.Xdc,2)},{breakpoints},lambdas,k);
        figure();
        plot(allErrors);
        drawnow();
        [~,j] = min(allErrors);
        disp(lambdas(j));
        regPar(i) = lambdas(j);
    end

    % Solve GLM
    regtype = 'onediff';
    lambda = regPar(i);
    thisPDM = pinv_reg(EEG.unfold.Xdc,lambda,regtype,breakpoints);
    tempBeta = thisPDM * EEG.data';
    allBeta(i,:,:) = tempBeta';

end

if doCV
    save(fullfile(resultsFolder,['regPar_' num2str(whichAnalysis) '.mat']),'regPar');
end

save(fullfile(resultsFolder,['results_' num2str(whichAnalysis) '_' num2str(doReg) '.mat']));
