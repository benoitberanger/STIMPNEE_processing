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

job_VOI = cell(length(models),nRun,numel(fileROI));

for j = 1 : length(models)
    
    for r = 1 : nRun
        
        for i = 1 : numel(fileROI)
            
            [~,nameROI] = spm_fileparts(fileROI{i});
            
            job_VOI{j,r,i}.spm.util.voi.spmmat = models(j);
            job_VOI{j,r,i}.spm.util.voi.adjust = NaN; % 0 adjust nothing, NaN adjust everything, => don't know what it means, but NaN is in the manual
            job_VOI{j,r,i}.spm.util.voi.session = r;
            job_VOI{j,r,i}.spm.util.voi.name = sprintf('%s_run%d',nameROI,r);
            job_VOI{j,r,i}.spm.util.voi.roi{1}.mask.image = fileROI(i);
            job_VOI{j,r,i}.spm.util.voi.roi{1}.mask.threshold = 0.01;
            job_VOI{j,r,i}.spm.util.voi.expression = 'i1';
            
        end
        
    end
    
end


%% run

job_VOI = job_VOI(:);

% job_ending_rountines(job_VOI,[],par)
