clc
clear
fclose('all');

filename = '/export/dataCENIR/dicom/nifti_raw/PRISMA_STIMPNEE/2016_05_13_STIMPNEE_Temoin01_V5_S2/S07_MBep2d_diff_175iso_B2k_d60/dic_param_f66_S07_MBep2d_diff_175iso_B2k_d60.json';

time_new_method_function = 1;
time_new_method = 1;
time_json = 0;


%% In a function

if time_new_method_function 
    fprintf('\n\n *** In a function *** \n\n')
    tic
    
    field_to_get={
        'SeriesNumber'
        'CsaSeries.MrPhoenixProtocol.sSliceArray.asSlice\[0\].dInPlaneRot'
        'InPlanePhaseEncodingDirection'
        'CsaImage.PhaseEncodingDirectionPositive'
        'CsaImage.BandwidthPerPixelPhaseEncode'
        };
    
    field_type={
        'double'
        'double'
        'char'
        'double'
        'double'
    };
    [ out ] = get_string_from_json( filename , field_to_get , field_type );
    out{:}
    
    toc
end


%% New method : low-levl I/O

if time_new_method
    fprintf('\n\n *** New method : low-levl I/O *** \n\n')
    tic
    
    fid = fopen(filename, 'r');
    content = fread(fid, '*char')';
    fclose('all');
    
    token = regexp(content,'"SeriesNumber": (\d+),','tokens');
    SeriesNumber = str2double( token{:} )
    
    token = regexp(content,'"CsaSeries.MrPhoenixProtocol.sSliceArray.asSlice\[0\].dInPlaneRot": (([-e.]|\d+)+),','tokens'); % celui-ci est relou : 2.051034897e-10
    if ~isempty(token)
        dInPlaneRot = str2double( token{:} )
    else
        dInPlaneRot = 0
    end
    
    token = regexp(content,'"InPlanePhaseEncodingDirection": "(\w+)", ','tokens');
    InPlanePhaseEncodingDirection = token{:}
    
    token = regexp(content,'"CsaImage.PhaseEncodingDirectionPositive": (\w+),','tokens');
    PhaseEncodingDirectionPositive = str2double( token{:} )
    
    token = regexp(content,'"CsaImage.BandwidthPerPixelPhaseEncode": (([-e.]|\d)+),','tokens');
    BandwidthPerPixelPhaseEncode = str2double( token{:} )
    
    toc
end


%% Old method : loadjson (JSONLab)

if time_json
    fprintf('\n\n *** Old method : loadjson (JSONLab) *** \n\n')
    tic
    
    fprintf('Start loadjson(filename) ...\n')
    j = loadjson(filename);
    fprintf('                   ... Done \n')
    
    hsession = j.global.const.SeriesNumber;
    if isfield(j.global.const,'sSliceArray_asSlice_0__dInPlaneRot')
        phase_angle =j.global.const.sSliceArray_asSlice_0__dInPlaneRot
    else
        phase_angle = 0
    end
    phase_dir = j.global.const.InPlanePhaseEncodingDirection
    phase_sign = j.global.const.PhaseEncodingDirectionPositive
    hz =  j.global.const.BandwidthPerPixelPhaseEncode
    
    
    toc % 39 secondes sur mon poste
end

