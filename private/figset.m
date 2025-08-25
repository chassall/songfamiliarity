% Common settings for stats and figures
%
% Other m-files required: 
% brewermap: https://github.com/DrosteEffect/BrewerMap
% subtightplot

% Author: Cameron Hassall, Department of Psychiatry, University of Oxford
% email address: cameron.hassall@psych.ox.ac.uk
% Website: http://www.cameronhassall.com

% Participants to include
% whichPs = [1:10 12:21]; % P11 noisy

% Set project folder

if ispc
    projectFolder = 'C:\Users\chass\OneDrive\Projects\2024_EEG_SongFamiliarity_Hassall';
    dataFolder = 'F:\2024_EEG_SongFamiliarity_Hassall/bids';
else
    projectFolder = '/Users/HassallC/Library/CloudStorage/OneDrive-Personal/Projects/2024_EEG_SongFamiliarity_Hassall';
    dataFolder = '/Volumes/T7 (Data)/2024_EEG_SongFamiliarity_Hassall/bids';
end
% dataFolder = fullfile(projectFolder,'data');
resultsFolder = fullfile(projectFolder,'analysis','results');
figuresFolder = fullfile(projectFolder,'figures'); 

% Plot settings
lineWidth = 1.5;
fontSize = 8;
fontName = 'Arial';
allColours = brewermap(5,'Set1');
plotLineColours = allColours([1 2 5 4 3],:);
myColormap = brewermap(256,'RdBu');
myColormap = flip(myColormap);

% Channel locations
chanlocs = readlocs(fullfile(projectFolder,'analysis','private','dmlab31.locs'));

% Load neighbour definition
load("neighbours.mat",'neighbours');