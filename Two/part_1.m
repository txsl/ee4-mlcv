

ORIG_IMG = 'albert_hall.jpg';

im_data = imread(ORIG_IMG, 'JPEG');
[height, width, rgb] = size(im_data);

%% 1
reshaped_im_data = double(reshape(im_data, width*height, 3));

K = [3, 10, 20];


for i = K
    [model, res.y] = cmeans(reshaped_im_data', i);

    output = model.X(:, res.y);
    
    output = uint8(reshape_cmeans_to_im(output, height, width));
    
    figure;
    imshow(output);
    
    imwrite(output, sprintf('%d-clusters-kmeans-full-img.jpeg', i));
end

%% 2

im_grey = uint8(mean(im_data, 3));

NUM_RANDOMS = 100;
OUTPUT_DIM = 20;

uniform_squares = cell(NUM_RANDOMS,1);
im_combined = uint8(zeros(OUTPUT_DIM^2, NUM_RANDOMS));

i = 1;
while i<=NUM_RANDOMS,
    square = round(rand*width);
    xstart = round(rand*width);
    ystart = round(rand*height);
    if xstart + square > width || ystart + square > height
        continue
    else
        square = imcrop(im_grey, [xstart, ystart square square]);
        uniform_squares{i} = imresize(square, [OUTPUT_DIM OUTPUT_DIM]);
        im_combined(:,i) = uniform_squares{i}(:);
        i = i + 1;
    end
end




