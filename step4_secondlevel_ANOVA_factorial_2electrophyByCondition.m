clear
clc

main_dir = pwd;

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

'Belt_Resp - Belt_Force'
'Belt_Resp - Belt_Eye'
'Belt_Resp - Belt_NULL'

'Belt_Diff_Resp - Belt_Diff_Force'
'Belt_Diff_Resp - Belt_Diff_Eye'
'Belt_Diff_Resp - Belt_Diff_NULL'

'Belt_Force - Belt_NULL'
'Belt_Eye - Belt_NULL'

'Belt_Diff_Force - Belt_Diff_NULL'
'Belt_Diff_Eye - Belt_Diff_NULL'

};

inputdir     = 'electrophyByCond';

for c = 1 : length(all_contrasts)
    
    modeldir     = sprintf('ANOVA_Factorial_electrophyByCond/%s',regexprep(all_contrasts{c},' ',''))
    contrastname = sprintf('con_%04d.nii',c)
    
    tools.second_level.main( modeldir, inputdir, contrastname )
    
    cd(main_dir)
    
end
