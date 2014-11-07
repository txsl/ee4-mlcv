function [ im_combined ] = generate_patches_cv( image, num_random, output_dims )
%GENERATE_PATCHES Returns random vector column of given image
%   Detailed explanation goes here

[height, width, ~] = size(image);

patches = cell(num_random,1);
im_combined = uint8(zeros(output_dims^2, num_random));



i = 1;
while i<=num_random,
    square = round(rand*width);
    xstart = round(rand*width);
    ystart = round(rand*height);
    if xstart + square > width || ystart + square > height
        continue
    else
        square = imcrop(image, [xstart, ystart square square]);
        patches{i} = imresize(square, [output_dims output_dims]);
        im_combined(:,i) = patches{i}(:);
        i = i + 1;
    end
end

end

