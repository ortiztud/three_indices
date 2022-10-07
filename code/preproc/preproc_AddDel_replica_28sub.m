clear
%% Setup
% Get main dir and add functions
main_folder=setup;
main_folder=[main_folder, 'versions/addDel-replica/'];

% Which subjects are available
which_subs = [1:28];

% Read in data
data = readtable([main_folder, 'data/raw/28subjects.xlsx'],'Sheet', 'NoPract','PreserveVariableNames',1);

%% Loop through  subjects
for cSub = which_subs
    enc=[];rec=[];
    % Get folder structure
    [sufs, sub_code]=cd_getdir(main_folder,cSub);
    
    % get current subject's data
    curr_sub=data(strcmpi(data.Subject,num2str(cSub)),:);
    
    % select relevant variables from encoding
    enc=table(curr_sub.Subject,...
        curr_sub.Object,...
        curr_sub.Congruencia,...
        curr_sub.("IM1[Trial]"),...
        curr_sub.("IM2[Trial]"),...
        curr_sub.Tipo,...
        curr_sub.Im_ACC,...
        curr_sub.Im_RT,...
        curr_sub.Informa,...
        curr_sub.Trial);
    var_names={'participant';'obj_file';'congruity';'scn_name';'scn_name2';
        'scn_type';'cd_acc';'cd_rt';'id_resp';'trial'};
    enc.Properties.VariableNames = var_names;
    
    % remove blank lines from memory test
    enc_ind=~strcmpi(enc.obj_file, '');
    enc=enc(enc_ind,:);
    
    % select relevant variables from recognition test
    rec=table(curr_sub.Subject,...
        curr_sub.Objetos,...
        curr_sub.Congruencia,...
        curr_sub.Base,...
        curr_sub.Tipo,...
        curr_sub.Rec_ACC,...
        curr_sub.Rec_RT,...
        curr_sub.Rec_Resp,...
        curr_sub.Conf_Resp,...
        curr_sub.Trial);
    var_names={'participant';'obj_file';'congruity';'scn_name';
        'scn_type';'rec_acc';'rec_rt';'rec_resp';'conf_resp';'trial'};
    rec.Properties.VariableNames = var_names;
    
    % remove blank lines from encoding
    rec_ind=~strcmpi(rec.obj_file, '');
    rec=rec(rec_ind,:);
    
    %% Merge enc and test
    
    % loop through test trials
    for cTrial=1:length(rec.participant)
        if ismember(rec.obj_file{cTrial}(1:end-4),lower(enc.obj_file))
            ind=find(strcmpi(rec.obj_file{cTrial}(1:end-4),lower(enc.obj_file)));
            cong_real{cTrial}=enc.congruity{ind};
            acc_real(cTrial)=str2num(enc.cd_acc{ind});
            rt_real(cTrial)=str2num(enc.cd_rt{ind});
            type_real{cTrial}=enc.scn_type{ind};
            OvsN{cTrial}='old';
        else
            cong_real{cTrial}='new';
            acc_real(cTrial)=0;
            rt_real(cTrial)=0;
            type_real{cTrial}='new';
            OvsN{cTrial}='new';
        end
    end
    % Re-code to standardize
    cong_real(strcmpi(cong_real,'Congruente'))={'con'};
    cong_real(strcmpi(cong_real,'Incongruente'))={'inc'};
    
    % Put data onto nice table
    t=rec;
    t= addvars(t,cong_real');
    t= addvars(t,acc_real');
    t= addvars(t,rt_real');
    t= addvars(t,type_real');
    t= addvars(t,OvsN');
    var_names={'participant';'obj_file';'congruity';'scn_name';
        'scn_type';'rec_acc';'rec_rt';'rec_resp';'conf_resp';'trial';'cong_real';
        'cd_acc';'cd_rt';'type_real';'OvsN'};
    t.Properties.VariableNames = var_names;
    
    % Output to file
    writetable(t, [sufs.BIDS sub_code, '_task-addDel-replica_merged.csv'])
    
end
