xwidth = 0.04; % Defines the area around the peak to consider xwidth/2 in either direction

[NUMERIC,TXT,RAW] = xlsread('datasets/peaks.csv');

all_names = {};
for i = 2:size(RAW,1)
    all_names{end+1} = RAW{i,1};
end
names = {};
for i = 2:size(RAW,1)
    names{end+1} = RAW{i,1};
end
locations = [];
for i = 2:size(RAW,1)
    locations(end+1) = RAW{i,2};
end
intensities = [];
for i = 2:size(RAW,1)
    intensities(end+1) = RAW{i,3};
end
locations = [];
for i = 2:size(RAW,1)
    locations(end+1) = RAW{i,2};
end
centers = [];
for i = 2:size(RAW,1)
    centers(end+1) = RAW{i,5};
end

names = unique(names);
name_inxs = {};
for i = 1:length(names)
    name_inxs{i} = find(strcmp(names{i},{RAW{2:end,1}}));
end

metabolites = {};
for name_inx = 1:length(names)
    % Need to make sure that all of the metabolite have a maximum
    % intensity of 1.0
    if max(intensities(name_inxs{name_inx})) ~= 1
        intensities(name_inxs{name_inx}) = intensities(name_inxs{name_inx})/max(intensities(name_inxs{name_inx}));
    end
    metabolites{name_inx}.locations = {};
    metabolites{name_inx}.intensities = {};
    metabolites{name_inx}.centers = unique(centers(name_inxs{name_inx}));
    metabolites{name_inx}.bin_boundaries = [];
    % Need to group these by center           
    for i = 1:length(metabolites{name_inx}.centers)
        center = metabolites{name_inx}.centers(i);
        ixs = find(centers == center & strcmp(all_names,names{name_inx}));
        metabolites{name_inx}.locations{end+1} = locations(ixs);
        metabolites{name_inx}.intensities{end+1} = intensities(ixs);
        for j = 1:length(ixs) % For each location make a bin
            loc = locations(ixs(j));
            left = loc + xwidth/2;
            right = loc - xwidth/2;
            metabolites{name_inx}.bin_boundaries = [metabolites{name_inx}.bin_boundaries;left right];
        end
    end
    metabolites{name_inx}.mname = names{name_inx};
end

% Output
for i = 1:length(metabolites)
    metabolite = metabolites{i};
    mat2json(metabolite,['datasets/metabolites/',metabolite.mname]);
end