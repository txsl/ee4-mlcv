 function model = AdaBoost_Haar(data,imgs,X,cl,options)

% data dimensions
dim = 24*24; num_data = size(X,2);

% initial data weights
data.D = ones(num_data,1)/num_data;

model.fun = 'vjadaclass';
model.Alpha = [];
model.Z = [];
model.WeightedErr = [];
model.ErrBound = [];
model.rule = [];

model.Accuracy = [];

t = 0;
go = 1;
while go,
    t = t + 1;
    tic;
    
    fprintf('rule %d: \n', t);
    
    % learn weak learner
    rule = feval(options.learner,imgs,X,data.y,cl,data.D');
    
    % evaluate by the weaklearner
    y = vj(rule, imgs, X);
    %y(find(curr_y>=0)) = 1;
    %y(find(curr_y<0)) = -1;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % // write your code here to compute the weighted error (werr)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ignore_trix = y ~= data.y;

    werr = (data.D' * ignore_trix')/sum(data.D);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % // write your code here to compute the alpha
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    alpha = log((1 - werr)/werr);          
    
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % // write your code here to update the weights
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    our_weights = data.D' .* exp(alpha*ignore_trix);
    
    
    % normalization constant
    Z = sum(our_weights);
    data.D = our_weights'/Z;  % Transpose the our_weights matrix to remain the same dimension as data.D
    
    % upper bound on the training error
    err_bound = prod(model.Z);
    
    % store variables
    model.Z = [model.Z; Z];
    model.Alpha = [model.Alpha;alpha];
    model.Alpha
    model.rule{t} = rule;
    model.ErrBound = [model.ErrBound; err_bound];

    toc
    
    
    % recognition accuracy on the training data 
    [y dfec] = feval(model.fun, imgs, X, model);
    length(find(data.y==y))/length(data.y)
    
    model.Accuracy = [model.Accuracy; length(find(data.y==y))/length(data.y)];
    
    
    % stopping conditions
    if t >= options.max_rules,
        go = 0;
    end
    model.WeightedErr = [model.WeightedErr; werr];
end
return;