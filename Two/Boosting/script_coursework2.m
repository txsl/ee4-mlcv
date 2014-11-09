% Face detection by Adaboost algorithm.
% (C) 2014, Written by Tae-Kyun Kim
% <a href="http://www.iis.ee.ic.ac.uk/icvl/">Personal Webpage</a>

% Compile C files
setup;

% Training data collection
load ImgData_tr; ImgData = ImgData_tr; clear ImgData_tr;

% To give us access to the function generate_patches()
addpath('..')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% // Q. Data generation 
% // Face image patches are provided in ImgData.Pos. //
% //
% // Write your code here to collect non-face image patches//
% // and store them in ImgData.Neg. //
% //
% // Data structure
% // ImgData = struct('Pos',[],'Neg',[]);
% //    ImgData.Pos [24 x 24 x N], where N is the number of face samples
% //    ImgData.Neg [24 x 24 x M], where M is the number of non-face
% samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Loading images and generating patches
[~, ~, POS_SAMPLES] = size(ImgData.Pos);

NUM_NEGATIVES = POS_SAMPLES * 10;
IMG_SIZE = 24;

images = dir('negative_images/*');
images(1) = [];
images(1) = [];

[n, ~] = size(images);

PATCHES_PER_IMAGE = round((NUM_NEGATIVES/n)+0.5);
ImgData.Neg = zeros(IMG_SIZE, IMG_SIZE, PATCHES_PER_IMAGE*n);

for i=1:n
    im_data = imread(strcat('negative_images/', images(i).name), 'JPEG');
    im_data = uint8(mean(im_data, 3));

    ImgData.Neg(:,:, 1+((i-1)*PATCHES_PER_IMAGE):(i)*PATCHES_PER_IMAGE) = generate_patches(im_data, PATCHES_PER_IMAGE, IMG_SIZE);
end

ImgData.Neg = uint8(ImgData.Neg);

% Adaboost leanring
DataProcess; % prepare training data in the format
WeakLearnerList; % build the list of weak learners

options.max_rules = 20;
options.learner = 'trainweak_fast';

fprintf('AdaBoost learning\n');


% Learn Adaboost classifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% // Q. Modify the function AdaBoost_Haar //
model = AdaBoost_Haar(data,imgs,X,cl,options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
plot(model.Alpha)
title('\alpha value through boosting rounds');
ylabel('\alpha_m');
xlabel('Boosting Round (m)');

figure;
plot(model.Accuracy)
title('Training data accuracy through boosting rounds');
ylabel('Training data accuracy');
xlabel('Boosting Round(m)');


save model_adaboost model;




% Testing (classification)
load model_adaboost;
load ImgData_te; ImgData = ImgData_te; clear ImgData_te;

DataProcess; % prepare test data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% // Q. Write your code here to calculate the recognition accuracy (%) //
% // on the test data set //
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[y dfce] = feval(model.fun, imgs, X, model);
accuracy = length(find(data.y==y))/length(data.y);

fprintf('Accuracy when measured against test samples: %.2f%% \n', accuracy*100);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% // Q. Write your code here to draw ROC curve //
% // for the test data set //
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[tpr, fpr] = roc(dfce, data.y);

figure;
plot(tpr, fpr)
title('ROC based on test data');
ylabel('False Negatives');
xlabel('False Positives');


% Testing (face detection in images)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% // Q. Write your codes below to complete
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load model_adaboost;
pathname = './test_images/';
ff = dir([pathname, '*.jpg']); % Use the provided 5 test images.

num_weaklearners = size(model.rule,2);

% ...

% Input:
%   img [width x height] (uint8): an input image
%   weaklearners [7 x num_weaklearners]: weaklearners learnt (model.rule)
%   alphas [num_weaklearns x 1] : weaklearner weights learnt (model.Alpha)
% Output:
%   a [5 x num_faces_detected] : detected faces
%   a(2:5,:) : box coordinates containing the faces

% a = findface(img, weaklearners, alphas); % main detection function

for i=1:5
    img = imread(strcat(pathname, ff(i).name), 'JPEG');
    a = findface(img, cell2mat(model.rule), model.Alpha); % main detection function

    % compute the response map 
    rmap = zeros(size(img,1),size(img,2));
    for J=1:size(a, 2) 
        rmap(a(2,J):a(4,J),a(3,J):a(5,J)) = rmap(a(2,J):a(4,J),a(3,J):a(5,J)) + 1;
    end
    
    figure;
    subplot(1,2,1);
    imshow(img);
    
    subplot(1,2,2);
    imagesc(uint8(rmap));
    axis image;
    colormap hsv;
end
% ...



colormap hsv;




