% function [] = write_syth_image(im_f, im_l, fd_n, image_n)
%
% function to write sythetic images to folder
%
% INPUT:
%       - im_f: fluorescence image 2D matrix  
%       - im_l: corresponding label image 
%       - fd_n: folder path to write to
%       - image_n: image number in this sequence (use to name the image)

function [] = write_syth_image(im_f, im_l, fd_n, image_n)

im_f_fn = 'syth_image';
im_l_fn = 'syth_label';
if image_n < 1000
    zero_pad = 3;
else
    zero_pad = floor(log10(1400));
end
n_str = num2str(image_n, sprintf('%%0%i.f',zero_pad ));
imwrite(im_f,fullfile(fd_n, [im_f_fn '_' n_str '.tiff']),'tiff');
imwrite(im_l,fullfile(fd_n, [im_l_fn '_' n_str '.tiff']),'tiff');