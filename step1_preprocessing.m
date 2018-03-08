clear
clc

use_pct = 1; % Parallel Computing Toolbox

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

e = exam(main_dir, 'STIMPNEE' );

% 3DT1
e.addSerie('t1mpr','anat_T1',1)
e.getSerie('anat_T1').addVolume('^s.*nii','s',1)

% run 1 & 2
e.addSerie('PA$','run_nm',2)
e.getSerie('run_nm').addVolume('^f.*nii','f',1)

% run 1 & 2 : blip
e.addSerie('PAblip$','run_blip',2)
e.getSerie('run_blip').addVolume('^f.*nii','f',1)

% Unzip if necessary
e.getVolume.unzip

e.reorderSeries('name'); % mostly useful for topup, that requires pairs of (AP,PA)/(PA,AP) scans

e.explore
dfonc    = e.getSerie('run_nm').toJob;
dfonc_op = e.getSerie('run_blip').toJob;
dfoncall = e.getSerie('run').toJob;
anat     = e.getSerie('anat_T1').toJob(0);


%% Segment anat

%anat segment
fanat = e.getSerie('anat').getVolume('^s').toJob;

par.GM   = [0 0 1 0]; % Unmodulated / modulated / native_space dartel / import
par.WM   = [0 0 1 0];
j_segment = job_do_segment(fanat,par);
fy    = e.getSerie('anat').addVolume('^y' ,'y' );
fanat = e.getSerie('anat').addVolume('^ms','ms');

%apply normalize on anat
j_apply_normalise=job_apply_normalize(fy,fanat,par);
e.getSerie('anat').addVolume('^wms','wms',1)


%% Brain extract

ff=e.getSerie('anat').addVolume('^c[123]','c',3);
fo=addsuffixtofilenames(anat,'mask_brain');
do_fsl_add(ff,fo);
fm=e.getSerie('anat').addVolume('^mask_b','mask_brain',1);

fanat=e.getSerie('anat').getVolume('^s').toJob;
fo = addprefixtofilenames(fanat,'brain_');
do_fsl_mult(concat_cell(fm,fanat),fo);
e.getSerie('anat').addVolume('^brain_','brain_extract',1)


%% Preprocess fMRI runs

%realign and reslice
par.file_reg = '^f.*nii'; par.type = 'estimate_and_reslice';
j_realign_reslice = job_realign(dfonc,par);
e.getSerie('run_nm').addVolume('^rf','rf',1)

%realign and reslice opposite phase
par.file_reg = '^f.*nii'; par.type = 'estimate_and_reslice';
j_realign_reslice_op = job_realign(dfonc_op,par);
e.getSerie('run_blip').addVolume('^rf','rf',1)

%topup and unwarp
par.file_reg = {'^rf.*nii'}; par.sge=0;
do_topup_unwarp_4D(dfoncall,par)
e.getSerie('run').addVolume('^utmeanf','utmeanf',1)
e.getSerie('run').addVolume('^utrf.*nii','utrf',1)

%coregister mean fonc on brain_anat
% fanat = get_subdir_regex_files(anat,'^s.*nii$',1) % raw anat
% fanat = get_subdir_regex_files(anat,'^ms.*nii$',1) % raw anat + signal bias correction
% fanat = get_subdir_regex_files(anat,'^brain_s.*nii$',1) % brain mask applied (not perfect, there are holes in the mask)
fanat = e.getSerie('anat').getVolume('^brain_extract').toJob;

fmean = e.getSerie('run_nm_001').getVolume('^utmeanf').toJob;
fo = e.getSerie('run_nm').getVolume('^utrf').toJob;
par.type = 'estimate';
j_coregister=job_coregister(fmean,fanat,fo,par);

%apply normalize
fy = e.getSerie('anat').getVolume('^y').toJob;
j_apply_normalize=job_apply_normalize(fy,fo,par);

%smooth the data
ffonc = e.getSerie('run_nm').addVolume('^wutrf','wutrf',1);
par.smooth = [8 8 8];
j_smooth=job_smooth(ffonc,par);
e.getSerie('run_nm').addVolume('^swutrf','swutrf',1)


save('e','e')

return
