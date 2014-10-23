
ORIG_IMG = 'cat.jpg';

% Part one

% We can use imshow() directly, or load the data and 
% imshow(ORIG_IMG)
im_data = imread(ORIG_IMG, 'JPEG');

% dims = size(im_data);

image(im_data)
axis image


figure

subplot(2,1,1);

im_data_r = im_data;
im_data_r(:,:,2) = 0;
im_data_r(:,:,3) = 0;

image(im_data_r)
axis image
imwrite(im_data_r, 'cat_r.jpg')

subplot(2,1,2);

im_data_b = im_data;
im_data_b(:,:,1) = 0;
im_data_b(:,:,2) = 0;

image(im_data_b)
axis image
imwrite(im_data_r, 'cat_b.jpg')

