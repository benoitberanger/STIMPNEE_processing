% close all
clear
% fclose('all')
clc


%% Parameters

maindir = '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE';

designdir = get_subdir_regex(maindir,'Analyse_2ndlevel','ANOVA_Factorial')

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
    
% fmri exam       'procedure' 'time'

'Temoin02_V1_S1'  1           1
'Temoin02_V5_S1'  1           2
'Temoin02_V1_S2'  2           1
'Temoin02_V5_S2'  2           2
'Temoin03_V1_S1'  2           1
'Temoin03_V5_S1'  2           2
'Temoin03_V1_S2'  1           1
'Temoin03_V5_S2'  1           2
'Temoin04_V1_S1'  2           1
'Temoin04_V5_S1'  2           2
'Temoin04_V1_S2'  1           1
'Temoin04_V5_S2'  1           2
'Temoin05_V1_S1'  2           1
'Temoin05_V5_S1'  2           2
'Temoin05_V1_S2'  1           1
'Temoin05_V5_S2'  1           2
'Temoin06_V1_S1'  1           1
'Temoin06_V5_S1'  1           2
'Temoin06_V1_S2'  2           1
'Temoin06_V5_S2'  2           2
'Temoin07_V1_S1'  2           1
'Temoin07_V5_S1'  2           2
'Temoin07_V1_S2'  1           1
'Temoin07_V5_S2'  1           2
'Temoin08_V1_S1'  1           1
'Temoin08_V5_S1'  1           2
'Temoin08_V1_S2'  2           1
'Temoin08_V5_S2'  2           2

};

% procedure = 1 => yellow, procedure = 2 => blue


lvl_11 = [];
lvl_12 = [];
lvl_21 = [];
lvl_22 = [];

for s = 1 : size(myScans)
    
    lvl  = cell2mat( myScans(s,[2 3]) );
    
    current_imagepath = get_subdir_regex(imagepath,myScans{s,1},'stat','fMRI');
    
    current_contrastfile = get_subdir_regex_files(current_imagepath,'con_0009.nii');
    
    if isequal(lvl, [1 1])
        lvl_11 = [ lvl_11 current_contrastfile ];
    elseif isequal(lvl, [1 2])
        lvl_12 = [ lvl_12 current_contrastfile ];
    elseif isequal(lvl, [2 1])
        lvl_21 = [ lvl_21 current_contrastfile ];
    elseif isequal(lvl, [2 2])
        lvl_22 = [ lvl_22 current_contrastfile ];
    end
    
end

char(lvl_11), size(lvl_11)
char(lvl_12), size(lvl_12)
char(lvl_21), size(lvl_21)
char(lvl_22), size(lvl_22)


%% Fill the 2nd lvl design job

%-----------------------------------------------------------------------
% Job saved on 01-Dec-2016 16:23:13 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
job1{1}.spm.stats.factorial_design.dir = designdir;
job1{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Procedure';
job1{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
job1{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Time';
job1{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 2;
job1{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
job1{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1 1];
job1{1}.spm.stats.factorial_design.des.fd.icell(1).scans = lvl_11';
job1{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1 2];
job1{1}.spm.stats.factorial_design.des.fd.icell(2).scans = lvl_12';
job1{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [2 1];
job1{1}.spm.stats.factorial_design.des.fd.icell(3).scans = lvl_21';
job1{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2 2];
job1{1}.spm.stats.factorial_design.des.fd.icell(4).scans = lvl_22';
job1{1}.spm.stats.factorial_design.des.fd.contrasts = 1;
job1{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
job1{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
job1{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
job1{1}.spm.stats.factorial_design.masking.im = 1;
job1{1}.spm.stats.factorial_design.masking.em = {''};
job1{1}.spm.stats.factorial_design.globalc.g_omit = 1;
job1{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
job1{1}.spm.stats.factorial_design.globalm.glonorm = 1;


spm('defaults', 'FMRI');

% spm_jobman('interactive',job1);
% spm('show');


%% Prepare the job for estimation

do_delete(designdir,1)
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
    'P2_J5 > P1_J5';
    'P2_J1 > P1_J1';
    'P2_J5 - P2_J1'; % <--- img
    'P2_J1 - P2_J5';
    'P1_J5 > P2_J5';
    'P1_J1 > P2_J1';
    'P1_J5 - P1_J1'; % <--- img
    'P1_J1 - P1_J5';
    }';

contrast.values = {
    [0 -1 0 1]
    [-1 0 1 0]
    [0 0 -1 1]
    [0 0 1 -1]
    
    [-1 0 1 0]
    [0 -1 0 1]
    [-1 1 0 0]
    [1 -1 0 0]
    }';

contrast.types = cat(1,repmat({'T'},[1 length(contrast.names)]));
par.delete_previous=1;
par.run=1;


%% Write contrasts

job_first_level12_contrast(fspm,contrast,par)


%% Prepare display

show{1}.spm.stats.results.spmmat = fspm;
show{1}.spm.stats.results.conspec.titlestr = '';
show{1}.spm.stats.results.conspec.contrasts = 3;
show{1}.spm.stats.results.conspec.threshdesc = 'none'; % 'none' 'FWE' 'FDR'
show{1}.spm.stats.results.conspec.thresh = 0.05;
show{1}.spm.stats.results.conspec.extent = 10;
show{1}.spm.stats.results.conspec.conjunction = 1;
show{1}.spm.stats.results.conspec.mask.none = 1;
show{1}.spm.stats.results.units = 1;
show{1}.spm.stats.results.print = 'ps';
show{1}.spm.stats.results.write.none = 1;


%% Display

spm_jobman('run', show );
