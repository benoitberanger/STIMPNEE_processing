clear
clc

load e

tic

par.file_reg = '^swutrf';
par.run=1;
par.display=0;

par.pct = 1;

model_name_base = 'electrophySpectralPower_phy';
models_base = e.getModel(model_name_base).getPath;

%% get ROIs

dirROI  = '/mnt/data/benoit/protocol/STIMPNEE/fmri/roi';
fileROI = cellstr(char(gfile(dirROI,'nii$'))); fileROI = remove_regex(fileROI,'T1');
char(fileROI)


%% Fetch fMRI volumes & stim files & regressors

dfonc = e.getSerie('run_nm').toJob;
stimFiles = e.getSerie('run_nm').getStim('run');
stimFiles_reg = stimFiles(:,1).toJob;
regressorDir = get_parent_path( stimFiles_reg );

regressorFiles = get_subdir_regex_files(regressorDir, 'R_SpectralPower_\d.mat$');

stimFiles_1 = stimFiles(:,1).toJob;
stimFiles_2 = stimFiles(:,2).toJob;


%% Now prepare the job

matlabbatch = cell(0);
iJob = 0;

for subj = 1 : length(e)
    
    currentRun_1 = get_subdir_regex_files(dfonc{subj}{1},par.file_reg);
    currentRun_2 = get_subdir_regex_files(dfonc{subj}{2},par.file_reg);
    
    allVolumes_1 = spm_select('expand',currentRun_1);
    allVolumes_2 = spm_select('expand',currentRun_2);
    
    for i = 1 : numel(fileROI)
        
        [~,nameROI] = spm_fileparts(fileROI{i});
        
        regressor_name = {'Belt', 'Grip'};
        
        for reg = 1 : length(regressor_name)
            
            
            model_name = sprintf('PPI_%s_%s',regressor_name{reg},nameROI);
            
            modelDir = e(subj).mkdir('stat',model_name_base,model_name);
            betafile = fullfile(char(modelDir),'SPM.mat');
            if exist(betafile,'file')
                continue
            end
            
            
            % JOB
            %==============================================================
            
            
            iJob = iJob + 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.dir = modelDir;
            matlabbatch{iJob}.spm.stats.fmri_spec.timing.units = 'secs';
            matlabbatch{iJob}.spm.stats.fmri_spec.timing.RT = 1.52;
            matlabbatch{iJob}.spm.stats.fmri_spec.timing.fmri_t = 16;
            matlabbatch{iJob}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
            
            
            % Run 1
            %------------------------------------------------------
            sess = 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).scans = allVolumes_1;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).multi = stimFiles_1(subj);
            
            PPIpath = fullfile( get_parent_path(char(modelDir)) , sprintf('modelPPI_%s_%s_run%d.mat',regressor_name{reg},nameROI,sess));
            PPI = load(PPIpath); PPI = PPI.PPI;
            c = 0;
            c = c + 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).name = sprintf('Y - %s',PPI.nameROI);
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).val  = PPI.Y                        ;
            c = c + 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).name = sprintf('P - %s',PPI.reg_name);
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).val  = PPI.P                        ;
            c = c + 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).name = sprintf('ppi - %s x %s',PPI.nameROI,PPI.reg_name);
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).val  = PPI.ppi                                          ;
            
            REG = load(deblank(regressorFiles{subj}(sess,:)));
            for r = 1 : length(REG.names)
                if strcmp(REG.names{r},PPI.reg_name)
                    continue
                end
                c = c + 1;
                matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).name = REG.names{r};
                matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).val  = REG.R(:,r)  ;
            end
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).multi_reg = gfile( dfonc{subj}{sess} , '^multiple_regressors' , 1 );
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).hpf = 128;
            
            
            % Run 2
            %------------------------------------------------------
            sess = 2;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).scans = allVolumes_2;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).multi = stimFiles_2(subj);
            
            PPIpath = fullfile( get_parent_path(char(modelDir)) , sprintf('modelPPI_%s_%s_run%d.mat',regressor_name{reg},nameROI,sess));
            PPI = load(PPIpath); PPI = PPI.PPI;
            c = 0;
            c = c + 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).name = sprintf('Y - %s',PPI.nameROI);
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).val  = PPI.Y                        ;
            c = c + 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).name = sprintf('P - %s',PPI.reg_name);
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).val  = PPI.P                        ;
            c = c + 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).name = sprintf('ppi - %s x %s',PPI.nameROI,PPI.reg_name);
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).val  = PPI.ppi                                          ;
            
            REG = load(deblank(regressorFiles{subj}(sess,:)));
            for r = 1 : length(REG.names)
                if strcmp(REG.names{r},PPI.reg_name)
                    continue
                end
                c = c + 1;
                matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).name = REG.names{r};
                matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).regress(c).val  = REG.R(:,r)  ;
            end
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).multi_reg = gfile( dfonc{subj}{sess} , '^multiple_regressors' , 1 );
            matlabbatch{iJob}.spm.stats.fmri_spec.sess(sess).hpf = 128;
            
            
            matlabbatch{iJob}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
            matlabbatch{iJob}.spm.stats.fmri_spec.bases.none = true;
            matlabbatch{iJob}.spm.stats.fmri_spec.volt = 1;
            matlabbatch{iJob}.spm.stats.fmri_spec.global = 'None';
            matlabbatch{iJob}.spm.stats.fmri_spec.mthresh = 0.8;
            matlabbatch{iJob}.spm.stats.fmri_spec.mask = {''};
            matlabbatch{iJob}.spm.stats.fmri_spec.cvi = 'AR(1)';
            
            
        end % reg
        
    end % roi
    
end  % subj


[ matlabbatch ] = job_ending_rountines( matlabbatch, [], par );

e.addModel('stat', model_name_base, model_name ,model_name )


%% Estime design


fspm = cell(0);

for subj = 1 : length(e)
    for i = 1 : numel(fileROI)
        
        [~,nameROI] = spm_fileparts(fileROI{i});
        
        regressor_name = {'Belt', 'Grip'};
        
        for reg = 1 : length(regressor_name)
            
            model_name = sprintf('PPI_%s_%s',regressor_name{reg},nameROI);
            
            modelDir = e(subj).mkdir('stat',model_name_base,model_name);
            fspm{end+1,1} = fullfile(char(modelDir),'SPM.mat');
            
        end % reg
        
    end % roi
    
end  % subj


j_estimate_model = job_first_level_estimate(fspm,par);



%% Prepare contrasts

contrast = struct;

ppi    = zeros(7,1);
ppi(7) = 1;


contrast.values = {
    
ppi

};

contrast.names = {
    
'ppi'

};

contrast.types = repmat({'T'},[1 length(contrast.values)]);


par.delete_previous=1;


%% Generate contrasts

par.sessrep = 'repl';
j_contrast = job_first_level_contrast(fspm,contrast,par);


%% save

save e e

toc
