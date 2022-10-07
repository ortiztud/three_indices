clear

%% Main path
main_folder='C:\Users\Javier\PowerFolders\CD_restart\CD_irrelevant\';
addpath('C:\Users\Javier\PowerFolders\CD_restart\_functions')

% Which subjects are available
which_subs = [1,6,10,12,15,16,17,18,20:36];

%% Loop through  subjects
for cSub = which_subs
    
    % Get folder structure
    [sufs, sub_code]=cd_getdir(main_folder,cSub);
    
    % load results file for a given subject
    load([sufs.raw, 'cdIrrelevantOutput_'  num2str(cSub) '.mat']);
    cd(sufs.task)
    % Select stim based on CB
    if mod(cSub,2)==0
        [object,bckscene,cong] = textread('semCongruity1.txt','%s %s %s',40,'emptyvalue', NaN);
        semCongruityStim = [object bckscene cong];
        [object,bckscene,cong] = textread('spatialCongruity1.txt','%s %s %s',40,'emptyvalue', NaN);
        spatialCongruityStim = [object bckscene cong];
        [object,cong,bckscene] =  textread('cluttered1.txt','%s %s %s',40,'emptyvalue', NaN);
        clutteredStim = [object cong bckscene];
    elseif mod(cSub,2)==1
        [object,bckscene,cong] = textread('semCongruity2.txt','%s %s %s',40,'emptyvalue', NaN);
        semCongruityStim = [object bckscene cong];
        [object,bckscene,cong] = textread('spatialCongruity2.txt','%s %s %s',40,'emptyvalue', NaN);
        spatialCongruityStim = [object bckscene cong];
        [object,cong,bckscene] =  textread('cluttered2.txt','%s %s %s',40,'emptyvalue', NaN);
        clutteredStim = [object cong bckscene];
    elseif mod(cSub,4)==2
        [object,bckscene,cong] = textread('semCongruity3.txt','%s %s %s',40,'emptyvalue', NaN);
        semCongruityStim = [object bckscene cong];
        [object,bckscene,cong] = textread('spatialCongruity3.txt','%s %s %s',40,'emptyvalue', NaN);
        spatialCongruityStim = [object bckscene cong];
        [object,cong,bckscene] =  textread('cluttered3.txt','%s %s %s',40,'emptyvalue', NaN);
        clutteredStim = [object cong bckscene];
    elseif mod(cSub,4)==3
        [object,bckscene,cong] = textread('semCongruity4.txt','%s %s %s',40,'emptyvalue', NaN);
        semCongruityStim = [object bckscene cong];
        [object,bckscene,cong] = textread('spatialCongruity4.txt','%s %s %s',40,'emptyvalue', NaN);
        spatialCongruityStim = [object bckscene cong];
        [object,cong,bckscene] =  textread('cluttered4.txt','%s %s %s',40,'emptyvalue', NaN);
        clutteredStim = [object cong bckscene];
    end
    cd ..
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
    
    % Equate cong labels between stim sets for sub 19
    %     if cSub==19
    %         congrReal(strcmpi(congrReal,'App'))={'con'}; congrReal(strcmpi(congrReal,'Inap'))={'inc'};
    %     end
    
    % Check if new cong with old cong
    if mean(strcmpi(congrReal',p.targetCong'))~=1;mean(strcmpi(congrReal',p.targetCong'))
        keyboard
    end
    if mean(p.accuracyTest)==.500;keyboard;end
    %
    for i=1:length(p.targetTest)
        
        obj_name=p.targetTest{i,1}(1:end-4);
        
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
        
        % Merge with study
        obj_name=p.targetTest{i,1};
        if ismember(obj_name, p.storedTargets(:,1))
            ind=strcmpi(obj_name, p.storedTargets(:,1));
            cong_study{i}=p.targetCong{ind};
            scn_name{i}=p.backScene{ind};
            set_size(i)=p.setSize(ind);
            study_acc(i)=p.accuracy(ind);
            study_rt(i)=p.RTStudy(ind);
        else
            cong_study{i}='new';
            scn_name{i}='new';
            set_size(i)=NaN;
            study_acc(i)=NaN;
            study_rt(i)=NaN;
        end
        
    end
    cong_study(strcmpi(cong_study,'App'))={'con'}; cong_study(strcmpi(cong_study,'Inap'))={'inc'};
    
    % Check
    temp=p.targetTest(:,2);
    if mean(strcmpi(cong_test',temp))~=1;mean(strcmpi(cong_test',temp))
        ['issue with ', sub_code]
        keyboard
    end
    
    % Put data onto nice table
    t=cell2table(p.targetTest);
    t= addvars(t,scn_name', 'Before', 'Var4');t= addvars(t,study_acc');
    t= addvars(t,study_rt');t= addvars(t,zeros(120,1));
    t= addvars(t,p.responsesTest');t= addvars(t,p.accuracyTest');
    t= addvars(t,p.RTTest');
    var_names={'obj_file';'congruity';'position';'scn_name';'OvsN';
        'cd_acc';'cd_rt';'cd_id';'rec_resp';'rec_acc';
        'rec_rt';};
    t.Properties.VariableNames = var_names;
    
    % Add subject code
    participant=repmat(cSub,length(p.targetTest),1);
    t=addvars(t,participant, 'Before', 'obj_file');
    
    % Output to file
    writetable(t, [sufs.BIDS sub_code, '_task-cdIrrelevant_merged.csv'])
    
end
