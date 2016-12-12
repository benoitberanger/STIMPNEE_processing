% close all
clear
% fclose('all')
clc


%% Parameters

maindir = '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE';

designdir_P1 = get_subdir_regex(maindir,'Analyse_2ndlevel','Regression_P1')
designdir_P2 = get_subdir_regex(maindir,'Analyse_2ndlevel','Regression_P2')

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
    
% fmri exam       AMPL   Procedure

'Temoin02_V5_S1'  -45.5  1
'Temoin02_V5_S2'  -38.2  2
'Temoin03_V5_S1'  -54.2  2
'Temoin03_V5_S2'  266.3  1
'Temoin04_V5_S1'  147.7  2
'Temoin04_V5_S2'  107.4  1
'Temoin05_V5_S1'   -1.9  2
'Temoin05_V5_S2'  -51.5  1
'Temoin06_V5_S1'  -71.5  1
'Temoin06_V5_S2'   22.4  2
'Temoin07_V5_S1'   50.8  2
'Temoin07_V5_S2'   34.2  1   
% 'Temoin08_V5_S1'  x
% 'Temoin08_V5_S2'  x

};

% procedure = 1 => yellow, procedure = 2 => blue

Procedure_1_idx = cell2mat(myScans(:,3)) == 1;
Procedure_2_idx = cell2mat(myScans(:,3)) == 2;

myScans_P1 = myScans(Procedure_1_idx,:);
myScans_P2 = myScans(Procedure_2_idx,:);

contrastpath_P1 = get_subdir_regex(imagepath,myScans_P1(:,1),'stat','fMRI');
char(contrastpath_P1), size(contrastpath_P1)
contrastpath_P2 = get_subdir_regex(imagepath,myScans_P2(:,1),'stat','fMRI');
char(contrastpath_P2), size(contrastpath_P2)

contrastfile_P1 = get_subdir_regex_files(contrastpath_P1,'con_0009.nii');
char(contrastfile_P1), size(contrastfile_P1)
contrastfile_P2 = get_subdir_regex_files(contrastpath_P2,'con_0009.nii');
char(contrastfile_P2), size(contrastfile_P2)


%% Fill the 2nd lvl design job

job1{1}.spm.stats.factorial_design.dir = designdir_P1;
job1{1}.spm.stats.factorial_design.des.mreg.scans = contrastfile_P1';
job1{1}.spm.stats.factorial_design.des.mreg.mcov.c = cell2mat(myScans_P1(:,2));
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

job1{2}.spm.stats.factorial_design.dir = designdir_P2;
job1{2}.spm.stats.factorial_design.des.mreg.scans = contrastfile_P2';
job1{2}.spm.stats.factorial_design.des.mreg.mcov.c = cell2mat(myScans_P2(:,2));
job1{2}.spm.stats.factorial_design.des.mreg.mcov.cname = 'AMPL';
job1{2}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
job1{2}.spm.stats.factorial_design.des.mreg.incint = 1;
job1{2}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
job1{2}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
job1{2}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job1{2}.spm.stats.factorial_design.masking.im = 1;
job1{2}.spm.stats.factorial_design.masking.em = {''};
job1{2}.spm.stats.factorial_design.globalc.g_omit = 1;
job1{2}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job1{2}.spm.stats.factorial_design.globalm.glonorm = 1;

spm('defaults', 'FMRI');
% spm_jobman('interactive', job1);


%% Prepare the job for estimation

do_delete(designdir_P1)
do_delete(designdir_P2)
mkdir(designdir_P1{1})
mkdir(designdir_P2{1})
spm_jobman('run', job1);


%% Estimate

fspm_P1 = get_subdir_regex_files( designdir_P1 , 'SPM.mat' , 1 )
fspm_P2 = get_subdir_regex_files( designdir_P2 , 'SPM.mat' , 1 )

job2{1}.spm.stats.fmri_est.spmmat = fspm_P1 ;
job2{1}.spm.stats.fmri_est.write_residuals = 0;
job2{1}.spm.stats.fmri_est.method.Classical = 1;

job2{2}.spm.stats.fmri_est.spmmat = fspm_P2 ;
job2{2}.spm.stats.fmri_est.write_residuals = 0;
job2{2}.spm.stats.fmri_est.method.Classical = 1;


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

job_first_level12_contrast(fspm_P1,contrast,par)
job_first_level12_contrast(fspm_P2,contrast,par)


%% Prepare show

show{1}.spm.stats.results.spmmat = fspm_P1;
show{1}.spm.stats.results.conspec.titlestr = '';
show{1}.spm.stats.results.conspec.contrasts = 1;
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
