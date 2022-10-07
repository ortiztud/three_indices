clear
%% Main path
main_folder='/home/javier/PowerFolders/CD_restart/emotional_induction/';
addpath('C:\Users\Javier\PowerFolders\CD_restart\_functions')

% Which subjects are available
which_subs = [1:120];

% Read in data
data = readtable([main_folder, 'data/raw/TPwholeData.xlsx'],'PreserveVariableNames',1);

%% Loop through  subjects
for cSub = which_subs
    enc=[];rec=[];
    % Get folder structure
    [sufs, sub_code]=cd_getdir(main_folder,cSub);
    
    % get current subject's data
    curr_sub=data(data.Subject_1==cSub,:);
    
    % Put data onto nice table
    t=curr_sub;
    t= movevars(t,'Object', 'After', 'Subject');
    t= movevars(t,'Congruency', 'After', 'Object');
    t= movevars(t,'ImPresent', 'After', 'Congruency');
    t= movevars(t,'Change', 'After', 'ImPresent');
    t= movevars(t,'Induction', 'After', 'Change');
    t= movevars(t,'Music', 'After', 'Induction');
    t= movevars(t,'Music', 'After', 'Induction');
    t= movevars(t,("Image1bis.ACC"), 'After', 'Music');
    t= movevars(t,("Image1bis.RT"), 'After', ("Image1bis.ACC"));
    t= movevars(t,("Informa.RESP"), 'After', ("Image1bis.RT"));
    t= movevars(t,("Id.Coding"), 'After', ("Image1bis.RT"));
    t= movevars(t,("Locat.ACC"), 'After', ("Id.Coding"));
    t= movevars(t,("Id.ACC"), 'After', ("Locat.ACC"));
    t= movevars(t,("ObjectStim.ACC"), 'After', ("Id.ACC"));
    t= movevars(t,("ObjectStim.RT"), 'After', ("ObjectStim.ACC"));
    t= movevars(t,("RK.RESP"), 'After', ("ObjectStim.RT"));
    t= movevars(t,("OLDvsNEW"), 'After', ("RK.RESP"));
    var_names={'participant';'obj_file';'congruity';'scn_name';
        'changeness';'induction';'music';'cd_acc';'cd_rt';'id_resp';
        'id_coding';'locat_acc';'id_acc';'rec_acc';'rec_rt';'rec_resp';'conf_resp';
        'OvsN'};
    t=t(:,1:18);
    t.Properties.VariableNames = var_names;
    
    % Output to file
    writetable(t, [sufs.BIDS sub_code, '_task-emotional_ind_merged.csv'])
    
end
