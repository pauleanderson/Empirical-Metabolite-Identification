function varargout = identify(varargin)
% IDENTIFY MATLAB code for identify.fig
%      IDENTIFY, by itself, creates a new IDENTIFY or raises the existing
%      singleton*.
%
%      H = IDENTIFY returns the handle to a new IDENTIFY or the handle to
%      the existing singleton*.
%
%      IDENTIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IDENTIFY.M with the given input arguments.
%
%      IDENTIFY('Property','Value',...) creates a new IDENTIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before identify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to identify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help identify

% Last Modified by GUIDE v2.5 02-Jul-2012 22:17:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @identify_OpeningFcn, ...
                   'gui_OutputFcn',  @identify_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before identify is made visible.
function identify_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to identify (see VARARGIN)

% Choose default command line output for identify
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes identify wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = identify_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_collection_pushbutton.
function load_collection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_collection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.collection = load_collection;

column_names = {'Prob',handles.collection.input_names{:},'Index'};    
set(handles.spectra_uitable,'ColumnName',column_names);
set(handles.ssort_listbox,'String',column_names);

data = cell(size(handles.collection.Y,2),length(column_names));
for i = 1:length(handles.collection.formatted_input_names)
    ix = i + 1;
    field = handles.collection.formatted_input_names{i};
    if iscell(handles.collection.(field)) || (ismatrix(handles.collection.(field)) && length(handles.collection.(field)) == size(handles.collection.Y,2))
        for j = 1:size(handles.collection.Y,2)
            if iscell(handles.collection.(field))
                data{j,ix} = handles.collection.(field){j};
            else
                data{j,ix} = handles.collection.(field)(j);
            end
        end        
    else        
        for j = 1:size(handles.collection.Y,2)
            data{j,ix} = handles.collection.(field);
        end        
    end
end
for j = 1:size(handles.collection.Y,2)
    data{j,end} = j;
end

if isfield(handles,'probabilities') && isfield(handles,'mindex')
    for j = 1:size(handles.collection.Y,2)
        data{j,1} = handles.probabilities{handles.mindex}.posterior(j);
    end 
end

data = sortrows(data,2);
set(handles.spectra_uitable,'data',data);

guidata(hObject, handles);

% --- Executes on button press in load_probabilities_pushbutton.
function load_probabilities_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_probabilities_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.mat', 'Pick a probabilities file');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel');
   return;
end

load([pathname,filename],'probabilities');
handles.probabilities = probabilities;

column_names = {'Name','Max','Min','Avg','Median','Dataset','Index'};
set(handles.msort_listbox,'String',column_names);

set(handles.metabolites_uitable,'ColumnName',column_names);
data = {};
for i = 1:length(handles.probabilities)
    data{i,1} = probabilities{i}.mname;
    data{i,2} = max(probabilities{i}.posterior);
    data{i,3} = min(probabilities{i}.posterior);
    data{i,4} = mean(probabilities{i}.posterior);
    data{i,5} = median(probabilities{i}.posterior);
    data{i,6} = probabilities{i}.dataset;
    data{i,7} = i;
end
data = sortrows(data,1);
set(handles.metabolites_uitable,'Data',data);
if isfield(handles,'mindex');
    handles = rmfield(handles,'mindex');
end

guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in metabolites_uitable.
function metabolites_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to metabolites_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.metabolites_uitable,'data');
i = eventdata.Indices(1,1);
handles.mindex = data{i,end};

data = get(handles.spectra_uitable,'data');
if isfield(handles,'probabilities') && isfield(handles,'mindex')
    for j = 1:size(handles.collection.Y,2)
        data{j,1} = handles.probabilities{handles.mindex}.posterior(data{j,end});
    end 
end
set(handles.spectra_uitable,'data',data);

guidata(hObject, handles);

% --- Executes on selection change in msort_listbox.
function msort_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to msort_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns msort_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from msort_listbox

contents = cellstr(get(hObject,'String'));
value = contents{get(hObject,'Value')};
column_names = get(handles.metabolites_uitable,'columnname');
ix = find(strcmp(column_names,value));
data = get(handles.metabolites_uitable,'data');
data = sortrows(data,ix);
set(handles.metabolites_uitable,'data',data);

% --- Executes during object creation, after setting all properties.
function msort_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msort_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ssort_listbox.
function ssort_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to ssort_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ssort_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ssort_listbox
contents = cellstr(get(hObject,'String'));
value = contents{get(hObject,'Value')};
column_names = get(handles.spectra_uitable,'columnname');
ix = find(strcmp(column_names,value));
data = get(handles.spectra_uitable,'data');
data = sortrows(data,ix);
set(handles.spectra_uitable,'data',data);

% --- Executes during object creation, after setting all properties.
function ssort_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ssort_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in spectra_uitable.
function spectra_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to spectra_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.spectra_uitable,'data');
i = eventdata.Indices(1,1);
sindex = data{i,end};
mindex = handles.mindex;
mname = handles.probabilities{mindex}.mname;
dataset = handles.probabilities{mindex}.dataset;
metabolite = json2mat(['datasets/metabolites/',mname],'tag');
bin_boundaries = metabolite.bin_boundaries;

c = handles.collection;
plot(c.x,c.Y(:,sindex));
set(gca,'xdir','reverse');
bin_inxs = [];
for b = 1:size(bin_boundaries,1)
    inxs = find(bin_boundaries(b,1) >= c.x & c.x >= bin_boundaries(b,2));
    bin_inxs = [bin_inxs,inxs];
    line([bin_boundaries(b,1),bin_boundaries(b,1)],ylim,'color','g');
    line([bin_boundaries(b,2),bin_boundaries(b,2)],ylim,'color','r');    
end
bin_inxs = unique(bin_inxs);
% Now graph the metabolite peaks
sm_to_match = max(c.Y(bin_inxs,sindex));
for c = 1:length(metabolite.centers)
    for j = 1:length(metabolite.locations{c})
        loc = metabolite.locations{c}(j);
        int = metabolite.intensities{c}(j);
        line([loc,loc],[0,int],'linewidth',3,'color','m');
    end
end


[vs,ixs] = sort(handles.probabilities{mindex}.corr_vector(sindex,:),'descend');
hold on
for i = ixs(1:3)
    spectrum = json2mat(['datasets/',dataset,'/spectra/',num2str(i)],'tag');
    bin_inxs = [];
    for b = 1:size(bin_boundaries,1)
        inxs = find(bin_boundaries(b,1) >= spectrum.x & spectrum.x >= bin_boundaries(b,2));
        bin_inxs = [bin_inxs,inxs];
    end
    bin_inxs = unique(bin_inxs);
    spectrum.y = spectrum.y/sum(spectrum.y(bin_inxs))*sm_to_match;
    plot(spectrum.x,spectrum.y,'k');
end
hold off