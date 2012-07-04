function test_data = convert_to_correlation(spectra,test_collection,bin_boundaries)
% dir_spectra = dir([export_dir,'/spectra']);
% dir_spectra = dir_spectra(3:end);

% Now for the test samples
test_data = zeros(length(spectra),size(test_collection.Y,2));

for i = 1:length(spectra)
    spectrum = spectra{i};    
        
    % Compute the bin indexes
    bin_inxs = [];
    for b = 1:size(bin_boundaries,1)
        left = bin_boundaries(b,1);
        right = bin_boundaries(b,2);
        bin_inxs = [bin_inxs,find(left >= spectrum.x & spectrum.x >= right)];
    end
    bin_inxs = unique(bin_inxs);
    
    test_bin_inxs = [];
    for b = 1:size(bin_boundaries,1)
        left = bin_boundaries(b,1);
        right = bin_boundaries(b,2);
        test_bin_inxs = [test_bin_inxs,find(left >= test_collection.x & test_collection.x >= right)];
    end
    test_bin_inxs = unique(test_bin_inxs);
    
    xwidth = spectrum.x(1) - spectrum.x(2);
    xi = spectrum.x(bin_inxs);
    
    dt = zeros(1,size(test_collection.Y,2));
    for j = 1:size(test_collection.Y,2)
        y1 = interp1(spectrum.x(bin_inxs),spectrum.y(bin_inxs),xi,'linear',0);
        y2 = interp1(test_collection.x(test_bin_inxs),test_collection.Y(test_bin_inxs,j),xi,'linear',0);
        dt(j) = corr(y1',y2');
    end
    test_data(i,:) = dt;
end
test_data = test_data';