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

cov(all_tr')  % Since each column is an observation, and each row is a variable, and each column an observation

