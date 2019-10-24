function MakeTrackFigures(matPath,outPath)
    if (~exist(matPath,'file'))
        error('Cannot open file %s',matPath);
    end
    tracks = load(matPath);
    
    [~,fName] = fileparts(matPath);
    tok = regexpi(fName,'(.*)_hmm','tokens');
    graphTitle = tok{1}{1};
    
    if (~exist(outPath,'dir'))
        mkdir(outPath);
    end
    
    sigs = [tracks.results.ML_params];
    sigs = horzcat(sigs.sigma_emit);
    ts = arrayfun(@(x)(mean(x.times(2:end)-x.times(1:end-1))),tracks.trackData);
    exposureTime = mean(ts(~isnan(ts)));
    Dcurr = (sigs.^2/2-tracks.locationError.^2)./exposureTime;
    f = figure;
    histogram(Dcurr,40);
    title('Distibution of diffusion constants');
    
    f.Units = 'normalized';
    f.Position = [0,0,1,1];
    figData = getframe(f);
    name = sprintf('_%s_diff_const_dist',graphTitle);
    imwrite(figData.cdata,fullfile(outPath,[name,'.tif']));
    close(f);
    

    cfg.umperpx = 1;
    cfg.locerror = tracks.locationError;
    labels = {'D','DV','D_D','D_DV','DV_DV','D_D_D','D_D_DV','D_DV_DV','DV_DV_DV'};
    for i=1:length(tracks.results)
        if (isempty(tracks.results(i).track))
            continue
        end

        cfg.fs = 1/mean(exposureTime);
        [~,l] = max(tracks.results(i).PrM);

        f = figure;
        try
            HMM_Bayes.ResultsPlot(cfg,tracks.results(i));
            f.Units = 'normalized';
            f.Position = [0,0,1,1];
            name = sprintf('%s Track%04d',graphTitle,tracks.results(i).trackID);
            suptitle(name);
            figData = getframe(f);
            name = sprintf('%s_Track%04d_States%s',graphTitle,tracks.results(i).trackID,labels{l});
            imwrite(figData.cdata,fullfile(outPath,[name,'.tif']));
        catch err
            warning('Problem plotting track:%d\n%s',tracks.results(i).trackID,err.message);
        end
        close(f);
    end
end
