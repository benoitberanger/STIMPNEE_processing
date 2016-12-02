clear all
clc


%% Prepare paths and regexp

chemin={'/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/raw'}

suj = get_subdir_regex(chemin,'Temoin02_V1_S1'); %to get all subdir that start with 2
%to see the content
char(suj)


%functional and anatomic subdir
par.dfonc_reg='PA$';
par.dfonc_reg_oposit_phase = 'PAblip$';
par.danat_reg='t1mpr';

%for the preprocessing : Volume selecytion
par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.run=1;par.display=0; 


%% Segment anat

%anat segment
anat = get_subdir_regex(suj,par.danat_reg)
fanat = get_subdir_regex_files(anat,par.anat_file_reg,1)

par.GM   = [1 0 1 0]; % Unmodulated / modulated / native_space dartel / import
par.WM   = [1 0 1 0]; 
j = job_do_segment(fanat,par)

%apply normalize on anat
fy = get_subdir_regex_files(anat,'^y',1)
fanat = get_subdir_regex_files(anat,'^ms',1)
j=job_apply_normalize(fy,fanat,par)


%% Brain extract

ff=get_subdir_regex_files(anat,'^c[123]',3);
fo=addsufixtofilenames(anat,'/mask_brain');
do_fsl_add(ff,fo)
fm=get_subdir_regex_files(anat,'^mask_b',1); fanat=get_subdir_regex_files(anat,'^s.*nii',1);
fo = addprefixtofilenames(fanat,'brain_');
do_fsl_mult(concat_cell(fm,fanat),fo);


%% Get files paths

dfonc = get_subdir_regex_multi(suj,par.dfonc_reg)
dfonc_op = get_subdir_regex_multi(suj,par.dfonc_reg_oposit_phase)
dfoncall = get_subdir_regex_multi(suj,{par.dfonc_reg,par.dfonc_reg_oposit_phase })
anat = get_subdir_regex_one(suj,par.danat_reg) %should be no warning


%% Preprocess fMRI runs

%realign and reslice
par.file_reg = '^f.*nii'; par.type = 'estimate_and_reslice';
j = job_realign(dfonc,par)

%realign and reslice opposite phase
par.file_reg = '^f.*nii'; par.type = 'estimate_and_reslice';
j = job_realign(dfonc_op,par)

%topup and unwarp
par.file_reg = {'^rf.*nii'}; 
do_topup_unwarp_4D(dfoncall,par)

%coregister mean fonc on brain_anat
fanat = get_subdir_regex_files(anat,'^brain.*nii$',1)

par.type = 'estimate';
for nbs=1:length(suj)
    fmean(nbs) = get_subdir_regex_files(dfonc{nbs}(1),'^utmeanf');
end

fo = get_subdir_regex_files(dfonc,'^utrf.*nii',1)
j=job_coregister(fmean,fanat,fo,par)

%apply normalize
fy = get_subdir_regex_files(anat,'^y',1)
j=job_apply_normalize(fy,fo,par)

%smooth the data
ffonc = get_subdir_regex_files(dfonc,'^wutrf')
par.smooth = [8 8 8];
j=job_smooth(ffonc,par);


return


%% Prepare first level

sta=r_mkdir(suj,'stat')
st =r_mkdir(sta,'fMRI')

[~, subdir] = get_parent_path(suj,1)

stimpath = '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/stim';
stimdir = get_subdir_regex(stimpath,subdir);

fons = get_subdir_regex_files(stimdir,'MRI_[12]_SPM.mat$',2);
char(fons)

par.file_reg = '^wutrf';


%% fMRI design specification

j = job_first_level12(dfonc,st,fons,par)


%% Estime design

fspm = get_subdir_regex_files(st,'SPM',1)
j = job_first_level12_estimate(fspm)


%% Prepare contrasts

contrast.names = {
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

contrast.values = {
    [1 0 0 0]
    [0 1 0 0]
    [0 0 1 0]
    [0 0 0 1]
    [-1 1 0 0]
    [-1 0 1 0]
    [-1 0 0 1]
    [0 1 -1 0]
    [0 -1 1 0]
    [0 1 0 -1]
    [0 0 1 -1]
    [-1 2 0 -1]
    [-1 0 2 -1]
    };

contrast.types = repmat({'T'},[1 length(contrast.values)]);
par.delete_previous=1;


%% Generate contrasts

j = job_first_level12_contrast_rep(fspm,contrast,par)

