
ORIG_IMG = 'albert_hall.jpg';

%% Part one

% We can use imshow() directly, or load the data and 
% imshow(ORIG_IMG)
im_data = imread(ORIG_IMG, 'JPEG');
[height, width, rgb] = size(im_data);

% Display the image, at correct proportions

imshow(im_data)

% New plot for 2.
% figure
% subplot(2,1,1);

im_data_r = im_data;
% Set all G and B values to 0
im_data_r(:,:,2) = 0;
im_data_r(:,:,3) = 0;

% imshow(im_data_r)
% image(im_data_r)
% axis image
imwrite(im_data_r, 'output_r.jpg')

% Now to set all R and G values to 0
% subplot(2,1,2);

im_data_b = im_data;
im_data_b(:,:,1) = 0;
im_data_b(:,:,2) = 0;

% imshow(im_data_b)
% image(im_data_b)
% axis image
imwrite(im_data_b, 'output_b.jpg')


% 3: convert to grayscale.
dims = size(im_data);
im_grey = uint8(mean(im_data, 3));
imwrite(im_grey, 'output_grey.jpg')
 
% figure;
% imshow(im_grey)


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
%         figure;
        squares{i} = imcrop(im_grey, [xstart, ystart square square]);
%         imshow(squares{i})
        filename = sprintf('sq_img_%d.jpg', i);
        imwrite(squares{i}, filename)
        i = i + 1;
    end
end


% 5: resizing and turning in to a column vector
OUTPUT_DIM = 20;

uniform_squares = cell(10,1);
im_combined = uint8(zeros(400, 10));
for i=1:10,
    [dim, ~] = size(squares{i});
    uniform_squares{i} = imresize(squares{i}, [OUTPUT_DIM OUTPUT_DIM]);
%     figure;
%     imshow(uniform_squares{i})
        
% The reshape function also works    
% 	im_combined(:,i) = uint8(reshape(uniform_squares{i}, 1, 400));

    im_combined(:,i) = uniform_squares{i}(:);
end

figure;
imagesc(im_combined)
colormap gray
imwrite(im_combined, 'im_combined_10.jpg')



%% Part 2
%1: 100 random squares
NUM_RANDOMS = 100;
OUTPUT_DIM = 20;

i = 1;
more_squares = cell(10,1);
while i<=NUM_RANDOMS,
    square = round(rand*width);
    xstart = round(rand*width);
    ystart = round(rand*height);
    if xstart + square > width || ystart + square > height
        continue
    else
%         figure;
        more_squares{i} = imcrop(im_grey, [xstart, ystart square square]);
%         imshow(more_squares{i})
%         filename = sprintf('sq_img_%d.jpg', i);
%         imwrite(more_squares{i}, filename)
        i = i + 1;
    end
end


more_uniform_squares = cell(NUM_RANDOMS,1);
larger_im_combined = uint8(zeros(400, NUM_RANDOMS));
for i=1:NUM_RANDOMS,
    [dim, ~] = size(more_squares{i});
    factor = OUTPUT_DIM/dim;
    more_uniform_squares{i} = imresize(more_squares{i}, [20 20]);
%     figure;
%     imshow(uniform_squares{i})
        
% The reshape function also works    
% 	im_combined(:,i) = uint8(reshape(uniform_squares{i}, 1, 400));

    larger_im_combined(:,i) = more_uniform_squares{i}(:);
end

figure;
imagesc(larger_im_combined)
colormap gray


% 2: mean vector and covariance matrix

% Mean:
mean_vector = uint8(sum(larger_im_combined, 2)/100);
matlab_mean = uint8(mean(larger_im_combined, 2));

if isequal(mean_vector, matlab_mean)
    disp('MATLAB function and manually calculated mean the same')
else
    disp('MATLAB function and manually calculated mean NOT the same')
end

mean_sq = reshape(mean_vector, [20 20]);
big_mean_sq = imresize(mean_sq, [400 400]);

matlab_mean_sq = reshape(matlab_mean, [20 20]);
big_matlab_mean_sq = imresize(matlab_mean_sq, [400 400]);


figure;
imagesc(mean_sq)
colormap gray

figure;
imagesc(matlab_mean_sq);
colormap gray

figure;
imagesc(big_mean_sq)
colormap gray

figure;
imagesc(big_matlab_mean_sq);
colormap gray

% Covariance Matrix:
mu = repmat(sum(larger_im_combined, 2)/100, [1 NUM_RANDOMS]);
diff = double(larger_im_combined) - mu;
covariance = 1/(NUM_RANDOMS-1).*diff*diff';

matlab_cov = cov(double(larger_im_combined'));


figure;
imagesc(covariance)
colormap gray

figure;
imagesc(matlab_cov);
colormap gray

