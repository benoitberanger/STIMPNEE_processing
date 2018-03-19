clear
clc

modeldir     = 'ANOVA_Factorial_boxcar_Force-Eye';
inputdir     = 'boxcar';
contrastname = 'con_0010.nii';

tools.second_level.main( modeldir, inputdir, contrastname )
