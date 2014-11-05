

ORIG_IMG = 'albert_hall.jpg';

im_data = imread(ORIG_IMG, 'JPEG');
[height, width, rgb] = size(im_data);

%% Part one
reshaped_im_data = double(reshape(im_data, width*height, 3));

% K = [3, 10, 20];
K = [3];


for i = K
    res = cmeans(reshaped_im_data, i);
    km(:,:,1) = reshape(res.X(:,1), height, width);
    km(:,:,2) = reshape(res.X(:,2), height, width);
    km(:,:,3) = reshape(res.X(:,3), height, width);
end
