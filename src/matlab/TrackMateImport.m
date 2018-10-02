function TrackMateImport(csvPath,condition,maxK,minTrackLength)
    [num,txt] = xlsread(csvPath);
    graphTitle = condition;

    %minTrackLength = 15;
    locationError = 0.025; %estimated error of particle placement
    mcmc_params.parallel = 'off'; % turn off if parallel is not available
    if (maxK==2)
        mcmc_params.nTrials = 250;
    elseif (maxK==3)
        mcmc_params.nTrials = 750;
    end
    %maxK = 2; %Number of models to fit

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% end user changes
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Convert data into input to hmm_bayes
    trackIDcol = strcmpi(txt(1,:),'TRACK_ID');
    xCol = strcmpi(txt(1,:),'EDGE_X_LOCATION');
    yCol = strcmpi(txt(1,:),'EDGE_Y_LOCATION');
    zCol = strcmpi(txt(1,:),'EDGE_Z_LOCATION');
    timeCol = strcmpi(txt(1,:),'EDGE_TIME');

    trackVals = num(:,trackIDcol);
    xVals = num(:,xCol);
    yVals = num(:,yCol);
    zVals = num(:,zCol);
    timeVals = num(:,timeCol);

    trackIDs = unique(trackVals);
    %%

    p = gcp();
    maxWorkers = min(length(trackIDs),p.NumWorkers);
    if (p~=0 && maxWorkers~=p.NumWorkers)
        delete(p);
        parpool(maxWorkers);
    end

    prgs = Utils.CmdlnProgress(length(trackIDs),true,'Analyzing tracks');
    spmd
        numResults = ceil(length(trackIDs)/numlabs);
        results = struct('PrM',[],'ML_states',[],'ML_params',[],'full_results',[],'logI',[],'track',[],'steps',[],'trackID',[]);
        results(numResults).PrM = [];
        exposureTime = zeros(1,numResults);
        j = 1;

        for i=labindex:numlabs:length(trackIDs)
            mask = trackVals==trackIDs(i);
            if (sum(mask)<minTrackLength)
                continue
            end
            results(j).trackID = trackIDs(i);

            results(j).track = vertcat(xVals(mask)',yVals(mask)',zVals(mask)');
            results(j).steps = results(j).track(:,2:end)-results(j).track(:,1:end-1);
            timeStamps = timeVals(mask);
            timeDeltas = timeStamps(2:end)-timeStamps(1:end-1);
            exposureTime(j) = max(timeDeltas);
            if (abs(exposureTime(j)-min(timeDeltas))>1e-4)
                warning('There was inconsistencies in exposure for track %d',trackIDs(i));
                prgs.StopUsingBackspaces(); % the warning message has messed with printing progress
            end

            [results(j).PrM, results(j).ML_states, results(j).ML_params, results(j).full_results, full_fitting, results(j).logI] = hmm_process_dataset(results(j).steps,maxK,mcmc_params);

            j = j +1;
            prgs.PrintProgress(i);
        end
    end
    prgs.ClearProgress(true);

    resultsGather = struct('PrM',[],'ML_states',[],'ML_params',[],'full_results',[],'logI',[],'track',[],'steps',[],'trackID',[]);
    for i=1:size(results,2)
        if (isa(results,'Composite') || iscell(results))
            r = results{i};
        else
            r = results(i);
        end
        for j=1:size(r,2)
            resultsGather(end+1) = r(j);
        end
    end
    resultsGather = resultsGather(2:end);

    exposureTimeGather = [];
    for i=1:size(exposureTime,2)
        if (isa(exposureTime,'Composite') || iscell(exposureTime))
            e = exposureTime{i};
        else
            e = exposureTime(i);
        end
        exposureTimeGather = [exposureTimeGather,e];
    end

    resultsMask = arrayfun(@(x)(~isempty(x.PrM)),resultsGather);
    exposureTimeMask = exposureTimeGather~=0;
    mask = resultsMask & exposureTimeMask;

    results = resultsGather(mask);
    exposureTime = exposureTimeGather(mask);

    delete(p);

    %% Display results
    [d,f,e] = fileparts(csvPath);
    if (isempty(d))
        d = '.';
    end
%     sigs = [results.ML_params];
%     sigs = horzcat(sigs.sigma_emit);
%     Dcurr = (sigs.^2/2-locationError.^2)./mean(exposureTime);
%     figure
%     histogram(Dcurr,40);

    cfg.umperpx = 1;
    cfg.locerror = locationError;
    for i=1:length(results)
        if (isempty(results(i).track))
            continue
        end

        cfg.fs = 1/mean(exposureTime(i));

        f = figure;
        try
            hmm_results_plot(cfg,results(i));
            f.Units = 'normalized';
            f.Position = [0,0,1,1];
            name = sprintf('%s_k_%dTrack_%04d',graphTitle,maxK,results(i).trackID);
            suptitle(name);
            figData = getframe(f);
            imwrite(figData.cdata,fullfile(d,[name,'.tif']));
        catch err
            warning('Problem plotting track:%d\n%s',results(i).trackID,err.message);
        end
        close(f);
    end
    
    save(fullfile(d,sprintf('%s_k%d',graphTitle,maxK)),'results','exposureTime');
end
