function [params_ordered, errors_ordered] = OrderStates(params, errors)
%%%%%%%%%%%%%%%%%%%%
% Orders the states from an HMM-Bayes run based on their parameters.
% D states (no V) come first, ordered from largest to smallest D value
% (smaller D may indicate more complex behavior, e.g. confinement).
% DV states come next, ordered from smallest to largest V magnitude.
%
%%%%%%%%%%%%%%%%%%%%
% Copyright MIT 2015
% Laboratory for Computational Biology & Biophysics
%%%%%%%%%%%%%%%%%%%%


% D states (no V) come first, ordered from largest to smallest D value
% (smaller D may indicate more complex behavior, e.g. confinement)
D_states = find(sum(params.mu_emit,1)==0);
[~,D_idx] = sort(params.sigma_emit(D_states),'descend');
final_order = D_states(D_idx);

% DV states come next, ordered from smallest to largest V magnitude
DV_states = find(sum(params.mu_emit,1)~=0);
V_mag = sum(params.mu_emit(:,DV_states).*params.mu_emit(:,DV_states),1);
[~,DV_idx] = sort(V_mag);
final_order = [final_order DV_states(DV_idx)];

% Re-order the parameters
params_ordered = params;
params_ordered.p_start = params.p_start(final_order);
params_ordered.p_trans = params.p_trans(final_order,final_order);
params_ordered.mu_emit = params.mu_emit(:,final_order);
params_ordered.sigma_emit = params.sigma_emit(final_order);

% Re-order the parameter errors
errors_ordered = errors;
errors_ordered.p_start = errors.p_start(final_order);
errors_ordered.p_trans = errors.p_trans(final_order,final_order);
errors_ordered.mu_emit = errors.mu_emit(:,final_order);
errors_ordered.sigma_emit = errors.sigma_emit(final_order);


end
