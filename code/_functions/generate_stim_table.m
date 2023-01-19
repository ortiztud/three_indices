clear; close all
%% Cluttered set
% Get main dir and add functions
table_folder = '/Users/javierortiz/PowerFolders/CD_restart/';
out_folder = '/Users/javierortiz/github_repos/three_indices/materials';

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

% Init
t = table(all_stim, 'VariableNames',{'file_name'});
c = 1;

%% Loop through objects
for c_obj = 1:length(all_stim)
    try

        im_pres = [];im_abs = [];

        % File name
        file_name = all_stim{c_obj};
        separators = strfind(file_name, '_');

        % Get object name
        t.object{c} = file_name(1:separators(1)-1);

        % Get scene code
        t.scene{c} = file_name(separators(2)+1:separators(3)-1);

        % Get congruity
        if contains(file_name, 'App')
            t.congruity{c} = 'congruent';
        elseif contains(file_name, 'Inap')
            t.congruity{c} = 'incongruent';
        end

        % Get set label
        t.set{c} = 'cluttered';

        % Update counter
        c = c+1;
    catch

            warning('File %s not found', file_name)

    end
end

%% Sparse set
% Stim folder
bck_folder  ='/Users/javierortiz/PowerFolders/CD_restart/versions/CD_irrelevant/task_scripts/stim/semCongruity/backgrounds';
obj_folder = '/Users/javierortiz/PowerFolders/CD_restart/versions/CD_irrelevant/task_scripts/stim/semCongruity/scenes';

% Get all background names
temp = dir([bck_folder, '/*jpg']);
for i = 1:length(temp)
    all_back{i} = temp(i).name;
end

% Get all background names
temp = dir([obj_folder, '/*jpg']);
for i = 1:160%length(temp)
    all_obj{i} = temp(i).name;
end

%% Loop through objects
for c_obj = 1:length(all_obj)
    try

        % File name
        file_name = all_obj{c_obj};
        t.file_name{c} = file_name; 
        separators = strfind(file_name, '_');

        % Get object name
        t.object{c} = file_name(1:separators(1)-1);

        % Get scene code
        t.scene{c} = file_name(separators(3)+1:end-4);

        % Get congruity
        if contains(file_name, 'con')
            t.congruity{c} = 'congruent';
        elseif contains(file_name, 'inc')
            t.congruity{c} = 'incongruent';
        end

        % Get set label
        t.set{c} = 'sparse';

        % Update counter
        c = c+1;

    catch
            warning('File %s not found', file_name)
       
    end
end

%% Output
writetable(t, [out_folder, '/stim_table.csv'])


