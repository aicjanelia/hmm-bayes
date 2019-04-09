function trackData = CSVimport(csvPath,trackStr,xStr,yStr,zStr,timeStr,timeMultiplier,umXYmultiplier,umZmultiplier)

    if (~exist('timeMultiplier','var') || isempty(timeMultiplier))
        timeMultiplier = 1;
    end
    if (~exist('umXYmultiplier','var') || isempty(umXYmultiplier))
        umXYmultiplier = 1;
    end
    if (~exist('umZmultiplier','var') || isempty(umZmultiplier))
        umZmultiplier = 1;
    end
    
    raw = csvread(csvPath,1,0);
    fH = fopen(csvPath,'rt');
    l = fgetl(fH);
    fclose(fH);
    tok = regexpi(l,',','split');

    %% Convert data into input to HMM_Bayes.Bayes
    trackIDcol = strcmpi(tok,trackStr);
    if (~any(trackIDcol))
        error('Cannont find Track column');
    end
    xCol = strcmpi(tok,xStr);
    if (~any(xCol))
        error('Cannont find X column');
    end
    yCol = strcmpi(tok,yStr);
    if (~any(yCol))
        error('Cannont find Y column');
    end
    zCol = strcmpi(tok,zStr);
    if (~any(zCol))
        error('Cannont find Z column');
    end
    timeCol = strcmpi(tok,timeStr);
    if (~any(timeCol))
        error('Cannont find Time column');
    end
    
    trackVals = raw(:,trackIDcol);
    xVals = raw(:,xCol).*umXYmultiplier;
    yVals = raw(:,yCol).*umXYmultiplier;
    zVals = raw(:,zCol).*umZmultiplier;
    timeVals = raw(:,timeCol);

    trackIDs = unique(trackVals);
    
    %% Make a structure that holds each track data
    trackData = struct('trackID',[],'pos_xyz',[],'times',[],'frames',[],'steps_xyz',[]);
    trackData(trackIDs(end)).trackID = trackIDs(end);
    
    for i=1:length(trackData)
        trackData(i).trackID = trackIDs(i);
        mask = trackVals==trackIDs(i);
        
        trackData(i).pos_xyz = [xVals(mask),yVals(mask),zVals(mask)];
        trackData(i).steps_xyz = trackData(i).pos_xyz(2:end,:)-trackData(i).pos_xyz(1:end-1,:);
        trackData(i).frames = timeVals(mask);
        trackData(i).times = trackData(i).frames .* timeMultiplier;
    end
end
