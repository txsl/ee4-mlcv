

ORIG_IMG = 'albert_hall.jpg';

im_data = imread(ORIG_IMG, 'JPEG');
[height, width, rgb] = size(im_data);

%% Part one
reshaped_im_data = double(reshape(im_data, width*height, 3));

K = [3, 10, 20];


for i = K
    [model, res.y] = cmeans(reshaped_im_data', i);

    output = model.X(:, res.y);
    
    output = uint8(reshape_cmeans_to_im(output, height, width));
    
    figure;
    imshow(output);
    
    imwrite(output, sprintf('%d-clusers-kmeans-full-img.jpeg', i));
end
