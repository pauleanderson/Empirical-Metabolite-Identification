function fitness = fitness1(POP,x,Y,labels,cvmethod,cvparam,classifier)
    % I'm using the same classifier, so if we parallelize this might cause
    % problems
    classifier.mask = POP;
    fitness = classifier.train(x,Y,labels,cvmethod,cvparam);
end