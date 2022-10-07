function [sufs, sub_code]=cd_getdir(main_folder, which_sub)
%% Get folder structure for this participant in feedBES

%% Folder names
sufs.BIDS = '/data/beh/';
sufs.raw = '/data/raw/';
% sufs.eyemov = '/data/et/';
sufs.outputs = '/outputs/';
sufs.figures = '/figures/';
sufs.task = '/task_scripts/';

%% Sub code
sub_code=sprintf('sub-%02d',which_sub);

%% Create subject folders names
sufs.BIDS=[main_folder,sufs.BIDS, sub_code,'/'];
sufs.raw=[main_folder,sufs.raw];
sufs.outputs=[main_folder,sufs.outputs, sub_code,'/'];
sufs.figures=[main_folder,sufs.figures, sub_code,'/'];
sufs.task=[main_folder,sufs.task];

%% Create folders if they don't already exist
if ~exist(sufs.BIDS);mkdir(sufs.BIDS);end
if ~exist(sufs.outputs);mkdir(sufs.outputs);end
if ~exist(sufs.figures);mkdir(sufs.figures);end
if ~exist(sufs.task);mkdir(sufs.task);end
end
