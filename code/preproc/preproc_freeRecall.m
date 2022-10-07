clear
%% Setup
% Get main dir and add functions
main_folder=setup;



% targetCong: obj-scn congruity (1. Congruent;2. Incongruent)
% addDel: addition-deletion (1. addition; 2. deletion)
% trialType: catch trials (1. change; 2. no-change)

% Data folder
data_dir=[main_folder, 'versions/free_recall/'];

% Subjects
which_sub=[1:6,8:21];

% Load fr acc
fr_pares=readtable([data_dir, 'data/raw/codificacionRecLibre.xlsx'], 'Sheet', 'ParticipantesPARES');
fr_impares=readtable([data_dir, 'data/raw/codificacionRecLibre.xlsx'], 'Sheet', 'ParticipantesIMPARES');

% Load id acc
id_coding=readtable([data_dir, 'data/raw/TFGElias.xlsx'], 'Sheet', 'Change Detection');

%% Loop to access each subject
for cSub=which_sub
    
    %% Load CD data
    load([data_dir, 'data/raw/FFcd_' num2str(cSub) '.mat'])
    
    % Accuracy study sin OLD
    % Acc change vs no change
    cd.AccGlobal(cSub,:)=[mean(p.accuracyCd(p.trialType==1)),mean(p.accuracyCd(p.trialType==2))];
    
    % Accuracy by congruity
    cd.AccCong(cSub,:)=[mean(p.accuracyCd(p.trialType==1 & p.targetCong==1)), ...
        mean(p.accuracyCd(p.trialType==1 & p.targetCong==2))];
    cd.Acc(cSub,:)=[mean(p.accuracyCd(p.trialType==1 & p.addDel==1 & p.targetCong==1)), ...
        mean(p.accuracyCd(p.trialType==1 & p.addDel==1 & p.targetCong==2)),...
        mean(p.accuracyCd(p.trialType==1 & p.addDel==2 & p.targetCong==1)),...
        mean(p.accuracyCd(p.trialType==1 & p.addDel==2 & p.targetCong==2))];
    
    % RT study
    p.RTcd(p.accuracyCd==0)=6;
    cd.RTCong(cSub,:)=[mean(p.RTcd(p.trialType==1 & p.targetCong==1 & p.accuracyCd==1)), ...
        mean(p.RTcd(p.trialType==1 & p.targetCong==2 & p.accuracyCd==1))];
    cd.RT(cSub,:)=[
        nanmean(p.RTcd(p.trialType==1 & p.addDel==1 & p.targetCong==1 & p.accuracyCd==1)), ...
        nanmean(p.RTcd(p.trialType==1 & p.addDel==1 & p.targetCong==2 & p.accuracyCd==1)),...
        nanmean(p.RTcd(p.trialType==1 & p.addDel==2 & p.targetCong==1 & p.accuracyCd==1)),...
        nanmean(p.RTcd(p.trialType==1 & p.addDel==2 & p.targetCong==2 & p.accuracyCd==1))];
        
    
    % Output
    out_mat={
        p.scene',p.target',p.trialType',p.targetCong',...
        p.addDel',p.accuracyCd',p.RTcd',p.idResp'
        };
end



%% Load memory data
imp_c=1;par_c=1;
for cSub=which_sub
    
        % Get folder structure
    [sufs, sub_code]=cd_getdir(data_dir,cSub);
    
    % Id coding
    curr_id=id_coding(id_coding.Subject==cSub,:);
    
    %% Load subject
    load([data_dir, 'data/raw/FFrecog' num2str(cSub) '.mat'])
    
    c=1;d=1;f=1;h=1;
    % Match both phases to generate appropriate indexes
    for i=1:size(p.recogMatrix,1)
        found=0;
        for j=1:size(p.cdMatrix,1)
            if strcmpi(p.recogMatrix{i,1},p.target{j})
                if found == 0
                    p.targetOld{c} = p.target{j};
                    tempAcc(1) = p.accuracyCd(j);
                    tempRT(1) = p.RTcd(j);
                    tempLocat(1) = curr_id.Locat_ACC(j);
                    tempId(1) = curr_id.Id_ACC(j);
                    p.idRespOld{c} = p.idResp{j};
                    p.sceneOld2{c} = p.scene{j};
                    p.targetCongOld(c) = p.targetCong(j);
                    p.addDelOld(c) = p.addDel(j);
                    p.trialTypeOld(c) = p.trialType(j);
                    p.OvsN(c) = 1;
                    p.locat_accOLD(c)=curr_id.Locat_ACC(c);
                    p.id_accOLD(c)=curr_id.Id_ACC(c);
                    found=found+1;
                elseif found==1
                    tempAcc(2) = p.accuracyCd(j);
                    tempRT(2) = p.RTcd(j);
                    tempLocat(2) = curr_id.Locat_ACC(j);
                    tempId(2) = curr_id.Id_ACC(j);
                    p.accCdOld(c) = nanmean(tempAcc);
                    p.RTcdOld(c) = nanmean(tempRT);
                    p.locat_accOLD(c) = nanmean(tempLocat);
                    p.id_accOLD(c) = nanmean(tempId);
                    p.lureTarget(f)=p.target(h);
                    p.lureCong(f)=p.targetCong(h);
                    p.lureAcc(f)=p.accuracyCd(h);
                    p.lureTrialType(f)=p.trialType(h);
                    f=f+1;
                    c=c+1;
                    found=found+1;
                end
            end
        end
        if found==0
            for h=1:size(p.cdMatrix,1)
                if strcmpi(p.recogMatrix{i,1}(1:end-5),p.target{h}(1:end-5))
                    p.lureTarget(f)=p.target(h);
                    p.lureCong(f)=p.targetCong(h);
                    p.lureAcc(f)=p.accuracyCd(h);
                    p.lureTrialType(f)=p.trialType(h);
                    f=f+1;
                    break
                end
            end
            p.targetOld{c} = p.recogMatrix{i,1};
            p.accCdOld(c)=NaN;
            p.RTcdOld(c) = NaN;
            p.idRespOld{c} = NaN;
            p.sceneOld2{c} = NaN;
            p.targetCongOld(c) = NaN;
            p.addDelOld(c) = NaN;
            p.trialTypeOld(c) = NaN;
            p.OvsN(c) = 0;
            p.locat_accOLD(c) = NaN;
            p.id_accOLD(c) = NaN;
            c=c+1;
        end
    end
    
    
    % RT study
    p.RTcd(p.accuracyCd==0)=6;
    rRTCong(cSub,:)=[mean(p.RTcd(p.trialType==1 & p.targetCong==1 & p.accuracyCd==1)), ...
        mean(p.RTcd(p.trialType==1 & p.targetCong==2 & p.accuracyCd==1))];
    rRT(cSub,:)=[
        nanmean(p.RTcd(p.trialType==1 & p.addDel==1 & p.targetCong==1 & p.accuracyCd==1)), ...
        nanmean(p.RTcd(p.trialType==1 & p.addDel==1 & p.targetCong==2 & p.accuracyCd==1)),...
        nanmean(p.RTcd(p.trialType==1 & p.addDel==2 & p.targetCong==1 & p.accuracyCd==1)),...
        nanmean(p.RTcd(p.trialType==1 & p.addDel==2 & p.targetCong==2 & p.accuracyCd==1))];
    
    % Recogntion scores
    p.HITglobal=[
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==0)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==.5)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==1))];
    p.HITCong=[
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==0 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==0 &  p.targetCongOld==2));...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==.5 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==.5 &  p.targetCongOld==2));...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==1 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==1 &  p.targetCongOld==2))];
    p.HITaddDel=[
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==0 & p.addDelOld==1 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==0 & p.addDelOld==1 &  p.targetCongOld==2)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==0 & p.addDelOld==2 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==0 & p.addDelOld==2 &  p.targetCongOld==2));...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==.5 & p.addDelOld==1 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==.5 & p.addDelOld==1 &  p.targetCongOld==2)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==.5 & p.addDelOld==2 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==.5 & p.addDelOld==2 &  p.targetCongOld==2));...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==1 & p.addDelOld==1 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==1 & p.addDelOld==1 &  p.targetCongOld==2)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==1 & p.addDelOld==2 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==1 & p.accCdOld==1 & p.addDelOld==2 &  p.targetCongOld==2))];
    
    p.GUESSglobal=[
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.accCdOld==0)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.accCdOld==.5)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.accCdOld==1))];
    p.GUESSCong=[
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==1 & p.accCdOld==0 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==1 & p.accCdOld==0 &  p.targetCongOld==2));...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==1 & p.accCdOld==.5 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==1 & p.accCdOld==.5 &  p.targetCongOld==2));...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==1 & p.accCdOld==1 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==1 & p.accCdOld==1 &  p.targetCongOld==2))];
    
    p.INCnoCDglobal=[mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==0)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==.5)),...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==1))];
    p.INCnoCDCong=[mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==0 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==0 &  p.targetCongOld==2));...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==.5 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==.5 &  p.targetCongOld==2));...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==1 &  p.targetCongOld==1)), ...
        mean(p.accuracyTest(p.OvsN==1 & p.trialTypeOld==2 & p.addDelOld==2 & p.accCdOld==1 &  p.targetCongOld==2))];
    
    p.FAglobal=1-[mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==1 & p.lureAcc==0)),...
        mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==1 & p.lureAcc==.5)),...
        mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==1 & p.lureAcc==1))];
    p.FACong=1-[mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==2 & p.lureAcc==0 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==2 & p.lureAcc==0 &  p.lureCong==2));...
        mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==2 & p.lureAcc==.5 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==2 & p.lureAcc==.5 &  p.lureCong==2));...
        mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==2 & p.lureAcc==1 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.lureTrialType==2 & p.lureAcc==1 &  p.lureCong==2))];
    p.FACong=[mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==0 & p.addDelOld==1 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==0 & p.addDelOld==1 &  p.lureCong==2)),...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==0 & p.addDelOld==2 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==0 & p.addDelOld==2 &  p.lureCong==2));...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==.5 & p.addDelOld==1 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==.5 & p.addDelOld==1 &  p.lureCong==2)),...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==.5 & p.addDelOld==2 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==.5 & p.addDelOld==2 &  p.lureCong==2));...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==1 & p.addDelOld==1 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==1 & p.addDelOld==1 &  p.lureCong==2)),...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==1 & p.addDelOld==2 &  p.lureCong==1)), ...
        mean(p.accuracyTest(p.OvsN==0 & p.trialTypeOld==2 & p.accCdOld==1 & p.addDelOld==2 &  p.lureCong==2))];
    
    %% Get free recall coding
    
    if mod(cSub,2)==1
        names=fr_impares(:,1);
        fr_data=table2array(fr_impares(:,imp_c+2));imp_c=imp_c+1;
    else
        names=fr_pares(:,1);
        fr_data=table2array(fr_pares(:,par_c+2));par_c=par_c+1;
    end
    
    p.fr_cod=NaN(p.nTestTrials,1);
    for cTrial=1:p.nTestTrials
        ind=find(strcmpi(names.Escena{cTrial},p.sceneOld2));
        p.fr_cod(ind)=fr_data(cTrial);
        p.fr_name(ind)=names.Escena(cTrial);
    end

    % Code acc
    p.fr_acc(p.fr_cod == 1) = 0;
    p.fr_acc(p.fr_cod == 2) = 1;
    p.fr_acc(p.fr_cod == 3) = 1;
    p.fr_acc(isnan(p.fr_cod)) = 0;
    
    %% Code changeness
    ind = p.trialTypeOld == 1;
    changeness(ind) = repmat({'change'}, sum(ind), 1);
    ind = p.trialTypeOld == 2;
    changeness(ind) = repmat({'no_change'}, sum(ind), 1);
    ind = isnan(p.trialTypeOld);
    changeness(ind) = repmat({'new'}, sum(ind), 1);


    %% Save
    % Save merge data in BIDS
    t=table(repmat(p.subjectcode', p.nTestTrials,1), p.targetOld', changeness', p.targetCongOld', p.sceneOld2',...
        p.OvsN', p.accCdOld', p.RTcdOld', p.locat_accOLD', p.id_accOLD',p.fr_acc', p.accuracyTest', p.RTTest');
    var_names={'participant';'obj_file';'changeness';'congruity';'scn_name';'OvsN';
        'cd_acc';'cd_rt';'loc_acc';'id_acc';'fr_acc';'rec_acc';'rec_rt'};
    t.Properties.VariableNames([1:13]) = var_names;
    
    % Output to file
    writetable(t, [sufs.BIDS sub_code, '_task-freeRec_merged.csv'])
    
end

%% Output