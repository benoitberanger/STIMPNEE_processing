clear
clc

load e

tic

par.file_reg = '^swutrf';
par.run=1;
par.display=0;

par.pct = 1;

model_name = 'boxcar';


%% Prepare first level

modelDir = e.mkdir('stat', model_name);
e.addModel('stat', model_name, model_name)

[ completeExams, incompleteExams ] = e.removeIncomplete

%%

if numel(incompleteExams) > 0
    
    modelDir = incompleteExams.mkdir('stat',model_name);
    dfonc = incompleteExams.getSerie('run_nm').toJob;
    stimFiles = incompleteExams.getSerie('run_nm').getStim('run_\d_SPM').toJob;
    
    par.file_reg = '^swutrf';
    
    
    
    %% fMRI design specification
    
    par.rp = 1; % realignment paramters : movement regressors
    
    par.run=1;
    par.display=0;
    
    par.pct = 1;
    
    j_fmri_desing = job_first_level_specify(dfonc,modelDir,stimFiles,par);
    
    
    %% Estime design
    
    fspm = incompleteExams.addModel('stat', model_name, model_name);
    
    par.run=1;
    par.display=0;
    j_estimate_model = job_first_level_estimate(fspm,par);
    
    
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
    j_contrast = job_first_level_contrast(fspm,contrast,par);
    
    
    %% save
    
    e.addModel('stat', model_name, model_name)
    
    for ex = 1 : numel(e)
        e(ex).is_incomplete = [];
    end
    
end

save e e

toc
