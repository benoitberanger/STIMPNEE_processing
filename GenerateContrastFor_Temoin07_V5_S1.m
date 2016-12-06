clear
clc

%-----------------------------------------------------------------------
% Job saved on 06-Dec-2016 11:08:14 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.imcalc.input = {
                                        '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/img/2016_06_10_STIMPNEE_Temoin02_V5_S2/stat/fMRI/con_0009.nii,1'
                                        '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/img/2016_06_03_STIMPNEE_Temoin03_V5_S2/stat/fMRI/con_0009.nii,1'
                                        '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/img/2016_05_27_STIMPNEE_Temoin04_V5_S1/stat/fMRI/con_0009.nii,1'
                                        '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/img/2016_06_17_STIMPNEE_Temoin05_V5_S1/stat/fMRI/con_0009.nii,1'
                                        '/media/benoit/DATADRIVE1/fMRI_data_benoit/STIMPNEE/img/2016_10_07_STIMPNEE_Temoin06_V5_S2/stat/fMRI/con_0009.nii,1'
                                        };
matlabbatch{1}.spm.util.imcalc.output = 'con_0009.nii';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2+i3+i4+i5)/5';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

spm('defaults', 'FMRI');
spm_jobman('run', matlabbatch);

