clear
clc

load e

tic

par.file_reg = '^swutrf';
par.run=1;
par.display=0;

par.pct = 1;

model_name = 'electrophySpectralPower';


%% Prepare first level

modelDir = e.mkdir('stat',model_name);
e.addModel('stat', model_name ,model_name )

[ completeExams, incompleteExams ] = e.removeIncomplete


%%

if numel(incompleteExams) > 0
    
    modelDir = incompleteExams.mkdir('stat',model_name);
    dfonc = incompleteExams.getSerie('run_nm').toJob;
    stimFiles = incompleteExams.getSerie('run_nm').getStim('run');
    stimFiles_reg = stimFiles(:,1).toJob;
    regressorDir = get_parent_path( stimFiles_reg );
    
    regressorFiles = get_subdir_regex_files(regressorDir, 'R_SpectralPower_\d.mat$');
    
    stimFiles_1 = stimFiles(:,1).toJob;
    stimFiles_2 = stimFiles(:,2).toJob;
    
    %% fMRI design specification
    
    %     j_fmri_desing = job_first_level_specify(dfonc,modelDir,stimFiles,par);
    
    matlabbatch = cell(length(modelDir),1);
    for subj = 1 : length(modelDir)
        
        currentRun_1 = get_subdir_regex_files(dfonc{subj}{1},par.file_reg);
        
        nrVoumes = spm_vol(currentRun_1{1});
        allVolumes_1 = cell(length(nrVoumes),1);
        for vol=1:length(nrVoumes)
            allVolumes_1{vol,1} = sprintf('%s,%d',currentRun_1{1},vol);
        end
        
        currentRun_2 = get_subdir_regex_files(dfonc{subj}{2},par.file_reg);
        nrVoumes = spm_vol(currentRun_2{1});
        allVolumes_2 = cell(length(nrVoumes),1);
        for vol=1:length(nrVoumes)
            allVolumes_2{vol,1} = sprintf('%s,%d',currentRun_2{1},vol);
        end
        
        matlabbatch{subj}.spm.stats.fmri_spec.dir = modelDir(subj);
        matlabbatch{subj}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{subj}.spm.stats.fmri_spec.timing.RT = 1.52;
        matlabbatch{subj}.spm.stats.fmri_spec.timing.fmri_t = 16;
        matlabbatch{subj}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
        matlabbatch{subj}.spm.stats.fmri_spec.sess(1).scans = allVolumes_1;
        matlabbatch{subj}.spm.stats.fmri_spec.sess(1).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        matlabbatch{subj}.spm.stats.fmri_spec.sess(1).multi = stimFiles_1(subj);
        sess = 1;
        REG = load(deblank(regressorFiles{subj}(sess,:)));
        for r = 1 : length(REG.names)
            matlabbatch{subj}.spm.stats.fmri_spec.sess(sess).regress(r).name = REG.names{r};
            matlabbatch{subj}.spm.stats.fmri_spec.sess(sess).regress(r).val = REG.R(:,r);
        end
        matlabbatch{subj}.spm.stats.fmri_spec.sess(1).multi_reg = gfile( dfonc{subj}{1} , '^rp.*txt' , 1 );
        matlabbatch{subj}.spm.stats.fmri_spec.sess(1).hpf = 128;
        matlabbatch{subj}.spm.stats.fmri_spec.sess(2).scans = allVolumes_2;
        matlabbatch{subj}.spm.stats.fmri_spec.sess(2).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
        matlabbatch{subj}.spm.stats.fmri_spec.sess(2).multi = stimFiles_2(subj);
        sess = 2;
        REG = load(deblank(regressorFiles{subj}(sess,:)));
        for r = 1 : length(REG.names)
            matlabbatch{subj}.spm.stats.fmri_spec.sess(sess).regress(r).name = REG.names{r};
            matlabbatch{subj}.spm.stats.fmri_spec.sess(sess).regress(r).val = REG.R(:,r);
        end
        matlabbatch{subj}.spm.stats.fmri_spec.sess(2).multi_reg = gfile( dfonc{subj}{2} , '^rp.*txt' , 1 );
        matlabbatch{subj}.spm.stats.fmri_spec.sess(2).hpf = 128;
        matlabbatch{subj}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{subj}.spm.stats.fmri_spec.bases.none = true;
        matlabbatch{subj}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{subj}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{subj}.spm.stats.fmri_spec.mthresh = 0.8;
        matlabbatch{subj}.spm.stats.fmri_spec.mask = {''};
        matlabbatch{subj}.spm.stats.fmri_spec.cvi = 'AR(1)';
        
    end
    
    
    [ matlabbatch ] = job_ending_rountines( matlabbatch, [], par );
    
    
    %% Estime design
    
    fspm = incompleteExams.addModel('stat', model_name, model_name );
    
    par.run=1;
    par.display=0;
    j_estimate_model = job_first_level_estimate(fspm,par);
    
    
    %% Prepare contrasts
    
    contrast = struct;
    
    %     1 0 0 0 0 0 0 0 rp 1 0 0 0 0 0 0 0 rp;
    %     0 1 0 0 0 0 0 0 rp 0 1 0 0 0 0 0 0 rp;
    %     0 0 1 0 0 0 0 0 rp 0 0 1 0 0 0 0 0 rp;
    %     0 0 0 1 0 0 0 0 rp 0 0 0 1 0 0 0 0 rp;
    %     0 0 0 0 1 0 0 0 rp 0 0 0 0 1 0 0 0 rp;
    %     0 0 0 0 0 1 0 0 rp 0 0 0 0 0 1 0 0 rp;
    %     0 0 0 0 0 0 1 0 rp 0 0 0 0 0 0 1 0 rp;
    %     0 0 0 0 0 0 0 1 rp 0 0 0 0 0 0 0 1 rp;
    
    % Boxcar : condition stim
    NULL  = [1 0 0 0  0 0 0 0];
    Force = [0 1 0 0  0 0 0 0];
    Resp  = [0 0 1 0  0 0 0 0];
    Eye   = [0 0 0 1  0 0 0 0];
    
    % Spectral Power : electrophy
    Belt  = [0 0 0 0  1 0 0 0];
    Grip  = [0 0 0 0  0 1 0 0];
    BeltD = [0 0 0 0  0 0 1 0];
    GripD = [0 0 0 0  0 0 0 1];
    
    
    contrast.values = {
        
    % Boxcar
    NULL
    Force
    Resp
    Eye
    
    % Spectral Power
    Belt
    Grip
    BeltD
    GripD
    
    % Boxcar + Spectral Power
    NULL  + Belt
    Force + Belt
    Resp  + Belt % !
    Eye   + Belt
    
    Force + Grip % !
    
    };

contrast.names = {
    
'NULL'
'Force'
'Resp'
'Eye'
'Belt'
'Grip'
'BeltD'
'GripD'

'NULL  + Belt'
'Force + Belt'
'Resp  + Belt'
'Eye   + Belt'

'Force + Grip'

};

contrast.types = repmat({'T'},[1 length(contrast.values)]);


% F contrast

contrast.values = [contrast.values; {eye(8)}];
contrast.names	= [contrast.names ; 'effects of interest'];
contrast.types  = [contrast.types   'F'];

par.delete_previous=1;


%% Generate contrasts

par.sessrep = 'repl';
j_contrast = job_first_level_contrast(fspm,contrast,par);


%% save

e.addModel('stat', model_name, model_name )

for ex = 1 : numel(e)
    e(ex).is_incomplete = [];
end

end

save e e

toc
