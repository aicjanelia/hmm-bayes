function MakeTrackFigures(matPath,outPath)
    if (~exist(matPath,'file'))
        error('Cannot open file %s',matPath);
    end
    tracks = load(matPath);
    
    [~,fName] = fileparts(matPath);
    tok = regexpi(fName,'(.*)_k(\d+)','tokens');
    graphTitle = tok{1}{1};
    maxK = str2double(tok{1}{2});
    
    if (~exist(outPath,'dir'))
        mkdir(outPath);
    end
    
    sigs = [tracks.results.ML_params];
    sigs = horzcat(sigs.sigma_emit);
    Dcurr = (sigs.^2/2-tracks.locationError.^2)./mean(tracks.exposureTime);
    figure
    histogram(Dcurr,40);
    title('Distibution of diffusion constants');

    cfg.umperpx = 1;
    cfg.locerror = tracks.locationError;
    labels = {'D','DV','D_D','D_DV','DV_DV','D_D_D','D_D_DV','D_DV_DV','DV_DV_DV'};
    for i=1:length(tracks.results)
        if (isempty(tracks.results(i).track))
            continue
        end

        cfg.fs = 1/mean(tracks.exposureTime(i));
        [~,l] = max(tracks.results(i).PrM);

        f = figure;
        try
            hmm_results_plot(cfg,tracks.results(i));
            f.Units = 'normalized';
            f.Position = [0,0,1,1];
            name = sprintf('%s k%d Track%04d',graphTitle,maxK,tracks.results(i).trackID);
            suptitle(name);
            figData = getframe(f);
            name = sprintf('%s_k%d_Track%04d_States%s',graphTitle,maxK,tracks.results(i).trackID,labels{l});
            imwrite(figData.cdata,fullfile(outPath,[name,'.tif']));
        catch err
            warning('Problem plotting track:%d\n%s',tracks.results(i).trackID,err.message);
        end
        close(f);
    end
end
