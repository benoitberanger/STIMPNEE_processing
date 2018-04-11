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

modeldir = 'ANOVA_OneWay_electrophyByCondition';
designdir = r_mkdir(fullfile(maindir,'Analyse_2ndlevel'),modeldir);

imagepath = get_subdir_regex(maindir,'img');

myScans = tools.rando;

exam_V1_S1_idx = regexp( myScans(:,1) ,  'V1_S1');
exam_V1_S1_idx =  find(~cellfun('isempty',exam_V1_S1_idx));

exam_V1_S1_name = myScans(exam_V1_S1_idx,1);

% Fetch dirs
exam_V1_S1_dir = get_subdir_regex(imagepath,exam_V1_S1_name)';

% Fetch contrasts
for con = [01 02 03 04]
    con_name = sprintf('con_%.4d.nii',con);
    CONS.(con_name(1:end-4)) = get_subdir_regex_files( fullfile(exam_V1_S1_dir,'stat','electrophyByConditon'), con_name );
end

%% Prepare the job for estimation

matlabbatch{1}.spm.stats.factorial_design.dir = designdir;
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(1).scans = CONS.con_0001';
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(2).scans = CONS.con_0002';
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(3).scans = CONS.con_0003';
matlabbatch{1}.spm.stats.factorial_design.des.anova.icell(4).scans = CONS.con_0004';
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

do_delete(designdir,0)
mkdir(designdir{1})
spm_jobman('run', matlabbatch);


%% Estimate : Prepare

fspm = get_subdir_regex_files( designdir , 'SPM.mat' , 1 );

job2{1}.spm.stats.fmri_est.spmmat = fspm ;
job2{1}.spm.stats.fmri_est.write_residuals = 0;
job2{1}.spm.stats.fmri_est.method.Classical = 1;

%% Estimate : Run

spm_jobman('run', job2);


%% Contraste

contrast.names = {
    
'Belt_NULL'
'Belt_Eye'
'Belt_Resp'
'Belt_Force'

}';

contrast.values = {
    [1 0 0 0]
    [0 1 0 0]
    [0 0 1 0]
    [0 0 0 1]
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
