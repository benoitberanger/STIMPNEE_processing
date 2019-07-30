clear
clc

load e

par.run     = 0;
par.display = 1;
par.sge     = 0;


%% get ROIs

dirROI  = '/mnt/data/benoit/protocol/STIMPNEE/fmri/roi';
fileROI = cellstr(char(gfile(dirROI,'nii$'))); fileROI = remove_regex(fileROI,'T1');
char(fileROI)


%% prepare job

% select models
models = e.getModel('electrophySpectralPower_phy').getPath;
nRun   = 2;

job_DECONV = cell(length(models),nRun,numel(fileROI));

for j = 1 : length(models)
    
    for r = 1 : nRun
        
        for i = 1 : numel(fileROI)
            
            [~,nameROI] = spm_fileparts(fileROI{i});
            
            job_DECONV{j,r,i}.spm.stats.ppi.spmmat = models(j);
            job_DECONV{j,r,i}.spm.stats.ppi.type.sd.voi = {fullfile(fileparts(models{j}),sprintf('VOI_%s_run%d_%d.mat',nameROI,r,r))};
            job_DECONV{j,r,i}.spm.stats.ppi.name = sprintf('%s_run%d',nameROI,r);
            job_DECONV{j,r,i}.spm.stats.ppi.disp = 0;
            
        end
        
    end
    
end


%% run

job_DECONV = job_DECONV(:);

% job_ending_rountines(job_DECONV,[],par)
