% function [im_f, im_l, params] = gen_images(im_info, ROIs)
%
% function to generate images using image parameteres and ROI coordinates
% 
% INPUT:
%       - im_info: structure containing image parameters
%       - ROIs: structure containing ROIs of nucleus (.nuc_roi_xy) and cytoplasma (.cell_roi_xy)
% OUTPUT:
%       - im_f: generated fluorescent image 2D matrix 
%       - im_l: label image 2D matrix 
%       - params: varible to return some default parameters in this function for reference. 
%               reserved for future implementation. Currently returing an
%               empty matrix
function [im_f, im_l, params] = gen_images(im_info, ROIs)
%% default parameters:
nucleus_lit = 0.7; % nucleus is 70% darker than the cytoplasma
%% 
% initialize 
im_f = zeros(im_info.height,im_info.width); % take care of the data type after making it (integrating noise and possible numerical negative value due to stacking ROIs
im_l = zeros(im_info.height,im_info.width, 'uint8');

% loop through cells 
for i_cell = 1:im_info.num_cell
    im_f = im_f ...
        +  poly2mask(ROIs.cell_roi_xy(:,1,i_cell),ROIs.cell_roi_xy(:,2,i_cell),im_info.width,im_info.height) .* im_info.f_intensity_cell(i_cell) ... % cytoplasma
        -  poly2mask(ROIs.nuc_roi_xy(:,1,i_cell), ROIs.nuc_roi_xy(:,2,i_cell), im_info.width,im_info.height) .* im_info.f_intensity_cell(i_cell) .* nucleus_lit; % lighter nucleus
    im_l = im_l + uint8(poly2mask(ROIs.cell_roi_xy(:,1,i_cell),ROIs.cell_roi_xy(:,2,i_cell),im_info.width,im_info.height)).* uint8(i_cell);
end
im_f = uint16(im_f);
params = [];