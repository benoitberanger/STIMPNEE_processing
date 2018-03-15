function [ X_reg, volumes_in_dataset_int ] = resample_at_TR( X, TR, freq )

volumes_in_dataset_float = size(X,1)/freq/TR;
volumes_in_dataset_int   = floor(volumes_in_dataset_float); % round toward 0
X_reg = X( round((0:(volumes_in_dataset_int - 1))*freq*TR)+1 ,:); % resample

end % function
