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
    
    [ X_raw, X_filtered, Time, BlockData ] = tools.electrophy.filter( input, freq );
    [ X_filtered_derivate ]                = tools.electrophy.derivate( X_filtered, freq );
    
    
    %% Specifique part
    
    % Prepare container
    u_names = {'NULL', 'Eye', 'Respiration', 'Force' 'Diff_NULL', 'Diff_Eye', 'Diff_Respiration', 'Diff_Force'};
    U_Belt = struct;
    U_Grip = struct;
    for u_idx = 1 : length(u_names)
        U_Belt(u_idx).u    = zeros(size(Time));
        U_Belt(u_idx).raw  = zeros(size(Time));
        U_Belt(u_idx).name = {['Belt_' u_names{u_idx}]};
        
        U_Grip(u_idx).u    = zeros(size(Time));
        U_Grip(u_idx).raw  = zeros(size(Time));
        U_Grip(u_idx).name = {['Grip_' u_names{u_idx}]};
    end
    
    % Replace container with the signal
    for e = 1 : size(BlockData,1)
        
        start_block = find(BlockData{e,2} == Time);
        if e ~= size(BlockData,1)
            stop_block = find(BlockData{e+1,2} == Time);
        else
            stop_block = Time(end);
        end
        
        switch BlockData{e,1}
            case 'NULL'
                u_idx = 1;
            case 'Eye'
                u_idx = 2;
            case 'Respiration'
                u_idx = 3;
            case 'Force'
                u_idx = 4;
            otherwise
                error(' ')
        end
        
        U_Belt(u_idx).u  (start_block:stop_block,1)   = X_filtered(start_block:stop_block,1);
        U_Belt(u_idx).raw(start_block:stop_block,1)   = X_raw     (start_block:stop_block,1);
        U_Grip(u_idx).u  (start_block:stop_block,1)   = X_filtered(start_block:stop_block,2);
        U_Grip(u_idx).raw(start_block:stop_block,1)   = X_raw     (start_block:stop_block,2);
        
        U_Belt(u_idx+4).u  (start_block:stop_block,1) = X_filtered_derivate(start_block:stop_block,1);
        U_Belt(u_idx+4).raw(start_block:stop_block,1) = X_filtered         (start_block:stop_block,1);
        U_Grip(u_idx+4).u  (start_block:stop_block,1) = X_filtered_derivate(start_block:stop_block,2);
        U_Grip(u_idx+4).raw(start_block:stop_block,1) = X_filtered         (start_block:stop_block,2);
        
    end
    
    U_Grip = U_Grip([4 8]); % only keep Grip_Force & Grip_Diff_Force
    U = [U_Belt U_Grip];
    
    
    %% Generate regressors
    
    [ R, names, X, X_reg ] = tools.electrophy.U2R( U, TR, freq, input_rp );
    
    
    %% Save
    
    dit_to_save = get_parent_path( input );
    output = fullfile(dit_to_save, sprintf('R_ByCondition_%s.mat', input(end-4)) );
    
    fprintf('output : %s \n\n', output)
    
    save( output, 'R', 'names' )
    
    
    %% Plot
    
    %     figure
    %     plot(R)
    %
    %     for i = 1 : numel(U)
    %         figure('Name',U(i).name{1},'NumberTitle','off')
    %         hold on
    %         plot(Time,U(i).raw,'black')
    %         plot(Time,U(i).u,'blue')
    %         plot(Time,X(:,i),'magenta')
    %         plot((0:size(X_reg,1)-1)*TR,X_reg(:,i),'red')
    %     end
    
    
end % for each run
