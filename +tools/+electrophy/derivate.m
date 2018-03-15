function [ X_filtered_derivate ] = derivate( X_filtered, freq )

X_filtered_derivate = [ zeros(1,size(X_filtered,2)); diff(X_filtered, 1, 1)] * freq;

end
