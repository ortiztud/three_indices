%% Setup
function root_dir = setup
% Get paths in the current pc (to standardise across computers).
here = cd;
root_dir = here(1:strfind(here, "CD_restart") + length('CD_restart'));

% Add homebrew functions
addpath(sprintf('%s/code/_functions', root_dir));

end