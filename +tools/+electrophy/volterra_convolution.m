function [ X ] = volterra_convolution( U, TR )

fMRI_T     = spm_get_defaults('stats.fmri.t');
fMRI_T0    = spm_get_defaults('stats.fmri.t0');
xBF.T  = fMRI_T;
xBF.T0 = fMRI_T0;

xBF.dt     = TR/xBF.T;
xBF.name = 'hrf';

[xBF] = spm_get_bf(xBF); % get HRF

X = spm_Volterra(U, xBF.bf, 1); % convolution

end % function
