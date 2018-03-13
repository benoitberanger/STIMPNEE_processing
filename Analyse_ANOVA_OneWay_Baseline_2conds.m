% close all
clear
% fclose('all')
clc


%% Parameters

maindir = pwd;

designdir = get_subdir_regex(maindir,'Analyse_2ndlevel','Analyse_ANOVA_OneWay_Baseline_2conds')

imagepath = get_subdir_regex(maindir,'img','V1_S1|V1_S2');

char(imagepath)


% Just to remember :
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

contrastpath = get_subdir_regex(imagepath,'stat','boxcar');
char(contrastpath), size(contrastpath)

con0010 = get_subdir_regex_files(contrastpath,'con_0010.nii');
con0011 = get_subdir_regex_files(contrastpath,'con_0011.nii');


%% Set job for SPM

matlabbatch{1}.spm.stats.factorial_design.dir = designdir;
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = con0010';
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = con0011';
matlabbatch{1}.spm.stats.factorial_design.des.anova.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.anova.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.anova.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
spm('defaults', 'FMRI');


%% Specify job

spm_jobman('run', matlabbatch);


%% Estimate

fspm = get_subdir_regex_files( designdir , 'SPM.mat' , 1 )

job2{1}.spm.stats.fmri_est.spmmat = fspm ;
job2{1}.spm.stats.fmri_est.write_residuals = 0;
job2{1}.spm.stats.fmri_est.method.Classical = 1;


%%

spm_jobman('run', job2);

