

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

K = 3;
[model, res.y] = cmeans(double(im_combined), K);
figure;
for i=1:K
    im = reshape(model.X(:,i), 20, 20);
    subplot(1, K, i);
    imshow(uint8(im));
end

K = 20;
[model, res.y] = cmeans(double(im_combined), K);
figure;
for i=1:K
    im = reshape(model.X(:,i), 20, 20);
    subplot(4, K/4, i);
    imshow(uint8(im));
end


%% 3

K = 12;
[model, res.y] = cmeans_custom(double(im_combined), K);  % customised to export each trial output

figure;
for j=1:K
    subplot(K, 1, j)
    imshow(uint8(reshape(model.initial(:,j), OUTPUT_DIM, OUTPUT_DIM)))
end

iterations = model.t;
for i=1:iterations
    this_iteration = model.stages{i};
    figure;
    for j=1:K
        subplot(K, 1, j)
        imshow(uint8(reshape(this_iteration(:,j), OUTPUT_DIM, OUTPUT_DIM)))
    end
end

figure;
plot(model.MsErr);


%% 4

K = 12;
NUM_TRIALS = 4;

trials = cell(4,1);
for i=1:NUM_TRIALS
    trials{i} = cmeans_custom_save_initial(double(im_combined), K);
    
    % Print the original image before K means
    figure;
    for j=1:K
        subplot(K, 1, j)
        imshow(uint8(reshape(trials{i, 1}.initial(:,j), OUTPUT_DIM, OUTPUT_DIM)))
    end
    
    % And the output
    figure;
    for j=1:K
        subplot(K, 1, j)
        imshow(uint8(reshape(trials{i, 1}.X(:,j), OUTPUT_DIM, OUTPUT_DIM)))
    end
end

% Objective function plot
figure;
hold all
for i=1:NUM_TRIALS
    plot(trials{i}.MsErr);
end


%% 5 GMM

% The line below fails, because of the singularity problem
% output = emgmm(double(im_combined));

OUTPUT_DIM = 5;
patches = generate_patches(im_grey, 1000, OUTPUT_DIM);

options.ncomp = 4;
output = emgmm(double(patches), options);

figure;
for i=1:options.ncomp
    subplot(2, options.ncomp, i)
    imagesc(reshape(output.Mean(:,i), OUTPUT_DIM, OUTPUT_DIM))
    
    subplot(2, options.ncomp, i + options.ncomp)
    imagesc(output.Cov(:,:,i))
end
colormap('default')


%% 6 

% Try with diagonal covariance matrix
options.cov_type = 'diag';
output = emgmm(double(patches), options);

figure;
for i=1:options.ncomp
    subplot(2, options.ncomp, i)
    imagesc(reshape(output.Mean(:,i), OUTPUT_DIM, OUTPUT_DIM))
    
    subplot(2, options.ncomp, i + options.ncomp)
    imagesc(output.Cov(:,:,i))
end
colormap('default')


% Try with cmeans initialisation (and reset the covariance matrix)
options.cov_type = 'full';
options.init = 'cmeans';
output = emgmm(double(patches), options);

figure;
for i=1:options.ncomp
    subplot(2, options.ncomp, i)
    imagesc(reshape(output.Mean(:,i), OUTPUT_DIM, OUTPUT_DIM))
    
    subplot(2, options.ncomp, i + options.ncomp)
    imagesc(output.Cov(:,:,i))
end
colormap('default')



