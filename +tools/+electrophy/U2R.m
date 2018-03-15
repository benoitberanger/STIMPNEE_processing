function [ R, names ] = U2R( U, TR, freq, input_rp )

[ X ] = tools.electrophy.volterra_convolution( U, TR );

[ X_reg, volumes_in_dataset_int ] = tools.electrophy.resample_at_TR( X, TR, freq );

[ R, names ] = tools.electrophy.add_RP( input_rp, X_reg, U, volumes_in_dataset_int );

end % function
