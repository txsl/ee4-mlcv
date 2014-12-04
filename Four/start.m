clear all; close all;

load face;

IM_WIDTH = 46;
IM_HEIGHT = 56;

[ distrib, bin_num ] = histc(l, unique(l));

for i=1:size(X,2)
    figure
    title(l(i))
    im_c = reshape(uint8(X(:,i)), [ IM_HEIGHT IM_WIDTH ]);
    imshow(im_c)
end