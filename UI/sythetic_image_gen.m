function varargout = sythetic_image_gen(varargin)
% SYTHETIC_IMAGE_GEN MATLAB code for sythetic_image_gen.fig
%      SYTHETIC_IMAGE_GEN, by itself, creates a new SYTHETIC_IMAGE_GEN or raises the existing
%      singleton*.
%
%      H = SYTHETIC_IMAGE_GEN returns the handle to a new SYTHETIC_IMAGE_GEN or the handle to
%      the existing singleton*.
%
%      SYTHETIC_IMAGE_GEN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYTHETIC_IMAGE_GEN.M with the given input arguments.
%
%      SYTHETIC_IMAGE_GEN('Property','Value',...) creates a new SYTHETIC_IMAGE_GEN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sythetic_image_gen_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sythetic_image_gen_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sythetic_image_gen

% Last Modified by GUIDE v2.5 21-Mar-2023 15:15:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sythetic_image_gen_OpeningFcn, ...
                   'gui_OutputFcn',  @sythetic_image_gen_OutputFcn, ...
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


% --- Executes just before sythetic_image_gen is made visible.
function sythetic_image_gen_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sythetic_image_gen (see VARARGIN)

% Choose default command line output for sythetic_image_gen
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sythetic_image_gen wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sythetic_image_gen_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
instruc_msg_Callback;

% --- Executes on button press in pushbutton_preview.
function pushbutton_preview_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% get all parameters & generate the plots in multiple figures
%% get parameters
im_info = getParams(handles); 

%% loop through num of image to be generated: generate preview figures: w/ corresponding label image

n_im = eval(handles.preview_num.String);
add_gaussian = handles.noise_checkbox_gaussian.Value;
add_poisson = handles.noise_checkbox_poisson.Value;
% user defined scale bar length
scale_bar_um = inputdlg('Please type in scale bar length (um)', 'Scale Bar');
scale_bar_um = str2double(scale_bar_um{1});
for i_n = 1:n_im
    %% make ROIs
    [ROIs, ~] = gen_rois(im_info);
    %% generate images
    [im_f, im_l, ~] = gen_images(im_info, ROIs);
    
    %% check noise selection and apply noise
    if add_gaussian
        if i_n == 1; disp('Applying Gaussian noise'); end
        im_f = imnoise(im_f,'gaussian', im_info.noise_gau_mean, im_info.noise_gau_std);
        % Gaussian white noise with mean= 0.03 and variance= 0.001 of the full scale (2^16 for uint16).
    end
    
    if add_poisson
        if i_n == 1; disp('Applying poisson noise'); end
        im_f = imnoise(im_f,'poisson'); % add poisson noise
    end
    %% plot
    plot_syth_image(im_f, im_l, im_info, scale_bar_um);    
end
disp('Done generating preview images');

% --- 
function [im_info]= getParams(handles)
im_info = []; % structure to hold parameters 
% image
im_info.width = str2double(handles.im_width.String);
im_info.height = str2double(handles.im_height.String);
im_info.scale = str2double(handles.im_scale.String); % um/pixel
% cells
im_info.cell_elp_axis_um = str2double(handles.cell_axis_mean.String); %3; % 4 um as the mean axis length for the cells
im_info.cell_elp_axis_std_um = str2double(handles.cell_axis_std.String); %0.5; 
im_info.cell_elp_axis_lim_um = str2double(strsplit( handles.cell_axis_lim.String)); %[1 6]; % limit for the the cell axis to apply to the generated axis length
im_info.num_cell = str2double(handles.cell_num.String); %9; % number of cells in the image
im_info.f_intensity_mean = eval(handles.cell_F_mean.String); %2^14; % drawn from a certain distribution? ==> add functionality for draw from different distribution, use dialog box to implement 
im_info.f_intensity_std = eval(handles.cell_F_std.String); %100;
% noise
im_info.noise_gau_mean =  str2double(handles.noise_gau_mean.String); %
im_info.noise_gau_std =  str2double(handles.noise_gau_std.String); %

% calculate needed parameters
im_info.cell_elp_axis_pixel = im_info.cell_elp_axis_um/im_info.scale;
im_info.cell_elp_axis_std_pixel = im_info.cell_elp_axis_std_um/im_info.scale;
im_info.cell_elp_axis_lim_pixel = im_info.cell_elp_axis_lim_um/im_info.scale;

im_info.estimated_half_cell_pixel = im_info.cell_elp_axis_um/im_info.scale/2; % to allow center of the cell to be off image (only capture a portion of the cell)

% guassian F 
im_info.f_intensity_cell = normrnd(im_info.f_intensity_mean, im_info.f_intensity_std, [im_info.num_cell, 1]);
% gate keeping making sure simulated cell with intensity with no smaller
% than 10
im_info.f_intensity_cell(im_info.f_intensity_cell<10) = 10; 

% --- Executes on button press in noise_checkbox_gaussian.
function noise_checkbox_gaussian_Callback(hObject, eventdata, handles)
% hObject    handle to noise_checkbox_gaussian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of noise_checkbox_gaussian



% --- Executes on button press in noise_checkbox_poisson.
function noise_checkbox_poisson_Callback(hObject, eventdata, handles)
% hObject    handle to noise_checkbox_poisson (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of noise_checkbox_poisson



function gen_num_Callback(hObject, eventdata, handles)
% hObject    handle to gen_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gen_num as text
%        str2double(get(hObject,'String')) returns contents of gen_num as a double


% --- Executes during object creation, after setting all properties.
function gen_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gen_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_gen.
function pushbutton_gen_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% get parameters
im_info = getParams(handles); 

%% loop through num of image to be generated: generate preview figures: w/ corresponding label image

n_im = eval(handles.gen_num.String);
add_gaussian = handles.noise_checkbox_gaussian.Value;
add_poisson = handles.noise_checkbox_poisson.Value;

fd_n = uigetdir('.','Type in the folder name to write to');
if exist(fd_n, 'dir')
   mkdir(fd_n) ;
end
for i_n = 1:n_im % can make parfor next 
    %% make ROIs
    [ROIs, ~] = gen_rois(im_info);
    %% generate images
    [im_f, im_l, ~] = gen_images(im_info, ROIs);
    
    %% check noise selection and apply noise
    if add_gaussian
        if i_n == 1; disp('Applying Gaussian noise'); end
        im_f = imnoise(im_f,'gaussian', im_info.noise_gau_mean, im_info.noise_gau_std);
        % Gaussian white noise with mean= 0.03 and variance= 0.001 of the full scale (2^16 for uint16).
    end
    
    if add_poisson
        if i_n == 1; disp('Applying poisson noise'); end
        im_f = imnoise(im_f,'poisson'); % add poisson noise
    end
    %% write tiff files
    write_syth_image(im_f, im_l, fd_n, i_n)
end
%% save the parameters into a .mat file
save(fullfile(fd_n, 'im_params.mat'),  '-struct', 'im_info');
disp('Done generating images');


function preview_num_Callback(hObject, eventdata, handles)
% hObject    handle to preview_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of preview_num as text
%        str2double(get(hObject,'String')) returns contents of preview_num as a double


% --- Executes during object creation, after setting all properties.
function preview_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to preview_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function im_width_Callback(hObject, eventdata, handles)
% hObject    handle to im_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of im_width as text
%        str2double(get(hObject,'String')) returns contents of im_width as a double


% --- Executes during object creation, after setting all properties.
function im_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to im_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function im_height_Callback(hObject, eventdata, handles)
% hObject    handle to im_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of im_height as text
%        str2double(get(hObject,'String')) returns contents of im_height as a double


% --- Executes during object creation, after setting all properties.
function im_height_CreateFcn(hObject, eventdata, handles)
% hObject    handle to im_height (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function im_scale_Callback(hObject, eventdata, handles)
% hObject    handle to im_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of im_scale as text
%        str2double(get(hObject,'String')) returns contents of im_scale as a double


% --- Executes during object creation, after setting all properties.
function im_scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to im_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cell_axis_mean_Callback(hObject, eventdata, handles)
% hObject    handle to cell_axis_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cell_axis_mean as text
%        str2double(get(hObject,'String')) returns contents of cell_axis_mean as a double


% --- Executes during object creation, after setting all properties.
function cell_axis_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_axis_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cell_axis_std_Callback(hObject, eventdata, handles)
% hObject    handle to cell_axis_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cell_axis_std as text
%        str2double(get(hObject,'String')) returns contents of cell_axis_std as a double


% --- Executes during object creation, after setting all properties.
function cell_axis_std_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_axis_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cell_axis_lim_Callback(hObject, eventdata, handles)
% hObject    handle to cell_axis_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cell_axis_lim as text
%        str2double(get(hObject,'String')) returns contents of cell_axis_lim as a double


% --- Executes during object creation, after setting all properties.
function cell_axis_lim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_axis_lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cell_num_Callback(hObject, eventdata, handles)
% hObject    handle to cell_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cell_num as text
%        str2double(get(hObject,'String')) returns contents of cell_num as a double


% --- Executes during object creation, after setting all properties.
function cell_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cell_F_mean_Callback(hObject, eventdata, handles)
% hObject    handle to cell_F_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cell_F_mean as text
%        str2double(get(hObject,'String')) returns contents of cell_F_mean as a double


% --- Executes during object creation, after setting all properties.
function cell_F_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_F_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cell_F_std_Callback(hObject, eventdata, handles)
% hObject    handle to cell_F_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cell_F_std as text
%        str2double(get(hObject,'String')) returns contents of cell_F_std as a double


% --- Executes during object creation, after setting all properties.
function cell_F_std_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cell_F_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in instruc_msg.
function instruc_msg_Callback(hObject, eventdata, handles)
% hObject    handle to instruc_msg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox(["Instruction";"Fill in the parameters box, select noise type and preview/generate images"]);



function noise_gau_mean_Callback(hObject, eventdata, handles)
% hObject    handle to noise_gau_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_gau_mean as text
%        str2double(get(hObject,'String')) returns contents of noise_gau_mean as a double


% --- Executes during object creation, after setting all properties.
function noise_gau_mean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_gau_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_gau_std_Callback(hObject, eventdata, handles)
% hObject    handle to noise_gau_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_gau_std as text
%        str2double(get(hObject,'String')) returns contents of noise_gau_std as a double


% --- Executes during object creation, after setting all properties.
function noise_gau_std_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_gau_std (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
