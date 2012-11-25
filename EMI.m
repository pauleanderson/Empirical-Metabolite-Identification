function res = EMI(input_file,output_file)

spectra = dataset('File',input_file,'ReadVarNames',false);
x = double(spectra(:,1));
y = double(spectra(:,2));

model = GABayesClassifier();

res = 0;