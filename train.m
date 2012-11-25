%% Load the training data
ds_name = '40m 5-15-2012';
prefix = './';
load([prefix,'samples ',ds_name,'.mat']);

%% Create a classifier for each metabolite in the samples
classifiers = {};
metabolite_names = {}; % An index for the names
xwidth = 0.04;
for s = 1:length(samples)
    sample = samples{s};
    for m = 1:length(sample.metabolite_names)
        mname = sample.metabolite_names{m};
        if ~isempty(find(strcmp(mname,metabolite_names)))
            ix = find(strcmp(mname,metabolite_names));
        else
            % We could consider optimizing the metabolite boundaries, etc
            met = Metabolite;
            met.mname = mname;
            met.locations = sample.locations{m};            
            met.ranges = zeros(0,2);
            for p = 1:length(sample.locations{m})
                for r = 1:length(sample.locations{m}{p})
                    met.ranges(end+1,[1,2]) = [sample.locations{m}{p}(r) + xwidth/2, sample.locations{m}{p}(r) - xwidth/2];                
                end
            end
            
            classifiers{end+1} = GABayesClassifier(met);
            metabolite_names{end+1} = mname;
        end
    end
end

%% Now we need to train each classifier
% Construct the Y matrix, which is the same for each classifier
Y = [];
for s = 1:length(samples)
    Y(end+1,:) = samples{s}.y';
end

% Now loop through each classifier and perform the training
fitness = [];
for c = 1%:length(classifiers)
    % Create the labels array
    labels = {};
    for s = 1:length(samples)
        if isempty(find(strcmp(classifiers{c}.met.mname,samples{s}.metabolite_names)))
            labels{end+1} = 'Does not contain';
        else
            labels{end+1} = classifiers{c}.met.mname;
        end
    end
    
    myfitness = @(POP) (fitness1(POP,samples{1}.x',Y,labels,'holdout',0.5,classifiers{c}));
    opt = gaoptimset('Vectorized','off','PopulationType','bitstring',...
        'PlotFcns',{@gaplotbestf,@gaplotbestindiv,@gaplotexpectation,@gaplotstopping});            
    [X,FVAL]   =  ga(myfitness,length(labels),[],[],[],[],[],[],[],opt);
    
%     classifiers{c}.mask = ones(1,length(labels));
%     fitness(c) = classifiers{c}.train(samples{1}.x',Y,labels,'holdout',0.5);
end