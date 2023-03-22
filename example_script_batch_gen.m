% example script to run batch image generation
%% check if functions/package in the matlab search path
clear
answer = which('write_syth_image');
if isempty(answer)
   error('package function not in MATLAB search path. Please add first.') 
end

%% define paramters: please modify parameters as needed
n_im = 10; % number of images to generate: >=1
scale_bar_um = 10; % scale bar for the preview figure in um
fd_n = '.'; % please specify the path of the folder to save to. Or replace with uigetdir('.','Type in the folder name to write to') to enable UI selection

im_info = [];
% parameters of image
im_info.num_cell = 9; % number of cells in the image
im_info.width = 128; % pixel
im_info.height = 128; % 
im_info.scale = 0.5; % um/pixel
% cells
im_info.cell_elp_axis_um = 3; % 4 um as the mean axis length for the cells
im_info.cell_elp_axis_std_um = 0.5; 
im_info.cell_elp_axis_lim_um = [1 6]; % limit for the the cell axis to apply to the generated axis length
% drawn from a Gaussian for cell fluorescence intensity
im_info.f_intensity_mean = 2^14; % 0 - 2^16 as uint16
im_info.f_intensity_std = 1000; % 

% noise:
% gaussian noise: input as the ratio of the full range [0 1] with 1
% indicating the max intensity coded by the picture 2^16
im_info.noise_gau_mean =  0.03; % 0.03 * 2^16
im_info.noise_gau_std =  0.001; 

% calculate needed parameters: convert um into pixel number
im_info.cell_elp_axis_pixel = im_info.cell_elp_axis_um/im_info.scale;
im_info.cell_elp_axis_std_pixel = im_info.cell_elp_axis_std_um/im_info.scale;
im_info.cell_elp_axis_lim_pixel = im_info.cell_elp_axis_lim_um/im_info.scale;
% to allow center of the cell to be off image (only capture a portion of the cell)
im_info.estimated_half_cell_pixel = im_info.cell_elp_axis_um/im_info.scale/2; 

% guassian F 
im_info.f_intensity_cell = normrnd(im_info.f_intensity_mean, im_info.f_intensity_std, [im_info.num_cell, 1]);
% gate keeping making sure simulated cell with intensity with no smaller than 10
im_info.f_intensity_cell(im_info.f_intensity_cell<10) = 10; 

%% noise section
add_gaussian = true; % if adding guassian noise
add_poisson = true; % if adding poisson noise

%% preview one figure
ROIs = []; 
im_f = [];
im_l = [];
% make ROIs
[ROIs, ~] = gen_rois(im_info);
% generate images
[im_f, im_l, ~] = gen_images(im_info, ROIs);

% check noise selection and apply noise
if add_gaussian
    disp('Applying Gaussian noise')
    im_f = imnoise(im_f,'gaussian', im_info.noise_gau_mean, im_info.noise_gau_std);
    % Gaussian white noise with mean= 0.03 and variance= 0.001 of the full scale (2^16 for uint16).
end

if add_poisson
    disp('Applying poisson noise')
    im_f = imnoise(im_f,'poisson'); % add poisson noise
end
% plot
plot_syth_image(im_f, im_l, im_info, scale_bar_um);

disp('Done generating a preview image');
%% ask whether to proceed
answer =  questdlg('Would you like to proceed?', ...
	'Decision', ...
	'Yes','No-stop', 'Yes');
if strcmp(answer,'No-stop')
    disp('Procedure Terminated');
end
%% generate image pairs and write to folder
if exist(fd_n, 'dir')
   mkdir(fd_n) ;
end

% save the previewed image
write_syth_image(im_f, im_l, fd_n, 1);
if n_im > 1
    % make the rest of images
    for i_n = 2:n_im % can make parfor next        
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
        write_syth_image(im_f, im_l, fd_n, i_n);
    end
end
%% save the parameters into a .mat file
save(fullfile(fd_n, 'im_params.mat'),  '-struct', 'im_info');
disp('Done generating images');
disp(fd_n);
