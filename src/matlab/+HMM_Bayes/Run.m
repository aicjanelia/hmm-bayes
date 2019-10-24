function [trackData,results,locationError] = Run(trackData,maxK,minTrackLength,locationError)
    if (~exist('locationError','var') || isempty(locationError))
        locationError = 0.025; %estimated error of particle placement
    end
        
%     p = gcp();

    mcmc_params.parallel = 'off'; % turn off because the each track will be run in parallel 43
    if (maxK==2)
        mcmc_params.nTrials = 250;
    elseif (maxK==3)
        mcmc_params.nTrials = 750;
    end
    %maxK = 2; %Number of models to fit
    
    usedMask = false(length(trackData),1);

    prgs = Utils.CmdlnProgress(length(trackData),true,'Analyzing tracks');

    fprintf('Running HMM Bayes...');
    tic
    numResults = length(trackData);
    results = struct('PrM',[],'ML_states',[],'ML_params',[],'full_results',[],'logI',[],'track',[],'steps',[],'trackID',[]);
    results(numResults).PrM = [];
    exposureTime = zeros(1,numResults);
    
    parfor i=1:length(trackData)
        curTrack = trackData(i);
        if (size(curTrack.pos_xyz,1)<minTrackLength)
            continue
        end
        usedMask(i) = true;
        results(i).trackID = curTrack.trackID;
        
        results(i).track = curTrack.pos_xyz';
        results(i).steps = results(i).track(:,2:end)-results(i).track(:,1:end-1);
        timeStamps = curTrack.times;
        timeDeltas = timeStamps(2:end)-timeStamps(1:end-1);
        exposureTime(i) = max(timeDeltas);
        if (abs(exposureTime(i)-min(timeDeltas))>1e-4)
            warning('There was inconsistencies in exposure for track %d',curTrack.trackID);
            prgs.StopUsingBackspaces(); % the warning message has messed with printing progress
        end
        
        [results(i).PrM, results(i).ML_states, results(i).ML_params, results(i).full_results, full_fitting, results(i).logI] = HMM_Bayes.ProcessDataset(results(i).steps,maxK,mcmc_params);
        
        prgs.PrintProgress(i);
    end

    for i=1:length(usedMask)
        if (~usedMask(i))
            continue
        end
        
        curResults = results(i).full_results;
        [~,I] = max([curResults.PrM]);
        
        exposureT = mean(trackData(i).times(2:end)-trackData(i).times(1:end-1));
        
        dConsts = (curResults(I).ML_params.sigma_emit.^2./2 - locationError.^2) ./ exposureT;
        trackData(i).dConst = dConsts;
        states = curResults(I).ML_states;
        
        for j=1:size(trackData(i).steps_xyz,1)
            trackData(i).velocity(j) = norm(trackData(i).steps_xyz(j,:));
            state = states(j);
            trackData(i).state{j} = HMM_Bayes.GetLabelInd(I,state);
            trackData(i).dConst(j) = dConsts(state);
        end
    end
    fprintf('took %s\n',Utils.PrintTime(toc,length(trackData)));
end
