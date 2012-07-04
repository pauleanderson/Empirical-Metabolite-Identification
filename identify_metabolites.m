% Identify metabolites
matlabpool 4

training_dataset = questdlg('What dataset would you like to use?','Dataset Question','25m','40m','25m');

target_dataset = load_collection;

spectra = load_spectra(training_dataset);

% Now calculate the probabilities
dir_models = dir([training_dataset,'/models']);
dir_models = dir_models(3:end);
probabilities = {};
for i = 1:length(dir_models)    
    model = json2mat([training_dataset,'/models/',dir_models(i).name],'tag');    
    probabilities{i} = {};
    probabilities{i}.mname = model.mname;
    probabilities{i}.bin_boundaries = model.bin_boundaries;
    corr_vector = convert_to_correlation(spectra,target_dataset,model.bin_boundaries);
    probabilities{i}.corr_vector = corr_vector;    
    probabilities{i}.dataset = training_dataset;

    nb = NaiveBayes.fit(model.corr_data,model.labels);
    final_post = nb.posterior(corr_vector);
    cinx = find(strcmp(nb.ClassLevels(),model.mname)); % this is only class that matters
    probabilities{i}.posterior = final_post(:,cinx);
end

% Now output in a formatted table
fid = fopen('summary.csv','w');
fprintf(fid,'Metabolite,Max,Min,Avg,Median,Dataset\n');
for i = 1:length(probabilities)
    fprintf(fid,'%s,%f,%f,%f,%f,%s\n',probabilities{i}.mname,...
        max(probabilities{i}.posterior),...
        min(probabilities{i}.posterior),...
        mean(probabilities{i}.posterior),...
        median(probabilities{i}.posterior),...
        probabilities{i}.dataset);
end
fclose(fid);

save('probabilities');