% close all
clear
% fclose('all')
clc


%% Parameters

maindir = '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE';

designdir = get_subdir_regex(maindir,'Analyse_2ndlevel','Regression')

imagepath = get_subdir_regex(maindir,'img')

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


myScans = {
    
% fmri exam       AMPL

'Temoin02_V5_S1'  -45.5
'Temoin02_V5_S2'  -38.2
'Temoin03_V5_S1'  -54.2
'Temoin03_V5_S2'  266.3
'Temoin04_V5_S1'  147.7
'Temoin04_V5_S2'  107.4
'Temoin05_V5_S1'  -1.9
'Temoin05_V5_S2'  -51.5
'Temoin06_V5_S1'  -71.5
'Temoin06_V5_S2'  22.4
'Temoin07_V5_S1'  50.8
'Temoin07_V5_S2'  34.2

};

contrastpath = get_subdir_regex(imagepath,myScans(:,1),'stat','fMRI');
char(contrastpath), size(contrastpath)

contrastfile = get_subdir_regex_files(contrastpath,'con_0009.nii');
char(contrastfile), size(contrastfile)


%% Fill the 2nd lvl design job

%-----------------------------------------------------------------------
% Job saved on 06-Dec-2016 11:29:14 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
job1{1}.spm.stats.factorial_design.dir = designdir;
job1{1}.spm.stats.factorial_design.des.mreg.scans = contrastfile';
job1{1}.spm.stats.factorial_design.des.mreg.mcov.c = cell2mat(myScans(:,2));
job1{1}.spm.stats.factorial_design.des.mreg.mcov.cname = 'AMPL';
job1{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
job1{1}.spm.stats.factorial_design.des.mreg.incint = 1;
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

do_delete(designdir)
mkdir(designdir{1})
spm_jobman('run', job1);


%% Estimate

fspm = get_subdir_regex_files( designdir , 'SPM.mat' , 1 )

job2{1}.spm.stats.fmri_est.spmmat = fspm ;
job2{1}.spm.stats.fmri_est.write_residuals = 0;
job2{1}.spm.stats.fmri_est.method.Classical = 1;


%%

spm_jobman('run', job2);


%% Contraste

contrast.names = {
    'Positive';
    'Negative';
    }';

contrast.values = {
    [0 1]
    [0 -1]
    }';

contrast.types = cat(1,repmat({'T'},[1 length(contrast.names)]));
par.delete_previous=0;
par.run=1;


%%

job_first_level12_contrast(fspm,contrast,par)


%% Prepare show

show{1}.spm.stats.results.spmmat = fspm;
show{1}.spm.stats.results.conspec.titlestr = '';
show{1}.spm.stats.results.conspec.contrasts = 1;
show{1}.spm.stats.results.conspec.threshdesc = 'none'; % 'none' 'FWE' 'FDR'
show{1}.spm.stats.results.conspec.thresh = 0.05;
show{1}.spm.stats.results.conspec.extent = 0;
show{1}.spm.stats.results.conspec.conjunction = 1;
show{1}.spm.stats.results.conspec.mask.none = 1;
show{1}.spm.stats.results.units = 1;
show{1}.spm.stats.results.print = 'ps';
show{1}.spm.stats.results.write.none = 1;


% spm_jobman('interactive', show);


%% Display

spm_jobman('run', show );
