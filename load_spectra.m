function spectra = load_spectra(export_dir)
    dir_spectra = dir([export_dir,'/spectra']);
    max_num = -1;
    for i = 1:length(dir_spectra)
        if dir_spectra(i).name(1) == '.'
            continue;
        end
        num = str2num(dir_spectra(i).name);
        if num > max_num
            max_num = num;
        end
    end
    spectra = cell(1,max_num);
    parfor i = 1:max_num    
        spectra{i} = json2mat([export_dir,'/spectra/',num2str(i)],'tag');    
    end
end