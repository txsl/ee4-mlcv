% Simple Random Forest Toolbox for Matlab
% by Mang Shao and Tae-Kyun Kim on Nov 16, 2014.

% This is a guideline script of simple-RF toolbox.
% The codes are made for educational purpose only.
% Some parts are inspired by Karpathy's RF Toolbox

% Under BSD Licence

% Initialisation
close all; clear all;
init;
addpath('../matlab2tikz')

% Set random forest parameters
param.num = 10;         % Number of trees
param.depth = 5;        % trees depth
param.splitNum = 3;     % Number of trials in split function
param.split = 'IG';     % Currently support 'information gain' only

% Select dataset
[data_train, data_test] = getData('Toy_Spiral'); % {'Toy_Gaussian', 'Toy_Spiral', 'Toy_Circle', 'Caltech'}

%%%%%%%%%%%%%
% check the training and testing data
    % data_train(:,1:2) : [num_data x dim] Training 2D vectors
    % data_train(:,3) : [num_data x 1] Label of training data, {1,2,3}
    
plot_toydata(data_train);

    % data_test(:,1:2) : [num_data x dim] Testing 2D vectors, 2D points in the
    % uniform dense grid within the range of [-1.5, 1.5]
    % data_train(:,3) : N/A
    
scatter(data_test(:,1),data_test(:,2),'.b');

%%%%%%%%%%%%%%%%%%%%%%
% Train Random Forest

%% Q1

% bagging : to create subsets of training data
[N,D] = size(data_train);
frac = 1 - 1/exp(1); % Bootstrap sampling fraction: 1 - 1/e (63.2%)
[labels,~] = unique(data_train(:,end));

% plot first 4 out of all data subsets
for T = 1:4
    idx = randsample(N, N, true); % index of a data subset for each tree is generated by random sampling from dataset WITH replacement.
    prior = histc(data_train(idx,end),labels)/length(idx);
    u_frac = size(unique(idx))/size(idx);
    disp(prior)
    subplot(2,2,T);
    plot_toydata(data_train(idx,:))
    title(sprintf('%2.2f%% Distinct Samples', u_frac*100));
end


%% Q2
keep idx D data_train data_test param labels prior;

% grow a trees by slitting a set of data
% here we grow the first trees out of (param.num) trees

T = 1; % the trees number 1

%%%%%%%%%%%%%%%%%%%%%%%%%
% Split Nodes

% Split the first node

% See function getE.m for details of entropy calculation

ig_best = -inf;
idx_size = size(idx, 1);
for n = 1:3
    dim = randi(D-1);                           % Pick one random dimension as a split function
    d_min = single(min(data_train(idx,dim)));   % Find the data range of this dimension
    d_max = single(max(data_train(idx,dim)));
    t = d_min + rand*((d_max-d_min));           % Pick a random value within the range as threshold
 
    idx_ = data_train(idx,dim) < t;            % idx_: index of data going to the left-child node by chosen dimension and threshold
    idx_r = ~idx_;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate information gain
    l_branch = data_train(idx_,:);
    r_branch = data_train(idx_r,:);
    
    ig = -((sum(idx_)/idx_size) * getE(l_branch)) - ((sum(idx_r)/idx_size) * getE(r_branch)); % information gain

    
    if ig_best < ig
        ig_best = ig;   % maximu information gain saved
        t_best = t;     % the best threhold to save
        dim_best = dim; % the best split function (dimension) to save
        idx_best = idx_;
    end
    
    % Visualise the split function and its information gain
    figure
    visualise_splitfunc(idx_,data_train(idx,:),dim,t,ig,0);
    drawnow;
end


% Visualise the best split function saved
figure
visualise_splitfunc(idx_best,data_train(idx,:),dim_best,t_best,ig_best,0);

disp('Shown some sample first node splits');
pause

%% Q4 

% Initialise base node
trees(T).node(1) = struct('idx',idx,'t',nan,'dim',-1,'prob',[]);
% Split the nodes recursively
for n = 1:2^(param.depth-1)-1
    [trees(T).node(n),trees(T).node(n*2),trees(T).node(n*2+1)] = splitNode(data_train,trees(T).node(n),param);
end

% Store class distributions in the leaf nodes
makeLeaf;
disp('Initialised base node and split them');
pause

%% Q5
% Visualise the class distributions of the first 9 leaf nodes
visualise_leaf
% close all;

% Grow all trees
trees = growTrees(data_train,param);
disp('Grown trees and visualised leaf');
pause
close all;


%% Q6
% testing
% grab the few data points and evaluate them one by one by the leant RF


test_point = [-.5 -.7; .4 .3; -.7 .4; .5 -.5];

figure(1)
plot_toydata(data_train);
plot(test_point(:,1), test_point(:,2), 's', 'MarkerSize',20, 'MarkerFaceColor', [.9 .9 .9], 'MarkerEdgeColor','k');

for n=1:4
    figure(2)
    subplot(1,2,1)
    plot_toydata(data_train);
    subplot(1,2,2)
    leaves = testTrees([test_point(n,:) 0],trees);
    
    % average the class distributions of leaf nodes of all trees
    p_rf = trees(1).prob(leaves,:);
    p_rf_sum = sum(p_rf)/length(trees);
    
    % visualise the class distributions of the leaf noes which the data
    % point arrives at
    for L = 1:size(leaves,2)
        subplot(3,5,L); bar(p_rf(L,:)); axis([0.5 3.5 0 1]);
    end
    subplot(3,5,L+3); bar(p_rf_sum); axis([0.5 3.5 0 1]);
    
    figure(1);
    hold on;
    plot(test_point(n,1), test_point(n,2), 's', 'MarkerSize',20, 'MarkerFaceColor', p_rf_sum, 'MarkerEdgeColor','k');
    pause;
    disp('In plot loop for testing and evaluating different points');
end
hold off;
close all;

%% Q7
% Test on the dense data by RF
leaves = testTrees_fast(data_test,trees);

for T = 1:length(trees)
    p_rf_all(:,:,T) = trees(1).prob(leaves(:,T),:);
end

p_rf_all = squeeze(sum(p_rf_all,3))/length(trees);

% Visualise
visualise(data_train,p_rf_all,[],0);


%%

% Test on the dense data by SVM, compare with the RF result
disp('Training SVM...');
model_svm = svmtrain(data_train(:,end),data_train(:,1:end-1),'-t 2 -b 1 -c 10');

% Test SVM
disp('Testing SVM...');
[p_svm, accuracy_svm, p_svm_prob] = svmpredict(data_test(:,end), data_test(:,1:end-1), model_svm, '-b 1');

% Visualise
visualise(data_train,p_rf_all,p_svm_prob,1);




% try different parameter values and see the effects



% Set random forest parameters
% change the number of trees
for N = [1,3,5,10,20]; % Number of trees, try {1,3,5,10, or 20}
    init;
    param.num = N;
    param.depth = 5;    % trees depth
    param.splitNum = 3; % Number of trials in split function
    param.split = 'IG'; % Currently support 'information gain' only
    
    % Select dataset
    [data_train, data_test] = getData('Toy_Spiral'); % {'Toy_Gaussian', 'Toy_Spiral', 'Toy_Circle', 'Caltech'}
    
    % Train Random Forest
    trees = growTrees(data_train,param);
    
    % Test Random Forest
    testTrees_script;
    
    % Visualise
    visualise(data_train,p_rf,[],0);
    
    pause;
end

% change the tree depth
for N = [2,5,7,11]; % Number of trees, try {2,5,7,11}
    init;
    param.num = 20;
    param.depth = N;    % trees depth
    param.splitNum = 3; % Number of trials in split function
    param.split = 'IG'; % Currently support 'information gain' only
    
    % Select dataset
    [data_train, data_test] = getData('Toy_Spiral'); % {'Toy_Gaussian', 'Toy_Spiral', 'Toy_Circle', 'Caltech'}
    
    % Train Random Forest
    trees = growTrees(data_train,param);
    
    % Test Random Forest
    testTrees_script;
    
    % Visualise
    visualise(data_train,p_rf,[],0);
    
    pause;
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% experiment with Caltech101 dataset for image categorisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init;
param.num = 10;
param.depth = 10;    % trees depth
param.splitNum = 3; % Number of trials in split function
param.split = 'IG'; % Currently support 'information gain' only

% Select dataset
[data_train, data_test] = getData('Caltech');
close all;

% we do bag-of-words technique to convert images to vectors (histogram of codewords)

% Set 'showImg' in getData.m to 0 to stop displaying training and testing images and their feature vectors.


% Train Random Forest
trees = growTrees(data_train,param);

% Test Random Forest
testTrees_script;

% show accuracy and confusion matrix
confus_script;