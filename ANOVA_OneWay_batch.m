% close all
clear
% fclose('all')
clc


%% Parameters

maindir = pwd;

designdir = get_subdir_regex(maindir,'Analyse_2ndlevel','ANOVA_OneWay_OneSample')

imagepath = get_subdir_regex(maindir,'img','(_V1_S1)')
char(imagepath)

myContrasts = {
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

contrastpath = get_subdir_regex(imagepath,'stat','fMRI');
char(contrastpath), size(contrastpath)

% contrastfile = cell(length(myContrasts),1);
% for c = 1 : length(myContrasts)
%     
%     con = sprintf('con_%.4d.nii',c)
%     
%     contrastfile{c} = get_subdir_regex_files(contrastpath,con);
%     
% end

% contrastfile{1} = get_subdir_regex_files(contrastpath,'con_0010.nii');
contrastfile{1} = get_subdir_regex_files(contrastpath,'con_0011.nii');
% char(contrastfile), size(contrastfile)



%%

%-----------------------------------------------------------------------
% Job saved on 12-Dec-2016 15:24:29 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
job1{1}.spm.stats.factorial_design.dir = designdir;
for c = 1 : length(contrastfile)
   job1{1}.spm.stats.factorial_design.des.anova.icell(c).scans = contrastfile{c}'; 
end
job1{1}.spm.stats.factorial_design.des.anova.dept = 0;
job1{1}.spm.stats.factorial_design.des.anova.variance = 1;
job1{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
job1{1}.spm.stats.factorial_design.des.anova.ancova = 0;
job1{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
job1{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
job1{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job1{1}.spm.stats.factorial_design.masking.im = 1;
job1{1}.spm.stats.factorial_design.masking.em = {''};
job1{1}.spm.stats.factorial_design.globalc.g_omit = 1;
job1{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job1{1}.spm.stats.factorial_design.globalm.glonorm = 1;


spm('defaults', 'FMRI');
% spm_jobman('interactive', job1);


%% Prepare the job for estimation

spm_jobman('run', job1);


%% Estimate

fspm = get_subdir_regex_files( designdir , 'SPM.mat' , 1 )

job2{1}.spm.stats.fmri_est.spmmat = fspm ;
job2{1}.spm.stats.fmri_est.write_residuals = 0;
job2{1}.spm.stats.fmri_est.method.Classical = 1;


%%

spm_jobman('run', job2);


%% Contraste

% contrast.names = myContrasts;
% 
% 
% vals = eye( length(contrast.names) );
% 
% contrast.values = {};
% for v = 1 : size(vals,1)
% 
%     contrast.values{v,1} = vals(v,:);
%         
% end

contrast.names{1} = 'con_';
contrast.values{1} = [1];

contrast.types = cat(1,repmat({'T'},[1 length(contrast.names)]));
par.delete_previous=1;
par.run=1;


%%

job_first_level_contrast(fspm,contrast,par)


%% Prepare show

show{1}.spm.stats.results.spmmat = fspm;
show{1}.spm.stats.results.conspec.titlestr = '';
show{1}.spm.stats.results.conspec.contrasts = 8;
show{1}.spm.stats.results.conspec.threshdesc = 'none'; % 'none' 'FWE' 'FDR'
show{1}.spm.stats.results.conspec.thresh = 0.05;
show{1}.spm.stats.results.conspec.extent = 10;
show{1}.spm.stats.results.conspec.conjunction = 1;
show{1}.spm.stats.results.conspec.mask.none = 1;
show{1}.spm.stats.results.units = 1;
show{1}.spm.stats.results.print = 'ps';
show{1}.spm.stats.results.write.none = 1;


% spm_jobman('interactive', show);


%% Display

spm_jobman('run', show );
