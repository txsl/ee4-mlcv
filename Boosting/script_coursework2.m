% Face detection by Adaboost algorithm.
% (C) 2014, Written by Tae-Kyun Kim
% <a href="http://www.iis.ee.ic.ac.uk/icvl/">Personal Webpage</a>

% Compile C files
setup;

% Training data collection
load ImgData_tr; ImgData = ImgData_tr; clear ImgData_tr;


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


% Adaboost leanring
DataProcess; % prepare training data in the format
WeakLearnerList; % build the list of weak learners

options.max_rules = 1;
options.learner = 'trainweak_fast';

fprintf('AdaBoost learning\n');


% Learn Adaboost classifier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% // Q. Modify the function AdaBoost_Haar //
model = AdaBoost_Haar(data,imgs,X,cl,options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save model_adaboost model;




% Testing (classification)
load model_adaboost;
load ImgData_te; ImgData = ImgData_te; clear ImgData_te;

DataProcess; % prepare test data


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% // Q. Write your code here to calculate the recognition accuracy (%) //
% // on the test data set //
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% // Q. Write your code here to draw ROC curve //
% // for the test data set //
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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

a = findface(img, weaklearners, alphas); % main detection function


% compute the response map 
rmap = zeros(size(img,1),size(img,2));
for J=1:size(a, 2) 
    rmap(a(2,J):a(4,J),a(3,J):a(5,J)) = rmap(a(2,J):a(4,J),a(3,J):a(5,J)) + 1;
end

% ...








