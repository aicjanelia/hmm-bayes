function [trackData,results,locationError] = LoadResults(rootDir,conditionName)
    res = load(fullfile(rootDir,[conditionName,'_hmm-bayes.mat']));
    trackData = res.trackData;
    results = res.results;
    locationError = res.locationError;
end
