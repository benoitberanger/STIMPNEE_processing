clear
clc

modeldir     = 'ANOVA_Factorial_boxcar_Resp-Eye';
inputdir     = 'boxcar';
contrastname = 'con_0011.nii';

tools.second_level.main( modeldir, inputdir, contrastname )
