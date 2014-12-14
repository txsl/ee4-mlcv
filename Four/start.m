clear all; close all;

load face;

IM_WIDTH = 46;
IM_HEIGHT = 56;
IMS_PER_FACE = 10;

NUM_FACES = size(unique(l), 2);

% [ distrib, ~ ] = histc(l, NUM_FACES);

% for i=1:size(X,2)
%     figure
%     title(l(i))
%     im_c = reshape(uint8(X(:,i)), [ IM_HEIGHT IM_WIDTH ]);
%     imshow(im_c)
%     pause
% end


%% Q2

te = cell(NUM_FACES, 1);
tr = te;

all_tr = [];
for i=1:NUM_FACES
    tr{i} = X(:,(10*(i-1))+1:(10*(i-1))+8);
    te{i} = X(:,(10*(i-1))+9:(10*(i-1))+10);
    all_tr = [ all_tr tr{i} ];
end


%% Q3

% diff = cell(NUM_FACES, 1);
% A = diff;
% for i=1:NUM_FACES
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
vec_norms = normc(vecs);

[ ~, I_small] = sort(eigvals_small, 'descend');

pca_small = zeros(IM_WIDTH*IM_HEIGHT, 50);

for i=1:size(vecs, 2)
    idx = I_small(i);
    pca_small(:,i) = vec_norms(:,idx);  % vecs(:,idx)/
end


%% Q6

for i=1:50
    figure;
    imagesc(reshape(pca_small(:,i), [ IM_HEIGHT IM_WIDTH ]));
    colormap gray
end


%% Q8

close all;

im = X(:,254);
mean_im = im - mean_tr;

for i=[1,20,50,400]
    Z = pca_small(:,1:i)' * mean_im;
    recon = (pca_small(:,1:i) * Z) + mean_tr;
    figure
    showface(recon);
    colormap gray
    title(sprintf('%i components', i))
end


%% Q9

eigs = cell(NUM_FACES, 1);
mean_ims = eigs;

% Training
for i=1:NUM_FACES
    
    set = tr{i};
    mean_im = mean(set, 2);
    A = set - repmat(mean_im, 1, size(set, 2));

    cov_small = A' * A;
    [eigvecs_small, eigvals_small ] = eig(cov_small, 'vector');
    vecs = A * eigvecs_small;
    vec_norms = normc(vecs);

    [ ~, I_small] = sort(eigvals_small, 'descend');

    pca_small = zeros(IM_WIDTH*IM_HEIGHT, 50);

    for j=1:size(vecs, 2)
        idx = I_small(j);
        pca_small(:,j) = vec_norms(:,idx);
    end
    
    eigs{i} = pca_small;
    mean_ims{i} = mean_im;

end


% Testing
correct = 0;
total = 0;
for i=1:NUM_FACES   % For each set of faces with test data
    for j=1:2       % For each face in the test series (2 per face)
        dist = 999999999999999999999;
        for k=1:NUM_FACES  % For each of the training sets of face data
            face_to_test = te{i}(:,j);
            comps = eigs{k};
            
            mean_im = face_to_test - mean_ims{k};

            Z = comps' * mean_im;
            recon = (comps * Z) + mean_ims{k};
            
            new_dist = sum(diag(pdist2(recon, face_to_test)));
            norm_f = norm(recon - face_to_test);
            if new_dist < dist
%                 disp(sprintf('new closest match: %i', k))
                dist = new_dist;
                face_guess = k;
            end
        end
        fprintf('Closest face is %i. Correct is %i\n', face_guess, i);
        if face_guess == i
            correct = correct + 1;
        end
        total = total + 1;
    end
end


%% Q10

% Getting the subspace
mean_tr = mean(all_tr, 2);
A = all_tr - repmat(mean_tr, 1, size(all_tr, 2));

cov_small = A' * A;
[ eigvecs_small, eigvals_small] = eig(cov_small, 'vector');
vecs = A * eigvecs_small;
vec_norms = normc(vecs);

[ ~, I_small] = sort(eigvals_small, 'descend');

pca_small = zeros(IM_WIDTH*IM_HEIGHT, 50);

for i=1:size(vecs, 2)
    idx = I_small(i);
    pca_small(:,i) = vec_norms(:,idx); 
end

comps = pca_small;
mean_classes_recon = cell(NUM_FACES, 1);
all_face_recon = cell(NUM_FACES, 1);

% Getting reconstructions of both class means and each image
for i=1:NUM_FACES
    set = tr{i};
    mean_im = mean(set, 2);
    
    Z = comps' * (mean_im - mean_tr);
    mean_classes_recon{i} = (comps * Z) + mean_tr;
    
    all_face_recon{i} = zeros(2576,8);
    for k=1:8
        face_to_recon = set(:,k);
        
        Z = comps' * face_to_recon;
        face_recon = (comps * Z) + mean_tr;
        all_face_recon{i}(:,k) = face_recon; 
    end
end
