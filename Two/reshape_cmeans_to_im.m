function [ output ] = reshape_cmeans_to_im( input, height, width )
%RESHAPE_ Summary of this function goes here
%   Detailed explanation goes here
    output = zeros(height, width, 3);
    
    output(:,:,1) = reshape(input(1,:), height, width);
    output(:,:,2) = reshape(input(2,:), height, width);
    output(:,:,3) = reshape(input(3,:), height, width);

end

