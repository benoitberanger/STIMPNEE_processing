clear
clc

all_contrasts = {
    
'Belt_NULL'
'Belt_Eye'
'Belt_Resp'
'Belt_Force'

'Belt_Diff_NULL'
'Belt_Diff_Eye'
'Belt_Diff_Resp'
'Belt_Diff_Force'

'Grip_Force'
'Grip_Diff_Force'

'Belt_Resp - Belt_Force' % 11
'Belt_Resp - Belt_Eye'   % 12
'Belt_Resp - Belt_NULL'

'Belt_Diff_Resp - Belt_Diff_Force'
'Belt_Diff_Resp - Belt_Diff_Eye'
'Belt_Diff_Resp - Belt_Diff_NULL'

'Belt_Force - Belt_NULL'% 17
'Belt_Eye - Belt_NULL'  % 18

'Belt_Diff_Force - Belt_Diff_NULL'
'Belt_Diff_Eye - Belt_Diff_NULL'

};


maindir = pwd;

modeldir = 'ANOVA_factorial3_electrophyByCondition_Derivatives';
designdir = r_mkdir(fullfile(maindir,'Analyse_2ndlevel'),modeldir);

imagepath = get_subdir_regex(maindir,'img');

myScans = tools.rando;

% procedure = 1 => yellow, procedure = 2 => blue

lvl_111 = [];
lvl_121 = [];
lvl_211 = [];
lvl_221 = [];
lvl_112 = [];
lvl_122 = [];
lvl_212 = [];
lvl_222 = [];


for s = 1 : size(myScans,1)
    
    lvl  = cell2mat( myScans(s,[2 3]) );
    
    current_imagepath = get_subdir_regex(imagepath,myScans{s,1},'stat','electrophyByConditon');
    
    current_contrastfile_BeltResp  = get_subdir_regex_files(current_imagepath,'con_0007.nii');
    current_contrastfile_BeltForce = get_subdir_regex_files(current_imagepath,'con_0008.nii');
    
    if isequal(lvl, [1 1])
        lvl_111 = [ lvl_111 ; current_contrastfile_BeltResp ];
        lvl_112 = [ lvl_112 ; current_contrastfile_BeltForce ];
    elseif isequal(lvl, [1 2])
        lvl_121 = [ lvl_121 ; current_contrastfile_BeltResp ];
        lvl_122 = [ lvl_122 ; current_contrastfile_BeltForce ];
    elseif isequal(lvl, [2 1])
        lvl_211 = [ lvl_211 ; current_contrastfile_BeltResp ];
        lvl_212 = [ lvl_212 ; current_contrastfile_BeltForce ];
    elseif isequal(lvl, [2 2])
        lvl_221 = [ lvl_221 ; current_contrastfile_BeltResp ];
        lvl_222 = [ lvl_222 ; current_contrastfile_BeltForce ];
    end
    
end



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
job1{1}.spm.stats.factorial_design.des.fd.fact(3).name = 'Condition';
job1{1}.spm.stats.factorial_design.des.fd.fact(3).levels = 2;
job1{1}.spm.stats.factorial_design.des.fd.fact(3).dept = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(3).variance = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(3).gmsca = 0;
job1{1}.spm.stats.factorial_design.des.fd.fact(3).ancova = 0;

job1{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1 1 1];
job1{1}.spm.stats.factorial_design.des.fd.icell(1).scans = lvl_111;
job1{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1 1 2];
job1{1}.spm.stats.factorial_design.des.fd.icell(2).scans = lvl_112;

job1{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [1 2 1];
job1{1}.spm.stats.factorial_design.des.fd.icell(3).scans = lvl_121;
job1{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [1 2 2];
job1{1}.spm.stats.factorial_design.des.fd.icell(4).scans = lvl_122;

job1{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [2 1 1];
job1{1}.spm.stats.factorial_design.des.fd.icell(5).scans = lvl_211;
job1{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [2 1 2];
job1{1}.spm.stats.factorial_design.des.fd.icell(6).scans = lvl_212;

job1{1}.spm.stats.factorial_design.des.fd.icell(7).levels = [2 2 1];
job1{1}.spm.stats.factorial_design.des.fd.icell(7).scans = lvl_221;
job1{1}.spm.stats.factorial_design.des.fd.icell(8).levels = [2 2 2];
job1{1}.spm.stats.factorial_design.des.fd.icell(8).scans = lvl_222;

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

do_delete(designdir,0)
mkdir(designdir{1})
spm_jobman('run', job1);


%% Estimate : Prepare

fspm = get_subdir_regex_files( designdir , 'SPM.mat' , 1 );

job2{1}.spm.stats.fmri_est.spmmat = fspm ;
job2{1}.spm.stats.fmri_est.write_residuals = 0;
job2{1}.spm.stats.fmri_est.method.Classical = 1;


%% Estimate : Run

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
par.delete_previous=0;
par.run=1;


%% Write contrasts

job_first_level_contrast(fspm,contrast,par)


%% Prepare display

show{1}.spm.stats.results.spmmat = fspm;
show{1}.spm.stats.results.conspec.titlestr = '';
show{1}.spm.stats.results.conspec.contrasts = 1;
show{1}.spm.stats.results.conspec.threshdesc = 'FWE'; % 'none' 'FWE' 'FDR'
show{1}.spm.stats.results.conspec.thresh = 0.05;
show{1}.spm.stats.results.conspec.extent = 10;
show{1}.spm.stats.results.conspec.conjunction = 1;
show{1}.spm.stats.results.conspec.mask.none = 1;
show{1}.spm.stats.results.units = 1;
show{1}.spm.stats.results.print = false;
show{1}.spm.stats.results.write.none = 1;


%% Display

spm_jobman('run', show );