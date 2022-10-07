clear
%% Setup
% Get main dir and add functions
main_folder=setup;

% Add Canlab toolbox for Eprime files
addpath(sprintf('%s/code/_functions/CanlabCore', main_folder));

%% Get subjects
% Which subjects are available
which_subs = [1:8, 10,13,15];

%% Loop through  subjects
for cSub = which_subs

    % Get folder structure
    [sufs, sub_code]=cd_getdir(main_folder,cSub);

    % Read in data encoding. WORK FROM HERE
    filename = 'CD (noident) - Training-1-1.edat2';
    [edat_struct, edat_cells] = parse_edat_txt(filename);

%     curr_sub=data(data.SubjectMem==cSub,:);
%     OvsN=repmat('old', length(curr_sub.Subject),1);ind=isnan(curr_sub.Subject);
%     OvsN(ind,:)=repmat('new',sum(ind),1);
% 
%     % Put data onto nice table
%     t=curr_sub;t.Properties.VariableNames('Subject')={'participant'};
%     t = movevars(t,'Objeto','After','participant');
%     t = movevars(t,'Congruencia','After','Objeto');
%     t = movevars(t,'Im1','After','Congruencia');
%     t = movevars(t,'Im2','After','Im1');
%     t= addvars(t,OvsN, 'After', 'Im2');
%     t = movevars(t,'Target.ACC','After','OvsN');
%     t = movevars(t,'Target.RT','After','Target.ACC');
%     t = movevars(t,'Local.ACC','After','Target.RT');
%     t = movevars(t,'Id.ACC','After','Local.ACC');
%     t = movevars(t,'Tipo','After','Im2');
%     t = movevars(t,'Recog.ACC','After','Id.ACC');
%     t = movevars(t,'Recog.RT','After','Recog.ACC');
%     var_names={'participant';'obj_file';'congruity';'scn_name';'scn_name2';
%         'scn_type';'OvsN';'cd_acc';'cd_rt';'loc_acc';'id_acc';'rec_acc';'rec_rt';};
%     t.Properties.VariableNames([1:13]) = var_names;
% 
%     % Output to file
%     writetable(t, [sufs.BIDS sub_code, '_task-addDel_merged.csv'])

end
