clear

%% Setup
% Get main dir and add functions
main_folder=setup;
main_folder=[main_folder, 'versions/sparseVScluttered/'];

% Which subjects are available
% which_subs = [2:4,6,7,9,11,12,14:19];
which_subs = 1:20;

% load ID coding
id_coding = readtable([main_folder, 'imCompAnalysesFiltered[Conflicto].xlsx'],...
    'Sheet', 'Detection','Range','A1:P3601','PreserveVariableNames',1);

% add current version
trial_order='Random';%'Blocked' 'Random'
main_folder=[main_folder, trial_order, '/'];

% select corresponding coding info
if strcmpi(trial_order, 'Random')
    id_coding = id_coding(id_coding.Exp == 1,:);
else
    id_coding = id_coding(id_coding.Exp == 2,:);
end

% cycle through all subjects
for cSub = which_subs

    % Get folder structure
    [sufs, sub_code]=cd_getdir(main_folder,cSub);

    % load results file for a given subject
    if strcmpi(trial_order, 'Blocked')
        load([sufs.raw, 'CDstimComp',trial_order,'Output'  num2str(cSub) '.mat']);
    else
        load([sufs.raw, 'CDstimCompOutput' num2str(cSub) '.mat']);
    end

    % Select stim based on CB
    if mod(cSub,3)==0
        [object,bckscene,cong] = textread([sufs.task, 'semCongruity30a.txt'],'%s %s %s',40,'emptyvalue', NaN);
        semCongruityStim = [object bckscene cong];
        [object,bckscene,cong] = textread([sufs.task, 'spatialCongruity30a.txt'],'%s %s %s',40,'emptyvalue', NaN);
        spatialCongruityStim = [object bckscene cong];
        [object,cong,bckscene] =  textread([sufs.task, 'cluttered30a.txt'],'%s %s %s',40,'emptyvalue', NaN);
        clutteredStim = [object cong bckscene];
    elseif mod(cSub,3)==1
        [object,bckscene,cong] = textread([sufs.task, 'semCongruity30b.txt'],'%s %s %s',40,'emptyvalue', NaN);
        semCongruityStim = [object bckscene cong];
        [object,bckscene,cong] = textread([sufs.task, 'spatialCongruity30b.txt'],'%s %s %s',40,'emptyvalue', NaN);
        spatialCongruityStim = [object bckscene cong];
        [object,cong,bckscene] =  textread([sufs.task, 'cluttered30b.txt'],'%s %s %s',40,'emptyvalue', NaN);
        clutteredStim = [object cong bckscene];
    elseif mod(cSub,3)==2
        [object,bckscene,cong] = textread([sufs.task, 'semCongruity30c.txt'],'%s %s %s',40,'emptyvalue', NaN);
        semCongruityStim = [object bckscene cong];
        [object,bckscene,cong] = textread([sufs.task, 'spatialCongruity30c.txt'],'%s %s %s',40,'emptyvalue', NaN);
        spatialCongruityStim = [object bckscene cong];
        [object,cong,bckscene] =  textread([sufs.task, 'cluttered30c.txt'],'%s %s %s',40,'emptyvalue', NaN);
        clutteredStim = [object cong bckscene];
    end

    % Get congruity at test
    for i=1:length(p.target)
        if strcmpi(p.sceneType(i),'cluttered')==1
            for j=1:length(clutteredStim)
                if strcmpi(p.target(i),[strcat(clutteredStim(j,1), '.jpg')])==1
                    congrReal(i)=clutteredStim(j,2);
                    break
                end
            end
        elseif strcmpi(p.sceneType(i),'semCongruity')==1
            for j=1:length(semCongruityStim)
                if strcmpi(p.target(i),[strcat(semCongruityStim(j,1), '.jpg')])==1
                    congrReal(i)=semCongruityStim(j,3);
                    break
                end
            end
        elseif strcmpi(p.sceneType(i),'spatialCongruity')==1
            for j=1:length(spatialCongruityStim)
                if strcmpi(p.target(i),[strcat(spatialCongruityStim(j,1), '.jpg')])==1
                    congrReal(i)=spatialCongruityStim(j,3);
                    break
                end
            end
        end
    end

    % Equate cong labels between stim sets
    congrReal(strcmpi(congrReal,'App'))={'con'}; congrReal(strcmpi(congrReal,'Inap'))={'inc'};

    % Check if new cong with old cong
    if mean(strcmpi(congrReal',p.targetCong'))~=1;mean(strcmpi(congrReal',p.targetCong'));end
    if mean(p.accuracyTest)==.500;keyboard;end

    for i=1:length(p.testMatrix)

        obj_name=p.testMatrix{i,1}(1:end-4);

        if ismember(obj_name, clutteredStim(:,1))
            ind=strcmpi(obj_name, clutteredStim(:,1));
            cong_test{i}=clutteredStim{ind,2};
        elseif ismember(obj_name, semCongruityStim(:,1))
            ind=strcmpi(obj_name, semCongruityStim(:,1));
            cong_test{i}=semCongruityStim{ind,3};
        elseif ismember(obj_name, spatialCongruityStim(:,1))
            ind=strcmpi(obj_name, spatialCongruityStim(:,1));
            cong_test{i}=spatialCongruityStim{ind,3};
        else
            cong_test{i}='new';
        end

    end

    cong_test(strcmpi(cong_test,'App'))={'con'}; cong_test(strcmpi(cong_test,'Inap'))={'inc'};

    % Check
    temp=p.testMatrix(:,2);
    if mean(strcmpi(cong_test',temp))~=1;%mean(strcmpi(cong_test',temp))
        [num2str(cSub), ' issue ', num2str(mod(subNr,2))]
        keyboard
    end

    % Put data onto nice table
    t=cell2table(p.testMatrix);
    var_names={'obj_file';'congruity';'position';'scn_name';'scn_type';
        'changeness';'cd_acc';'cd_rt';'cd_id';'OvsN';'rec_resp';'rec_acc';
        'rec_rt';};
    t.Properties.VariableNames = var_names;

    % Add coding info. We need to remove annoying ''' in the objects first
    if strcmpi(trial_order, 'Random')
        curr_coding = id_coding(id_coding.Sub==100+cSub,:);
    elseif strcmpi(trial_order, 'Blocked')
        curr_coding = id_coding(id_coding.Sub==200+cSub,:);
    end
    if height(curr_coding)>1
        for c_trial = 1:height(curr_coding)
            if strcmpi(curr_coding.Object{c_trial}(1), "'")
                curr_coding.Object{c_trial} = curr_coding.Object{c_trial}(2:end-1);
            end

            % Find id info
            [~, ind] = ismember(curr_coding.Object{c_trial}, t.obj_file);

            % Fill it in
            t.loc_acc(ind) = curr_coding.("Locat.ACC")(c_trial);
            t.id_acc(ind) = curr_coding.("Id.ACC")(c_trial);
        end
    else
        t.loc_acc = NaN(height(t),1);
        t.id_acc = NaN(height(t),1);
    end
    t = movevars(t,'loc_acc','After','cd_id');
    t = movevars(t,'id_acc','After','loc_acc');

    % Add subject code
    participant=repmat(cSub,length(p.testMatrix),1);
    t=addvars(t,participant, 'Before', 'obj_file');

    % Create output
    writetable(t, [sufs.BIDS, sub_code, '_task-sparseVScluttered_merged.csv'])

end
