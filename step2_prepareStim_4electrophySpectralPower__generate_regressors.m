%% Init

clear
% close all
clc

% Fetch files and infos
[ TR, freq, stim_files_char, rp_files_char ] = tools.electrophy.prepare_extraction;


%%  Loop

for idx = 1 : size(stim_files_char,1)
    %% Prepare run data
    
    input    = deblank(stim_files_char(idx,:));
    input_rp = deblank(rp_files_char  (idx,:));
    
    fprintf('input : %s \n', input)
    
    [ X_raw, X_filtered, Time ] = tools.electrophy.filter( input, freq, {[0.1 0.4] [0.001 0.3]} );
    [ X_filtered_derivate ]     = tools.electrophy.derivate( X_filtered, freq );
    
    %% Specifique part
    
    %     s_filt_deriv = X_filtered(:,1);
    %     s_filt_abs_deriv = abs(s_filt_deriv);
    %
    %     nSammpesPerVolumes = floor(TR*freq);
    %     nVolumesInElectrophy = floor( length(s_filt_abs_deriv) / nSammpesPerVolumes );
    %
    %     AUC_nm = zeros(nVolumesInElectrophy,1);
    %     time = 1/freq:1/freq:TR;
    %     for vol = 1 : nVolumesInElectrophy
    %         if vol == 1
    %             AUC_nm(vol) = trapz(time(1:round(nSammpesPerVolumes/2)),s_filt_abs_deriv( (1:round(nSammpesPerVolumes/2)) + (vol-1)*nSammpesPerVolumes));
    %         else
    %             AUC_nm(vol) = trapz(time,s_filt_abs_deriv( (1:nSammpesPerVolumes)-round(nSammpesPerVolumes/2) + (vol-1)*nSammpesPerVolumes));
    % %             if vol == 2
    % %                 AUC(1) = AUC(2);
    % %             end
    %         end
    %     end
    %
    %     %     AUC_upsampled = interp(AUC_nm,round(freq*TR));
    %     %     AUC_upsampled(length(AUC_upsampled):size(X_raw,1)) = AUC_upsampled(end);
    %     AUC_upsampled = interp1( (0:nVolumesInElectrophy-1)*TR, AUC_nm' , (0:size(X_raw,1)-1)/freq, 'linear' )';
    
    signal = abs(X_filtered(:,1));
    
    window = floor(TR*freq); % == 1 TR
    %     window = freq;
    
    %     figure
    %     hold on
    
    %     O = [0 0.1 0.5  0.9 1]; % overlap
    O = 0.5; % overlap
    
    colors = jet(length(O));
    
    for o = 1 : length(O)
        
        overlap = O(o);
        
        ds = window -overlap*window;
        if ds == 0
            ds = 1;
        end
        
        IDX   =  1 : round(ds) : length(signal) ;
        power = nan(length(IDX),1);
        
        t = IDX/freq;
        
        for sample = 1 : length(IDX)
            realWindow = round(-window/2 : +window/2);
            realWindow(1) = [];
            realWindow = realWindow + IDX(sample) -1;
            realWindow = realWindow(realWindow>0);
            realWindow = realWindow(realWindow<length(signal));
            x = realWindow/freq;
            y = signal(realWindow);
            power(sample) = trapz(x, y);
        end
        
        %         plot(t,power,'DisplayName',num2str(O(o)),'Color',colors(o,:))
        
    end
    
    %     plot((1:length(signal))/freq,signal,'DisplayName','signal','Color','black')
    %     legend show
    
    power = interp1(t,power,(1:length(signal))/freq,'spline')'; % resmaple
    U(1).u    = power;
    %     U(1).u    = X_filtered(:,1);
    U(1).raw  = X_raw(:,1);
    U(1).name = {'Belt'};
    
    U(2).u    = X_filtered(:,2);
    U(2).raw  = X_raw     (:,2);
    U(2).name = {'Grip'};
    
    
    [ power_deriv ] = tools.electrophy.derivate( power, freq );
    %     U(3).u    = X_filtered_derivate(:,1);
    U(3).u    = power_deriv;
    U(3).raw  = power;
    U(3).name = {'Diff_Belt'};
    
    U(4).u    = X_filtered_derivate(:,2);
    U(4).raw  = X_filtered(:,2);
    U(4).name = {'Diff_Grip'};
    
    
    %% Generate regressors
    
    [ R, names, X, X_reg ] = tools.electrophy.U2R( U, TR, freq, input_rp );
    
    % Delete the RP : we need to add the personnal regressors as Regressor, not Multiple_Regressor
    R = R(:,1:end-6);
    names = names(1:end-6);
    
    
    %% Save
    
    dit_to_save = get_parent_path( input );
    output = fullfile(dit_to_save, sprintf('R_SpectralPower_%s.mat', input(end-4)) );
    
    fprintf('output : %s \n\n', output)
    
    save( output, 'R', 'names' )
    
    
    %% Plot
    
    %     figure
    %     plot(R)
    
    %     for sample = 1 : numel(U)
    %         figure('Name',U(sample).name{1},'NumberTitle','off')
    %         hold on
    %         plot(Time,U(sample).raw,'black')
    %         plot(Time,U(sample).u,'blue')
    %         plot(Time,X(:,sample),'magenta')
    %         plot((0:size(X_reg,1)-1)*TR,X_reg(:,sample),'red')
    %     end
    
    
end % for each run
