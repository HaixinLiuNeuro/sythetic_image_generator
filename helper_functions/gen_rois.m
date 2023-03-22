% function [ROIs, params] = gen_rois(im_info)
% 
% function to make ROIs using defined parameter set
% 
% INPUT:
%    - im_info: stucture containing all the parameters
% OUTPUT:
%    - ROIs: structure to out put generated ROIs of cell and its
%    corresponding nucleus w/ field names:
%                             .cell_roi_xy 
%                             .nuc_roi_xy 
%    - params: varible to return some default parameters in this function for reference. 
%               reserved for future implementation. Currently returing an
%               empty matrix

function [ROIs, params] = gen_rois(im_info)
params = []; % reserved output for parameters if needed in the future
%% input checking module to be added later
%% default paras
theta = 0 : 0.01 : 2*pi; % resolution 


% nucleus: 75% size of the minor axis of the cell, as a circle, jitter
% location by 0.2um std guaussian
nuc_jitter_size_mean = 0.75;
nuc_jitter_size_std = 0.02;



%% 
cell_roi_xy = zeros(length(theta), 2, im_info.num_cell); % theta x [x y] x cell, to store the cell ROI coordinates
nuc_roi_xy = zeros(length(theta), 2, im_info.num_cell); % theta x [x y] x cell, to store the nucleus ROI coordinates

% location: when not specified, random generate from a uniform distribution
% since we can possibly see cropped cells, we allow the center to be off
% the edge of the image
center_x = rand(1, im_info.num_cell)*(im_info.width+ im_info.estimated_half_cell_pixel*2)  - im_info.estimated_half_cell_pixel;
center_y = rand(1, im_info.num_cell)*(im_info.height+im_info.estimated_half_cell_pixel*2) - im_info.estimated_half_cell_pixel;

% axis length
elp_x = normrnd(im_info.cell_elp_axis_pixel, im_info.cell_elp_axis_std_pixel, im_info.num_cell,1);
elp_y = normrnd(im_info.cell_elp_axis_pixel, im_info.cell_elp_axis_std_pixel, im_info.num_cell,1);
elp_x(elp_x<im_info.cell_elp_axis_lim_pixel(1)) = im_info.cell_elp_axis_lim_pixel(1);
elp_y(elp_y<im_info.cell_elp_axis_lim_pixel(1)) = im_info.cell_elp_axis_lim_pixel(1);
elp_x(elp_x>im_info.cell_elp_axis_lim_pixel(2)) = im_info.cell_elp_axis_lim_pixel(2);
elp_y(elp_y>im_info.cell_elp_axis_lim_pixel(2)) = im_info.cell_elp_axis_lim_pixel(2);

% nucleus: 
tmp_jitter = normrnd(nuc_jitter_size_mean, nuc_jitter_size_std, im_info.num_cell,1);
tmp_jitter(tmp_jitter>0.9) = 0.9; % gate keeping (not too big)
nuc_r = min([elp_x elp_y],[], 2) .* tmp_jitter; % nucleus size
nuc_pos_jitter_x = normrnd(0, 0.1/im_info.scale, im_info.num_cell, 1); % nucleus position jitter 0.1 um std drawn from gaussian
nuc_pos_jitter_y = normrnd(0, 0.1/im_info.scale, im_info.num_cell, 1);

% rotation
angle_cell = rand(1, im_info.num_cell)*pi;
%% loop through cells to make ROIs

for i_cell = 1:im_info.num_cell
    tmp_x = elp_x(i_cell) * cos(theta) ;
    tmp_y = elp_y(i_cell) * sin(theta) ;
    
%     figure;
%     plot(tmp_x, tmp_y,'r');
    tmp_R = cell_rotate(angle_cell(i_cell));
    
    cell_roi_xy(:,:,i_cell) = (tmp_R*[tmp_x; tmp_y])';
    cell_roi_xy(:,1,i_cell) = cell_roi_xy(:,1,i_cell) + center_x(i_cell);
    cell_roi_xy(:,2,i_cell) = cell_roi_xy(:,2,i_cell) + center_y(i_cell);
    
    nuc_roi_xy(:, :, i_cell) = [nuc_r(i_cell) * cos(theta) + center_x(i_cell)+ nuc_pos_jitter_x(i_cell); ...
                                nuc_r(i_cell) * sin(theta) + center_y(i_cell)+ nuc_pos_jitter_y(i_cell)]';
    % given the big size nature of this stack, consider make this mask on
    % the fly during the image generating phase
    % mask_by_cell(:,:,i_cell) = poly2mask(cell_roi_xy(:,1,i_cell),cell_roi_xy(:,2,i_cell),im_info.width,im_info.height);
end
%% OUTPUT
ROIs.cell_roi_xy = cell_roi_xy;
ROIs.nuc_roi_xy = nuc_roi_xy;
