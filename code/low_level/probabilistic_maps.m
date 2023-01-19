clear; close all
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
%% Loop through objects
for c_obj = 1:length(all_stim)
    try

        % Clean
        im_pres = [];im_abs = [];
        % Load first object
        pres_file = all_stim{c_obj};
        im_pres = imread(sprintf('%s/%s', stim_folder, pres_file));
        im_pres = imresize(im_pres, [565,850]);

        % Load absent
        abs_file = strrep(pres_file, 'present', 'absent');
        im_abs = imread(sprintf('%s/%s', stim_folder, abs_file));
        im_abs = imresize(im_abs, [565,850]);

        % Compute difference
        diff = double(rgb2gray(im_pres))-double(rgb2gray(im_abs));
%         diff = double((im_pres))-double((im_abs));

        % Find the object
        [row, col] = find(diff~=0);
        [row, col] = find(diff(10:end-10,10:end-10~=0));
        obj_rect(:,:,c_obj) = [min(row), min(col), max(row), max(col)];

        % Compute area size
        obj_area(c_obj) = (max(row)-min(row)) * (max(col)-min(col));

        % Fill in the object rectangle
        map(min(row):max(row), min(col):max(col), c_obj)=1;

        % Get congruity
        if contains(pres_file, 'App')
            cong(c_obj) = 1;

        end
        if obj_area(c_obj)>350000
            keyboard
        end


    catch

        if isempty(im_pres)
            warning('File %s not found', pres_file)
            keyboard
        else
            warning('File %s not found', abs_file)
            keyboard
        end
        
    end
end

%% Write output
out.obj_rect = obj_rect;
out.file_names = all_stim;
out.cong = cong;
save('object_locations.mat', 'out')

%% Assess differences
con_ind = cong==1;
inc_ind = cong==0;

% Split area by conf
% area_by_cong = [obj_area(con_ind);obj_area(inc_ind)];

%% Get same object sizes
obj_names_by_cong = [all_stim(1:2:end), all_stim(2:2:end)];
obj_area_by_cong = [obj_area(1:2:end)', obj_area(2:2:end)'];
area_con = obj_area_by_cong(:,1);
area_inc = obj_area_by_cong(:,2);

%% Stats
addpath('/Users/javierortiz/Documents/MATLAB/BF_toolbox')
bf10 = bf.ttest(area_con,area_inc);

%% Plot
fig = figure(9999);
subplot(1,3,1), imagesc(mean(map(:,:,inc_ind),3)); title('Incongruent');clim([0,0.15]);axis('off')
subplot(1,3,2), imagesc(mean(map(:,:,con_ind),3)); title('Congruent');clim([0,0.15]);axis('off')
% subplot(1,5,3), imagesc(mean(map(:,:,con_ind),3)-mean(map(:,:,inc_ind),3)); title('Diff');%clim([-.15,0.15])
% subplot(1,4,3), imagesc(t_val); title('Ts')
% subplot(1,4,4), imagesc(p_val<.05); title('p value < .05')
addpath('/Users/javierortiz/Documents/MATLAB/notBoxPlot');
subplot(2,3,3), h = notBoxPlot(obj_area, con_ind, 'style', 'sdline', 'markMedian', true); title('Object area by congruency')
xticklabels({'Incongruent', 'Congruent'})
h(1).data.MarkerFaceColor = [1,1,1];h(2).data.MarkerFaceColor = [1,1,1];
h(1).data.MarkerEdgeColor = [0,.4,.7];h(2).data.MarkerEdgeColor = [0,.4,.7];
h(1).data.MarkerSize = 6;h(2).data.MarkerSize = 6;
disp_text = sprintf('BF01 = %.3f', 1/bf10);
text(0.5, max(obj_area)*.90, disp_text,"FontSize",15)


subplot(2,3,6),corr_and_fit(area_con, area_inc, 1, 'Pearson', 0, {'Area congruent version ';'Area incongruent version'});title('Correlation across conditions')


fig_folders = '/Users/javierortiz/github_repos/three_indices/figures';
saveas(fig, [fig_folders, '/object_area_analysis.jpg'])


