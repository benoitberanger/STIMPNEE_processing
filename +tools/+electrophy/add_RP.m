function [ R, names ] = add_RP( input_rp, X_reg, U, volumes_in_dataset_int )

RP = load( input_rp );

% add 0 at the end for the remaining volumes without stim
if size(RP,1) - volumes_in_dataset_int > 0
    X_reg = [X_reg ; zeros( size(RP,1) - volumes_in_dataset_int ,4)];
elseif size(RP,1) - volumes_in_dataset_int < 0
    X_reg = X_reg(1:size(RP,1),:);
end

R = [X_reg RP];
names =  [ [U.name]  {'Tx', 'Ty', 'Tz',    'Rx', 'Ry', 'Rz'} ];

end % function
