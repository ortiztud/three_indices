clear; close all
%% Setup
% Stim folder
bck_folder  ='/Users/javierortiz/PowerFolders/CD_restart/versions/CD_irrelevant/task_scripts/stim/spatialCongruity/backgrounds';
stim_folder = '/Users/javierortiz/PowerFolders/CD_restart/versions/CD_irrelevant/task_scripts/stim/spatialCongruity/scenes';

% Get all background names
temp = dir([bck_folder, '/*jpg']);
for i = 1:length(temp)
    all_back{i} = temp(i).name;
end

% Get all background names
temp = dir([stim_folder, '/*jpg']);
for i = 1:length(temp)
    all_stim{i} = temp(i).name;
end

% Initi empty map
map = zeros(510,764,length(all_stim));

% Congruity
cong = zeros(1,length(all_stim));
obj_area = nan(1,length(all_stim));

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
        ind = strfind(pres_file, '_');
        abs_file = pres_file(ind(end)+1:end);
        im_abs = imread(sprintf('%s/%s', bck_folder, abs_file));
        im_abs = imresize(im_abs, [565,850]);

        % Compute difference
        diff = double(rgb2gray(im_pres))-double(rgb2gray(im_abs));

        % Find the object
        [row, col] = find(diff(10:end-10,10:end-10~=0));
%         obj_rect = [min(row), min(col), max(row), max(col)];

        % Compute area size
        obj_area(c_obj) = (max(row)-min(row)) * (max(col)-min(col));

        % Fill in the object rectangle
        map(min(row):max(row), min(col):max(col), c_obj)=1;

        % Get congruity
        if contains(pres_file, 'con')
            cong(c_obj) = 1;
        end

        if obj_area(c_obj)>20000
            keyboard
        end

    catch

        if isempty(im_pres)
            warning('File %s not found', pres_file)
        else
            warning('File %s not found', abs_file)
        end
        % Output to file
        %     writetable(t, [sufs.BIDS sub_code, '_task-elliot_merged.csv'])
    end
end


%% Assess differences
con_ind = cong==1;
inc_ind = cong==0;

% for row_pix = 1:size(map,1)
%     for col_pix = 1:size(map,2)
%     [H,P,CI,STATS] = ttest2(map(row_pix,col_pix,con_ind),map(row_pix,col_pix,inc_ind), 'Tail','both');
%     p_val(row_pix, col_pix)  = P;
%     t_val(row_pix, col_pix)  = STATS.tstat;
%     end
% end

% Split area by conf
% area_by_cong = [obj_area(con_ind);obj_area(inc_ind)];
%% Get same object sizes
obj_names_by_cong = [all_stim(1:2:end), all_stim(2:2:end)];
obj_area_by_cong = [obj_area(1:2:end)', obj_area(2:2:end)'];
area_con = obj_area_by_cong(:,1);
area_inc = obj_area_by_cong(:,2);

%% Plot

subplot(1,3,1), imagesc(mean(map(:,:,con_ind),3)); title('Congruent');clim([0,0.15])
subplot(1,3,2), imagesc(mean(map(:,:,inc_ind),3)); title('Incongruent');clim([0,0.15])
% subplot(1,5,3), imagesc(mean(map(:,:,con_ind),3)-mean(map(:,:,inc_ind),3)); title('Diff');%clim([-.15,0.15])
% subplot(1,4,3), imagesc(t_val); title('Ts')
% subplot(1,4,4), imagesc(p_val<.05); title('p value < .05')
addpath('/Users/javierortiz/Documents/MATLAB/notBoxPlot');
subplot(2,3,3), h = notBoxPlot(obj_area, con_ind, 'style', 'sdline', 'markMedian', true); title('Area extension');
xticklabels({'Incongruent';'Congruent'})
xticklabels({'Congruent' ,'Incongruent'})
subplot(2,3,6),corr_and_fit(area_con, area_inc, 1, 'Pearson', 0, {'Congruent';'Incongruent'});title('Object area')

