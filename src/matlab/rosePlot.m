root = 'D:\Users\eric\Dropbox (HHMI)\Woellert';
conditionStr = 
locerror = 0.025;

dList2Min = dir(fullfile(root,'*2min*.mat'));
stepsAll2min = [];
PrMAll2min = [];
drAll2min = [];
stepSizesAll2min = [];
dAll2min = [];
for i=1:length(dList2Min)
    r = load(fullfile(root,dList2Min(i).name));
    steps = horzcat(r.results.steps);
    steps = steps';
    stepsAll2min = vertcat(stepsAll2min,steps);
    PrMAll2min = vertcat(PrMAll2min,r.results.PrM);
    
    for j = 1:length(r.results)
        [dr,vel] = GetTrackDirAndVel(r.results(j).track');
        drAll2min = [drAll2min;dr];
        stepSizesAll2min = [stepSizesAll2min;vel];
        sig = r.results(j).ML_params.sigma_emit;
        Dcurr = (sig.^2/2)./r.exposureTime(j);
        dAll2min = [dAll2min;Dcurr'];
    end
end
[stepsAll2m_theta,elv,r] = cart2sph(stepsAll2min(:,1),stepsAll2min(:,2),stepsAll2min(:,3));
PrMAll2min = mean(PrMAll2min,1);

figure
% subplot(1,2,1)
polarhistogram(drAll2min,60);
title(sprintf('var:%0.2f',rad2deg(var(wrapToPi(drAll2min)))));

% subplot(1,2,2)
% m = max(vertcat(dAll2min,dAll5min,dAll10min,dAll15min,dAll20min,dAll100_666,dAll200_666,dAll100_689,dAllCntl));
% edges = 0:0.001:m;
% histogram(dAll2min,edges);
% title('2min after Glu');
% xlabel('Diffusion constant (\mum)');
% ylabel('Number of tracks');