function labels = GetLabelInd(mixtureInd,typeInd)
    [labels,separator] = HMM_Bayes.GetLabelStrings();
    labels = labels{mixtureInd};
    
    if (exist('typeInd','var') && ~isempty(typeInd))
        labels = strsplit(labels,separator);
        labels = labels{typeInd};
    end
end
