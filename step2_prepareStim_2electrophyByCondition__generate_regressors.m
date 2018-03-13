clear
% close all
clc

load e

stim_dir = get_subdir_regex(fullfile(pwd,'stim'),{e.name})';

stim_files = get_subdir_regex_files(stim_dir,'MRI_\d.mat$')';
stim_files_char = char(stim_files);

rp_files = get_subdir_regex_files(sort(cellstr(e.getSerie('run_nm').print)),'^rp_.*.txt')';
rp_files_char = char(rp_files);

freq = 60;
TR = 1.520;


%%

for idx = 1 : size(stim_files_char,1)
    
    S = load( deblank(stim_files_char(idx,:)) );
    
    %% Volumes
    
    %     vol_idx  = cell2mat(S.DataStruct.TaskData.KL.KbEvents{1,2}(:,2)) == 1;
    %     vol_time = cell2mat(S.DataStruct.TaskData.KL.KbEvents{1,2}(vol_idx,1));
    
    Time  = cell2mat(S.DataStruct.TaskData.RR.Data(2:end-1,2));
    
    %% Convonve HRF from SPM
    
    fMRI_T     = spm_get_defaults('stats.fmri.t');
    fMRI_T0    = spm_get_defaults('stats.fmri.t0');
    xBF.T  = fMRI_T;
    xBF.T0 = fMRI_T0;
    
    xBF.dt     = TR/xBF.T;
    xBF.name = 'hrf';
    
    [xBF] = spm_get_bf(xBF); % HRF
    
    Belt = cell2mat(S.DataStruct.TaskData.RR.Data(2:end-1,4));
    Belt = Belt-mean(Belt);
    Belt = Belt/(max(abs(Belt)));
    BeltF = ft_preproc_bandpassfilter( Belt', freq, [0.001  0.3], 2 )';
    
    Grip = cell2mat(S.DataStruct.TaskData.RR.Data(2:end-1,5));
    Grip = Grip-mean(Grip);
    Grip = Grip/(max(abs(Grip)));
    GripF = ft_preproc_bandpassfilter( Grip', freq, [0.001  0.3], 2 )';
    
    Capn = cell2mat(S.DataStruct.TaskData.RR.Data(2:end-1,6));
    Capn = Capn-mean(Capn);
    Capn = Capn/(max(abs(Capn)));
    CapnF = ft_preproc_bandpassfilter( Capn', freq, [0.001  0.3], 2 )';
    
    
    U(1).u = BeltF;
    U(1).uu = Belt;
    U(1).name = {'Belt'};
    
    U(2).u = GripF;
    U(2).uu = Grip;
    U(2).name = {'Grip'};
    
    U(3).u = [0 ; diff(BeltF)];
    U(3).uu = BeltF;
    U(3).name = {'Diff_Belt'};
    
    U(4).u = [0 ; diff(GripF)];
    U(4).uu = GripF;
    U(4).name = {'Diff_Grip'};
    
    X = spm_Volterra(U, xBF.bf, 1); % convolution
    
    volumes_in_dataset = size(X,1)/freq/TR;
    nrVolumes_dataset = floor(volumes_in_dataset);
    X_reg = X( round((0:(nrVolumes_dataset - 1))*freq*TR)+1 ,:); % resample
    
    RP = load( deblank(rp_files_char(idx,:)) );
    
    % add 0 at the end for the remaining volumes without stim
    if size(RP,1) - nrVolumes_dataset > 0
        X_reg = [X_reg ; zeros( size(RP,1) - nrVolumes_dataset ,4)]; %#ok<AGROW>
    elseif size(RP,1) - nrVolumes_dataset < 0
        X_reg = X_reg(1:size(RP,1),:);
    end
    
    R = [X_reg RP];
    names = {'Belt', 'Grip', 'Diff_Belt', 'Diff_Grip'    'Tx', 'Ty', 'Tz',    'Rx', 'Ry', 'Rz'};
    
    
    dit_to_save = get_parent_path( deblank(stim_files_char(idx,:)) );
    
    nr = deblank(stim_files_char(idx,:));
    save(fullfile(dit_to_save, sprintf('R_Condition_%s.mat', nr(end-4)) ) , 'R', 'names' )
    
    
    %% Plot
    
    %     figure('Name',deblank(stim_files_char(idx,:)),'NumberTitle','off')
    %     plot(R(:,1:4))
    %
    %     for i = 1 : 4
    %         figure
    %         hold on
    %         plot(Time,U(i).uu,'black')
    %         plot(Time,U(i).u,'blue')
    %         plot(Time,X(:,i),'magenta')
    %         plot((0:size(X_reg,1)-1)*TR,X_reg(:,i),'red')
    %     end
    
end
