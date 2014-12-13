clear all; close all;

load face;

IM_WIDTH = 46;
IM_HEIGHT = 56;
IMS_PER_FACE = 10;

num_faces = size(unique(l), 2);

% [ distrib, ~ ] = histc(l, num_faces);

% for i=1:size(X,2)
%     figure
%     title(l(i))
%     im_c = reshape(uint8(X(:,i)), [ IM_HEIGHT IM_WIDTH ]);
%     imshow(im_c)
%     pause
% end


%% Q2

te = cell(num_faces, 1);
tr = te;

all_tr = [];
for i=1:num_faces
    tr{i} = X(:,(10*(i-1))+1:(10*(i-1))+8);
    te{i} = X(:,(10*(i-1))+9:(10*(i-1))+10);
    all_tr = [ all_tr tr{i} ];
end


%% Q3

% diff = cell(num_faces, 1);
% A = diff;
% for i=1:num_faces
%     diff{i} = tr{i} - repmat(mean(tr{i}, 2), 1, 8);
%     A{i} = cell(8,1);
%     for j=1:8
%         A{i}{j} = diff{i}(:,j) * diff{i}(:,j)';
%         [v, e] = eig(A{i}{j});
%     end
% end

% cov(all_tr')  % Since each column is an observation, and each row is a variable, and each column an observation
mean_tr = mean(all_tr, 2);
A = all_tr - repmat(mean_tr, 1, size(all_tr, 2));

cov_big = A * A';
[ eigvecs_big, eigvals_big] = eig(cov_big, 'vector');
[ ~, I_big] = sort(eigvals_big, 'descend');

pca_big = zeros(IM_WIDTH*IM_HEIGHT, 50);
for i=1:50
    idx = I_big(i);
    pca_big(:,i) = eigvecs_big(:,idx);
end

%% Q4

im_c = reshape(uint8(mean_tr), [ IM_HEIGHT IM_WIDTH ]);
figure
imshow(im_c)

for i=1:50
    figure;
%     idx = I_big(i);
%     eigval = eigvals_big(idx);
%     reconstruct = (pca_big(:,i) * eigval) + mean_big;
%     im_c = reshape(uint8(reconstruct), [ IM_HEIGHT IM_WIDTH ]);
    imagesc(reshape(pca_big(:,i), [ IM_HEIGHT IM_WIDTH ]));
    colormap gray
end


%% Q5

cov_small = A' * A;
[ eigvecs_small, eigvals_small] = eig(cov_small, 'vector');
vecs = A * eigvecs_small;

[ ~, I_small] = sort(eigvals_small, 'descend');

pca_small = zeros(IM_WIDTH*IM_HEIGHT, 50);

for i=1:50
    idx = I_small(i);
    pca_small(:,i) = vecs(:,idx);
end


%% Q6

for i=1:50
    figure;
    imagesc(reshape(pca_small(:,i), [ IM_HEIGHT IM_WIDTH ]));
    colormap gray
end


%% Q8

im = X(:,254);
mean_im = im - mean(im);
Z = mean_im;

for i=[20,50]
    Z = pca_small(:,1:i)' * Z;
end



