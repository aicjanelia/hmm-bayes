function results = HMMBayesResults(fPath,fName)
    r = load(fullfile(fPath,fName));
    sm = sum(vertcat(r.results(:).PrM));
    results = sm./sum(sm);
end
