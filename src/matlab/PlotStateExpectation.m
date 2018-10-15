function PlotStateExpectation(root)
%root = 'D:\Images\SIM\Langford\_HMM-Bayes\';
    if (~exist('root','var') || isempty(root))
        root = uigetdir();
        if (root==0)
            return
        end
    end
    
    dList = dir(fullfile(root,'*.mat'));
    
    results = [];
    fNames = '';
    for i=1:length(dList)
        [~,fNames{i}] = fileparts(dList(i).name);
        r = Actin.HMMBayesResults(root,dList(i).name);
        results = [results,r'];
    end

    figure
    bar(results)
    legend(fNames)
    xticklabels({'D','DV','D-D','D-DV','DV-DV','D-D-D','D-D-DV','D-DV-DV','DV-DV-DV'});
end
