clear
%% Setup
% Get main dir and add functions
main_folder=setup;
main_folder=[main_folder, 'versions/addDel-replica/'];

% Which subjects are available
which_subs = [1:28];

% Read in data
data = readtable([main_folder, 'data/raw/repElias_sorted.xlsx'],'Sheet', 'data','PreserveVariableNames',1);

%% Loop through  subjects
for cSub = which_subs
    enc=[];rec=[];
    % Get folder structure
    [sufs, sub_code]=cd_getdir(main_folder,cSub);
    
    % get current subject's data
    curr_sub=data(data.Subject==cSub,:);
    
   % Put data onto nice table
    t=curr_sub;
%     t.("OvsN") = nan(height(t),1);
    ind = t.("Old/New") == 1;
    t.("OvsN")(ind) = repmat({'old'}, sum(ind),1);
    ind = t.("Old/New") == 0;
    t.("OvsN")(ind) = repmat({'new'}, sum(ind),1);
    t.("Im1") = nan(height(t),1);

    % Re-order vars
%     t = movevars(t,"Subject",'Before','CD.Resp');
    t = movevars(t,"object",'After','Subject');
%     t = movevars(t,'Changeness','After','Object(study)');
    t = movevars(t,'Congruencia','After','object');
    t = movevars(t,'Im1','After','Congruencia');
    t = movevars(t,'Image','After','Im1');
    t = movevars(t,'OvsN','After','Image');
    t = movevars(t,'ACC','After','OvsN');
    t = movevars(t,'RT','After','ACC');
    t = movevars(t,'Id.resp','After','RT');
    t = movevars(t,'Id.Coding','After','Id.resp');
    t = movevars(t,'Loc.Acc','After','Id.Coding');
    t = movevars(t,'Id.Acc','After','Loc.Acc');
    t = movevars(t,'RecResp','After','Id.Acc');
    

    % Re-code acc
    for c_trial = 1:height(t)
        if t.RecResp(c_trial) == 1 && t.("Old/New")(c_trial) == 1
            t.rec_acc(c_trial) = 1;
        elseif t.RecResp(c_trial) == 1 && t.("Old/New")(c_trial) == 0
            t.rec_acc(c_trial) = 0;
            elseif t.RecResp(c_trial) == 2 && t.("Old/New")(c_trial) == 1
            t.rec_acc(c_trial) = 0;
            elseif t.RecResp(c_trial) == 2 && t.("Old/New")(c_trial) == 0
            t.rec_acc(c_trial) = 1;
        else
            'cueck'
            keyboard
        end
    end

    % Continue moving
    t = movevars(t,"rec_acc",'After','RecResp');
    t = movevars(t,'Tipo','After','Image');
    var_names={'order';'participant';'obj_file'; 'congruity';
        'scn_name';'scn_name2';'scn_type';'OvsN';'cd_acc';'cd_rt';'id_resp';
        'id_coding'; 'loc_acc'; 'id_acc'; 'rec_resp';'rec_acc'};
    t.Properties.VariableNames([1:16]) = var_names;

    % Output to file
    writetable(t, [sufs.BIDS sub_code, '_task-addDel-replica_merged.csv'])
    
end
