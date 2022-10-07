clear
%% Setup
% Get main dir and add functions
main_folder=setup;

% Which subjects are available
which_subs = [1:20];

% Read in data
data = readtable([main_folder, 'versions/elliot/data/raw/ElliotRecheck.xlsx'], ...
    'Sheet', 'Whole','Range','A1:AV2281','PreserveVariableNames',1);

%% Loop through  subjects
for cSub = which_subs
    
    % Get folder structure
    [sufs, sub_code]=cd_getdir([main_folder, 'versions/elliot/'],cSub);
    
    % get current subject's data
    curr_sub=data(data.Subject==cSub,:);
      
    % Put data onto nice table
    t=curr_sub;
    t.("OvsN") = curr_sub.Type;
    t.("Im1") = nan(height(t),1);
    t.("Changeness") = lower(t.("Changeness"));

    % Re-order vars
%     t = movevars(t,"Subject",'Before','CD.Resp');
%     t = movevars(t,"Sex",'After','Subject');
    t = movevars(t,"Objeto",'After','Participant');
    t = movevars(t,'Changeness','After','Objeto');
    t = movevars(t,'Congruency','After','Changeness');
    t = movevars(t,'Im1','After','Congruency');
    t = movevars(t,'ImPresent','After','Im1');
    t = movevars(t,'OvsN','After','ImPresent');
    t = movevars(t,'CD.ACC','After','OvsN');
    t = movevars(t,'CD.RT','After','CD.ACC');
    t = movevars(t,'Id.Resp','After','CD.RT');
    t = movevars(t,'Id.Coding','After','Id.Resp');
    t = movevars(t,'Locat.ACC','After','Id.Coding');
    t = movevars(t,'Id.ACC','After','Locat.ACC');
    t = movevars(t,'Recog.ACC','After','Id.ACC');
    t = movevars(t,'RK.RESP','After','Recog.ACC');
    var_names={'participant';'obj_file'; 'changeness';'congruity';
        'scn_name';'scn_name2';'OvsN';'cd_acc';'cd_rt';'id_resp';
        'id_coding'; 'loc_acc'; 'id_acc'; 'rec_acc';'rk_resp'};
    t.Properties.VariableNames([1:15]) = var_names;
    
    % Output to file
    writetable(t, [sufs.BIDS sub_code, '_task-elliot_merged.csv'])
    
end
