%% Use Saliency Toolbox to compute pixel-level saliency
clear; close all
% Add SUN's toolbox
addpath('/Users/javierortiz/Documents/MATLAB/SaliencyToolbox')
params = defaultSaliencyParams;

%% Setup
% Get main dir and add functions
table_folder = '/Users/javierortiz/PowerFolders/CD_restart/';

% Read in data
data = readtable([table_folder, 'versions/elliot/data/raw/ElliotRecheck.xlsx'], ...
    'Sheet', 'Whole','Range','A1:AV2281','PreserveVariableNames',1);

% Get all names
all_stim = unique(data.ImPresent);

% Fix typo due to no-change trials
for c_obj = 1:length(all_stim)
    if contains(all_stim{c_obj}, 'absent')
        all_stim{c_obj} = strrep(all_stim{c_obj}, 'absent', 'present');
    end
end

% Stim folder
stim_folder  ='/Users/javierortiz/PowerFolders/CD_restart/versions/CD_irrelevant/task_scripts/stim/cluttered';

% Initi empty map
map = zeros(510,764,length(all_stim));

% Congruity
cong = zeros(1,length(all_stim));
obj_area = nan(1,length(all_stim));
c=1;

%%
% Equate size
resizeIm(stim_folder, [565,850], 0)

% Read one image to get the dimmensions right
im = imread([stim_folder,'/resized/',all_stim{1}]);
im_size = size(im);

% Pre-allocate
sal_data.im_pres=zeros(im_size(1:2));
sal_data.im_abs=zeros(im_size(1:2));

% Loop through names
for cIm=1:length(all_stim)

    % Echo
    sprintf('Computing saliency map for image %d out of %d', cIm, length(all_stim))

    % Get saliency map with the object
    pres_file = [stim_folder,'/resized/',all_stim{cIm}];
    img=initializeImage(pres_file);
    sal_out = makeSaliencyMap(img,params);
    big_map = imresize(sal_out.data,img.size(1:2));

    % Store it into a X by Y by Image matrix in its original size
    sal_data.im_pres(:,:,cIm)= big_map;

    % Get saliency map without the object
    abs_file = strrep(pres_file, 'present', 'absent');
    img=initializeImage(abs_file);
    sal_out = makeSaliencyMap(img,params);
    big_map = imresize(sal_out.data,img.size(1:2));

    % Store it into a X by Y by Image matrix in its original size
    sal_data.im_abs(:,:,cIm)= big_map;

end

%% Asses object saliency positions
load('object_locations.mat')

% Loop through names
for cIm=1:length(all_stim)

    % Echo
    sprintf('Assessing object saliency for image %d out of %d', cIm, length(all_stim))

    % Get current data
    obj_loc = out.obj_rect(:,:,cIm);
    pres_map = sal_data.im_pres(:,:,cIm);
    abs_map = sal_data.im_abs(:,:,cIm);

    % Get saliency measures with the object
    sal_data.obj_area(cIm) = mean(mean(pres_map(obj_loc(1):obj_loc(3),obj_loc(2):obj_loc(4))));
    sal_data.empty_area(cIm) = mean(mean(abs_map(obj_loc(1):obj_loc(3),obj_loc(2):obj_loc(4))));

    % Compute object saliency
    sal_data.obj(cIm) = sal_data.obj_area(cIm) - sal_data.empty_area(cIm);
end

% Separate by congruency
con_ind = out.cong==1;
inc_ind = out.cong==0;

%% Stats
addpath('/Users/javierortiz/Documents/MATLAB/BF_toolbox')
bf10 = bf.ttest(sal_data.obj(con_ind),sal_data.obj(inc_ind));

%% Plot
n = 221;fig=figure(9999);
subplot(2,3,1), imagesc(imread([stim_folder,'/resized/',all_stim{n}]));title('Congruent scene');axis('off')
subplot(2,3,2), imagesc(imread([stim_folder,'/resized/',all_stim{n+1}]));title('Incongruent scene');axis('off')
subplot(2,3,4), imagesc(sal_data.im_pres(:,:,n));title('Saliency map');axis('off')
subplot(2,3,5), imagesc(sal_data.im_pres(:,:,n+1));title('Saliency map');axis('off')

addpath('/Users/javierortiz/Documents/MATLAB/notBoxPlot');
subplot(2,3,[3,6]), h = notBoxPlot(sal_data.obj, con_ind, 'style', 'sdline', 'markMedian', true); 
title('Object saliency');
xticklabels({'Incongruent', 'Congruent'})
h(1).data.MarkerFaceColor = [1,1,1];h(2).data.MarkerFaceColor = [1,1,1];
h(1).data.MarkerEdgeColor = [0,.4,.7];h(2).data.MarkerEdgeColor = [0,.4,.7];
h(1).data.MarkerSize = 6;h(2).data.MarkerSize = 6;

disp_text = sprintf('BF01 = %.3f', 1/bf10);
text(0.5, max(sal_data.obj)*.90, disp_text,"FontSize",15)

fig_folders = '/Users/javierortiz/github_repos/three_indices/figures';
exportgraphics(fig, [fig_folders, '/saliency_analysis.jpg'],'Resolution',300);


%% Write output
% out.sal_mat = sal_data;
% out.file_names = all_stim;

% Save saliency matrix that contains all the images
% save('sal_saliency_maps.mat', 'out')