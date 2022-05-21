function stats = GetTrackStats(track_results, cfg, condition)
    if ~exist('condition', 'var')
        condition = '';
    end

    state_enum = {
        {'Diffusive'};
        {'Directed'};
        {'Diffusive', 'Diffusive'};
        {'Diffusive', 'Directed'}; 
        {'Directed', 'Directed'}};

    [~, I] = max(track_results.PrM);
    state_names = state_enum{I};
    
    states = unique(track_results.ML_states);
    state_mean_frames = zeros(length(states),1);
    velocity_vectors = zeros(length(states), size(track_results.track,1));
    speeds = zeros(length(states), 1);
    multiplier = cfg.fs * cfg.umperpx;
    diffusion_coefficient = zeros(length(states), 1);
    
    for st = 1:length(states)
        state_mask = track_results.ML_states == states(st);
        rp = regionprops(state_mask, 'area');
        state_mean_frames(st) = mean([rp.Area]);
        diffusion_coefficient(st) = sqrt(-2 * cfg.locerror^2 + track_results.ML_params.sigma_emit(st)^2)^2 * cfg.fs / 2 * cfg.umperpx^2;
        
        for dimen = 1:size(track_results.track, 1)
            velocity_vectors(st,dimen) = multiplier * track_results.ML_params.mu_emit(dimen,st);
        end
        speeds(st) = norm(velocity_vectors(st,:));
    end

    state_mean_time = state_mean_frames ./ cfg.fs;
    
    conditions = repmat({condition}, length(states), 1);

    stats = table(velocity_vectors, speeds, diffusion_coefficient, state_mean_time, state_names', conditions);
    stats.Properties.VariableNames = {'Velocity', 'Speed', 'Diffusion', 'State Mean Time', 'State Name', 'Condition'};
end
