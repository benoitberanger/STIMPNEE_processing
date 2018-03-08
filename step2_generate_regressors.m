clear
close all
clc

load('/mnt/data/benoit/Protocol/STIMPNEE/fmri/stim/2017_12_08_STIMPNEE_Temoin07_V5_S1BIS/Témoin07_V5_S1BIS_FullMRIrun_MRI_1.mat');
% load('/mnt/data/benoit/Protocol/STIMPNEE/fmri/stim/2017_12_08_STIMPNEE_Temoin07_V5_S1BIS/Témoin07_V5_S1BIS_FullMRIrun_MRI_2.mat');

freq = 60;
TR = 1.520;


%% Volumes

vol_idx  = cell2mat(DataStruct.TaskData.KL.KbEvents{1,2}(:,2)) == 1;
vol_time = cell2mat(DataStruct.TaskData.KL.KbEvents{1,2}(vol_idx,1));

Time  = cell2mat(DataStruct.TaskData.RR.Data(2:end-1,2));

%% Convonve HRF from SPM

fMRI_T     = spm_get_defaults('stats.fmri.t');
fMRI_T0    = spm_get_defaults('stats.fmri.t0');
xBF.T  = fMRI_T;
xBF.T0 = fMRI_T0;

xBF.dt     = TR/xBF.T;
xBF.name = 'hrf';

[xBF] = spm_get_bf(xBF); % HRF

Belt = cell2mat(DataStruct.TaskData.RR.Data(2:end-1,4));
Belt = Belt-mean(Belt);
Belt = Belt/(max(abs(Belt)));
% BeltF = ft_preproc_lowpassfilter(Belt', 60, 0.3)';
BeltF = ft_preproc_bandpassfilter( Belt', 60, [0.001  0.3], 2 )';

Grip = cell2mat(DataStruct.TaskData.RR.Data(2:end-1,5));
Grip = Grip-mean(Grip);
Grip = Grip/(max(abs(Grip)));
% GripF = ft_preproc_lowpassfilter(Grip', 60, 0.3)';
GripF = ft_preproc_bandpassfilter( Grip', 60, [0.001  0.3], 2 )';

Capn = cell2mat(DataStruct.TaskData.RR.Data(2:end-1,6));
Capn = Capn-mean(Capn);
Capn = Capn/(max(abs(Capn)));
% CapnF = ft_preproc_lowpassfilter(Capn', 60, 0.3)';
CapnF = ft_preproc_bandpassfilter( Capn', 60, [0.001  0.3], 2 )';


U(1).u = BeltF;
% U(1).u = Belt;
U(1).uu = Belt;
U(1).name = {'Belt'};

U(2).u = GripF;
% U(2).u = Grip;
U(2).uu = Grip;
U(2).name = {'Grip'};

U(3).u = CapnF;
% U(3).u = Capn;
U(3).uu = Capn;
U(3).name = {'Capn'};

X = spm_Volterra(U, xBF.bf, 1); % convolution

vol_idx  = cell2mat(DataStruct.TaskData.KL.KbEvents{1,2}(:,2)) == 1;
k = length(vol_time);
% X = X((0:(k - 1))*fMRI_T + fMRI_T0 + 32,:); % resample
X_reg = X( round((0:(k - 1))*60*TR)+1 ,:); % resample
% X_reg = downsample(X,round(60*TR));
% X_reg = X_reg(1:k,:);

for i = 1 : 3
    figure
    hold on
    plot(Time,U(i).uu,'black')
    plot(Time,U(i).u,'blue')
    plot(Time,X(:,i),'magenta')
    plot(vol_time,X_reg(:,i),'red')
end


%% Curves

% clear Belt Grip Capn
%
% Time  = cell2mat(DataStruct.TaskData.RR.Data(2:end-1,2))';
%
% Belt.raw = cell2mat(DataStruct.TaskData.RR.Data(2:end-1,4))'; Belt.raw = Belt.raw-mean(Belt.raw);
% Grip.raw = cell2mat(DataStruct.TaskData.RR.Data(2:end-1,5))'; Grip.raw = Grip.raw-mean(Grip.raw);
% Capn.raw = cell2mat(DataStruct.TaskData.RR.Data(2:end-1,6))'; Capn.raw = Capn.raw-mean(Capn.raw);
%
% Belt.filt = ft_preproc_bandpassfilter( Belt.raw, 60, [0.001  3], 2 );
% Grip.filt = ft_preproc_bandpassfilter( Grip.raw, 60, [0.001  3], 2 );
% Capn.filt = ft_preproc_bandpassfilter( Capn.raw, 60, [0.001  3], 2 );
%
% Belt.filt = Belt.filt + sign(min(Belt.filt))*min(Belt.filt);
% Grip.filt = Grip.filt + sign(min(Grip.filt))*min(Grip.filt);
% Capn.filt = Capn.filt + sign(min(Capn.filt))*min(Capn.filt);
%
%
% %% volume time to eletrophy time
%
% Belt.reg = zeros(length(vol_time),1);
% Grip.reg = Belt.reg;
% Capn.reg = Belt.reg;
%
% for v = 1 : length(vol_time)
%
%     [vol_Time(v),IDX_vol_Time(v)] = min(abs(vol_time(v) - Time));
%     idx = IDX_vol_Time(v);
%     if v > 1
%     Belt.reg(v) = trapz( Time(idx-1:idx) , Belt.filt(idx-1:idx) );
%     Grip.reg(v) = trapz( Time(idx-1:idx) , Grip.filt(idx-1:idx) );
%     Capn.reg(v) = trapz( Time(idx-1:idx) , Capn.filt(idx-1:idx) );
%     end
%
% end % volume
%
% Belt.reg = Belt.reg/(max(abs(Belt.reg))) * max(abs(Belt.filt));
% Grip.reg = Grip.reg/(max(abs(Grip.reg))) * max(abs(Grip.filt));
% Capn.reg = Capn.reg/(max(abs(Capn.reg))) * max(abs(Capn.filt));
%
% figure
% hold on
% plot(Time    ,Belt.raw,'red')
% plot(Time    ,Belt.filt,'magenta')
% plot(vol_time,Belt.reg,'blue')
%
% figure
% hold on
% plot(Time    ,Grip.raw,'red')
% plot(Time    ,Grip.filt,'magenta')
% plot(vol_time,Grip.reg)
%
% figure
% hold on
% plot(Time    ,Capn.raw,'red')
% plot(Time    ,Capn.filt,'magenta')
% plot(vol_time,Capn.reg,'blue')
