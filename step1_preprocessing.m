clear
clc

use_pct = 1; % Parallel Computing Toolbox

setenv('FSLOUTPUTTYPE', 'NIFTI')
par.fsl_output_format = 'NIFTI';

%% Prepare paths and regexp

% chemin=[ pwd filesep 'img' ];
%
% suj = get_subdir_regex(chemin,'Temoin');
% suj(22) = [];
% %to see the content
% char(suj)
%
% %functional and anatomic subdir
% par.dfonc_reg='PA$';
% par.dfonc_reg_oposit_phase = 'PAblip$';
% par.danat_reg='t1mpr';
%
% %for the preprocessing : Volume selecytion
% par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
% par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

main_dir = fullfile(pwd,'img');

par.display=0;
par.run=1;
par.pct = 1;

%% Get files paths

check_coherence = 0;

if check_coherence
    
    e = exam(main_dir, 'STIMPNEE' );
    s = exam(fullfile(pwd,'stim'), 'STIMPNEE' )
    nSubjects = 20;
    
    for subj = 1 : nSubjects
        tmp1 = e.getExam(sprintf('Temoin%0.2d',subj));
        length(tmp1)
        disp(char(tmp1.name))
        %    disp(' ')
        tmp2 = s.getExam(sprintf('Temoin%0.2d',subj));
        length(tmp2)
        disp(char(tmp2.name))
        disp(' ')
        
        for t = 1 : numel(tmp1)
            result = strcmp(tmp1(t).name,tmp2(t).name)
            if ~result
                warning(' ')
            end
            
        end
        
    end
    
    return
    
end

% dfonc = get_subdir_regex_multi(suj,par.dfonc_reg)
% dfonc_op = get_subdir_regex_multi(suj,par.dfonc_reg_oposit_phase)
% dfoncall = get_subdir_regex_multi(suj,{par.dfonc_reg,par.dfonc_reg_oposit_phase })
% anat = get_subdir_regex_one(suj,par.danat_reg) %should be no warning

% e = exam(main_dir, 'STIMPNEE' );

% Only fetch subject used for sendonc level analisys
E = exam.empty;
r = tools.rando;
for subj = 1:size(r,1)
    E = [E ; exam(main_dir,r{subj,1}) ]; %#ok<AGROW>
end

e = E;

% 3DT1
e.addSerie('t1mpr','anat_T1',1)
e.getSerie('anat_T1').addVolume('^s.*nii','s',1)

% run 1 & 2
e.addSerie('PA$','run_nm',2)
e.getSerie('run_nm').addVolume('^f.*nii','f',1)

% run 1 & 2 : blip
e.addSerie('PAblip$','run_bp',2)
e.getSerie('run_bp').addVolume('^f.*nii','f',1)

% Unzip if necessary
e.getVolume.unzip

e.reorderSeries('name'); % mostly useful for topup, that requires pairs of (AP,PA)/(PA,AP) scans

e.explore
dfonc    = e.getSerie('run_nm').toJob;
dfonc_op = e.getSerie('run_bp').toJob;
dfoncall = e.getSerie('run').toJob;
anat     = e.getSerie('anat_T1').toJob(0);


%% Segment anat

%anat segment
fanat = e.getSerie('anat').getVolume('^s');

par.GM   = [0 0 1 0]; % Unmodulated / modulated / native_space dartel / import
par.WM   = [0 0 1 0];
j_segment = job_do_segment(fanat,par);

%apply normalize on anat
fy    = e.getSerie('anat').getVolume('^y_s' );
fanat = e.getSerie('anat').getVolume('^ms');
par.vox          = [NaN NaN NaN];
j_apply_normalise=job_apply_normalize(fy,fanat,par);

% Apply normalize on C1 C2 C3
fc1 = e.getSerie('anat').getVolume('^c1s');
fc2 = e.getSerie('anat').getVolume('^c2s');
fc3 = e.getSerie('anat').getVolume('^c3s');
par.vox = [2.5 2.5 2.5]; % for tapas/physio
job_apply_normalize(fy,fc1,par);
job_apply_normalize(fy,fc2,par);
job_apply_normalize(fy,fc3,par);


%% Brain extract

ff=e.getSerie('anat').addVolume('^c[123]','C',3);
fo=addsuffixtofilenames(anat,'mask_brain');
do_fsl_add(ff,fo);
fm=e.getSerie('anat').addVolume('^mask_b','mask_brain',1);

fanat=e.getSerie('anat').getVolume('^s').toJob;
fo = addprefixtofilenames(fanat,'brain_');
do_fsl_mult(concat_cell(fm,fanat),fo);
e.getSerie('anat').addVolume('^brain_','brain_extract',1)


%% Preprocess fMRI runs

%realign and reslice
j_realign_reslice = job_realign(e.getSerie('run_nm').getVolume('^f'),par);

%realign and reslice opposite phase
j_realign_reslice_op = job_realign(e.getSerie('run_bp').getVolume('^f'),par);

%topup and unwarp
par.sge=0;
do_topup_unwarp_4D(e.getSerie('run').getVolume('^rf'),par)

%coregister mean fonc on brain_anat
% fanat = get_subdir_regex_files(anat,'^s.*nii$',1) % raw anat
% fanat = get_subdir_regex_files(anat,'^ms.*nii$',1) % raw anat + signal bias correction
% fanat = get_subdir_regex_files(anat,'^brain_s.*nii$',1) % brain mask applied (not perfect, there are holes in the mask)
fanat = e.getSerie('anat').getVolume('^brain_extract');

fmean = e.getSerie('run_nm_001').getVolume('^utmeanf');
fo = e.getSerie('run_nm').getVolume('^utrf');
par.type = 'estimate';
j_coregister=job_coregister(fmean,fanat,fo,par);

%apply normalize
fy = e.getSerie('anat').getVolume('^y');
par.vox                = [2.5 2.5 2.5]; % for tapas/physio
j_apply_normalize      = job_apply_normalize(fy,fo   ,par);
j_apply_normalize_mean = job_apply_normalize(fy,fmean,par);

%smooth the data
ffonc = e.getSerie('run_nm').getVolume('^wutrf');
par.smooth = [8 8 8];
j_smooth=job_smooth(ffonc,par);
e.getSerie('run_nm').addVolume('^swutrf','swutrf',1)

% Coregister wc[23] -> wmean
par.type = 'estimate_and_write';
j_coregister_w=job_coregister(...
    e.gser('anat').gvol('wc2'),...
    e.gser('run' ).gvol('wutmean').removeEmpty,...
    e.gser('anat').gvol('wc3'),...
    par);

save('e','e')

return
