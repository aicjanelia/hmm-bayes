%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% User settings
rootDir = '/nrs/aic/Wait/Moore';
conditionName = 'FinalComets';
numOfStates = 3;
minTrackLength = 10;
trackString = '﻿TRACK_ID';
posXstring = 'POSITION_X';
posYstring = 'POSITION_Y';
posZstring = 'POSITION_Z';
framestring = 'POSITION_T';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Run
trackData = HMM_Bayes.CSVimport(fullfile(rootDir,[conditionName,'.csv']),trackString,posXstring,posYstring,posZstring,framestring);

[trackData,results,locationError] = HMM_Bayes.Run(trackData,numOfStates,minTrackLength);

HMM_Bayes.SaveResults(rootDir,conditionName,trackData,results,locationError);

HMM_Bayes.MakeTrackFigures(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']),fullfile(rootDir,conditionName));
