
ORIG_IMG = 'cat.jpg';

% Part one

% We can use imshow() directly, or load the data and 
% imshow(ORIG_IMG)
im_data = imread(ORIG_IMG, 'JPEG');
[height, width, rgb] = size(im_data);

% Display the image, at correct proportions

imshow(im_data)

% New plot for 2.
figure
subplot(2,1,1);

im_data_r = im_data;
% Set all G and B values to 0
im_data_r(:,:,2) = 0;
im_data_r(:,:,3) = 0;

imshow(im_data_r)
% image(im_data_r)
% axis image
imwrite(im_data_r, 'cat_r.jpg')

% Now to set all R and G values to 0
subplot(2,1,2);

im_data_b = im_data;
im_data_b(:,:,1) = 0;
im_data_b(:,:,2) = 0;

imshow(im_data_b)
% image(im_data_b)
% axis image
imwrite(im_data_r, 'cat_b.jpg')


% 3: convert to grayscale.
dims = size(im_data);
im_grey = uint8(mean(im_data, 3));

figure;
imshow(im_grey)


% 4: extracting 10 random square image patches
i = 1;
squares = cell(10,1);
while i<=10,
    square = round(rand*width);
    xstart = round(rand*width);
    ystart = round(rand*height);
    if xstart + square > width || ystart + square > height
        continue
    else
        figure;
        squares{i} = imcrop(im_grey, [xstart, ystart square square]);
        imshow(squares{i})
        filename = sprintf('sq_img_%d.jpg', i);
        imwrite(squares{i}, filename)
        i = i + 1;
    end
end


% 5: 
OUTPUT_DIM = 20;

uniform_squares = cell(10,1);
im_combined = uint8(zeros(400, 10));
for i=1:10,
    [dim, ~] = size(squares{i});
    factor = OUTPUT_DIM/dim;
    uniform_squares{i} = imresize(squares{i}, factor);
    figure;
    imshow(uniform_squares{i})
    
%     im_combined(:,i) = uint8(reshape(uniform_squares{i}, 1, 400));

    im_combined(:,i) = uniform_squares{i}(:);
end

figure;
imshow(im_combined)
