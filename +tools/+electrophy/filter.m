function [ X_raw, X_filtered, Time, BlockData ] = filter( input, freq, Fbp )

S = load( input );


%% Volumes timestamp

%     vol_idx  = cell2mat(S.DataStruct.TaskData.KL.KbEvents{1,2}(:,2)) == 1;
%     vol_time = cell2mat(S.DataStruct.TaskData.KL.KbEvents{1,2}(vol_idx,1));

Time      = cell2mat(S.DataStruct.TaskData.RR.Data(2:end-1,2));

S.DataStruct.TaskData.ER.MakeBlocks;
BlockData = S.DataStruct.TaskData.ER.BlockData;
BlockData = BlockData(2:end-1,:);

%% Convonve HRF from SPM

Belt = cell2mat(S.DataStruct.TaskData.RR.Data(2:end-1,4));
Belt = Belt-mean(Belt);
Belt = Belt/(max(abs(Belt)));

Grip = cell2mat(S.DataStruct.TaskData.RR.Data(2:end-1,5));
Grip = Grip-mean(Grip);
Grip = Grip/(max(abs(Grip)));

% Capn = cell2mat(S.DataStruct.TaskData.RR.Data(2:end-1,6));
% Capn = Capn-mean(Capn);
% Capn = Capn/(max(abs(Capn)));

% X_raw = [Belt, Grip, Capn];
X_raw = [Belt, Grip];

if isnumeric(Fbp)
    X_filtered = ft_preproc_bandpassfilter( X_raw', freq, Fbp, 2 )';
elseif iscell(Fbp)
    X_filtered = [ft_preproc_bandpassfilter( X_raw(:,1)', freq, Fbp{1}, 2 )' ft_preproc_bandpassfilter( X_raw(:,2)', freq, Fbp{2}, 2 )'];
else
    error('Fbp')
end


end % function
