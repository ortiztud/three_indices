clear
%% Setup
% Get main dir and add functions
main_folder=setup;

% Which subjects are available
which_subs = [1:36];

% Read in data
data = readtable([main_folder, 'versions/no_id/data/raw/CDnoIdent-Whole_recheck2.xlsx'],'Sheet', 'Whole','Range','A1:X4321','PreserveVariableNames',1);

%% Loop through  subjects
for cSub = which_subs
    
    % Get folder structure
    [sufs, sub_code]=cd_getdir([main_folder, 'versions/no_id/'],cSub);
    
    % get current subject's data
    curr_sub=data(data.Subject==cSub,:);
      
    % Put data onto nice table
    t=curr_sub;
    t.("OvsN") = lower(curr_sub.OLDvsNEW);
    t.("Im1") = nan(height(t),1);

    % Re-order vars
    t = movevars(t,"Subject",'Before','CD.Resp');
    t = movevars(t,"Sex",'After','Subject');
    t = movevars(t,"Object(study)",'After','Sex');
    t = movevars(t,'Changeness','After','Object(study)');
    t = movevars(t,'Congruency','After','Changeness');
        
    t = movevars(t,'Im1','After','Congruency');
    t = movevars(t,'Stimuli','After','Im1');
    t = movevars(t,'OvsN','After','Stimuli');
    t = movevars(t,'Image1.ACC','After','OvsN');
    t = movevars(t,'Image1.RT','After','Image1.ACC');
    t = movevars(t,'Target.ACC','After','Image1.RT');
    t = movevars(t,'RecTarg.RT','After','Target.ACC');
    t = movevars(t,'Bind.ACC','After','Target.ACC');
    t = movevars(t,'Loc.ACC','After','Bind.ACC');
    var_names={'participant';'gender';'obj_file'; 'changeness';'congruity';
        'scn_name';'scn_name2';'OvsN';'cd_acc';'cd_rt';'rec_acc';
        'rec_rt';'assoc_acc';'location_acc'};
    t.Properties.VariableNames([1:14]) = var_names;
    
    % Output to file
    writetable(t, [sufs.BIDS sub_code, '_task-noid_merged.csv'])
    
end
