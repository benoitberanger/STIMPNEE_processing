clear
clc


return

%% Prepare first level

sta=r_mkdir(suj,'stat')
do_delete(sta,0)
sta=r_mkdir(suj,'stat')
st =r_mkdir(sta,'fMRI')

[~, subdir] = get_parent_path(suj,1)

stimpath = [ pwd filesep 'stim' ];
stimdir = get_subdir_regex(stimpath,subdir);

fons = get_subdir_regex_files(stimdir,'MRI_[12]_SPM.mat$',2);
char(fons)

par.TR = 1.520;
par.file_reg = '^swutrf';


%% fMRI design specification

par.rp = 1; % realignment paramters : movement regressors

par.run=1;
par.display=0;
j_fmri_desing = job_first_level_specify(dfonc,st,fons,par)


%% Estime design

fspm = get_subdir_regex_files(st,'SPM',1)

par.run=1;
par.display=0;
j_estimate_model = job_first_level_estimate(fspm,par)


%% Prepare contrasts

contrast.names = {
    'Positive Effect Null' % 1
    'Positive Effect Force'% 2
    'Positive Effect Resp' % 3
    'Positive Effect Eye'  % 4
    'Force - Null'         % 5
    'Resp  - Null'         % 6
    'Eye   - Null'         % 7
    'Force - Resp'         % 8
    'Resp  - Force'        % 9
    'Force - Eye'          % 10
    'Resp  - Eye'          % 11
    '2*Force - Null - Eye' % 12
    '2*Resp  - Null - Eye' % 13
    };

contrast.values = {
    [1 0 0 0]
    [0 1 0 0]
    [0 0 1 0]
    [0 0 0 1]
    [-1 1 0 0]
    [-1 0 1 0]
    [-1 0 0 1]
    [0 1 -1 0]
    [0 -1 1 0]
    [0 1 0 -1]
    [0 0 1 -1]
    [-1 2 0 -1]
    [-1 0 2 -1]
    };

contrast.types = repmat({'T'},[1 length(contrast.values)]);
par.delete_previous=1;


%% Generate contrasts

par.sessrep = 'repl';
j_contrast = job_first_level_contrast(fspm,contrast,par)

