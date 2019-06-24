clc
clear

load e

%% dirs

dirFunc = e.getSerie('run_nm').toJob;
dirNoiseROI = e.getSerie('anat').toJob(0);


%% tapas

% Physio regressors types
par.usePhysio = 0;
par.RETROICOR = 0;
par.RVT       = 0;
par.HRV       = 0;

% Noise ROI regressors
par.noiseROI = 1;
par.noiseROI_files_regex  = '^wutrf.*nii';       % usually use normalied files, NOT the smoothed data
par.noiseROI_mask_regex   = '^rwc[23].*nii'; % 2 = WM, 3 = CSF
par.noiseROI_thresholds   = [0.95 0.95];     % keep voxels with tissu probabilty >= 95%
par.noiseROI_n_voxel_crop = [2 1];           % crop n voxels in each direction, to avoid partial volume
par.noiseROI_n_components = 10;              % keep n PCA componenets

% Movement regressors
par.rp           = 1;
par.rp_regex     = '^rp.*txt';
par.rp_order     = 24; % can be 6, 12, 24
% 6 = just add rp, 12 = also adds first order derivatives, 24 = also adds first + second order derivatives
par.rp_method    = 'FD'; % 'MAXVAL' / 'FD' / 'DVARS'
par.rp_threshold = 0.5;  % Threshold above which a stick regressor is created for corresponding volume of exceeding value

par.other_regressor_regex = ''; % if you want to add other ones...

par.print_figures = 0; % 0 , 1 , 2 , 3

par.jobname  = 'spm_physio';
par.walltime = '04:00:00';
par.sge      = 0;

par.run      = 1;
par.display  = 0;
par.redo     = 0;
par.verbose  = 2;
par.pct      = 1;

[ jobs ]= job_physio_tapas( dirFunc, [], dirNoiseROI, par);

