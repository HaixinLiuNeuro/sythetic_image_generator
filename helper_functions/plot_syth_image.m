% function [h_fig, h_ax] = plot_syth_image(im_f, im_l, im_info)
% 
function [h_fig, h_ax] = plot_syth_image(im_f, im_l, im_info, scale_bar_dist)
% default scale bar 10um
if nargin < 4 
   scale_bar_dist = 10; 
end

h_fig = figure('units', 'normalized', 'position',[0.1 0.1 0.6 0.6]);

h_ax = [];
h_ax(1)=subplot(1,2,1); hold on;
imagesc(im_f, [min(im_f(:)) max(im_f(:))]);
colorbar; colormap(gca, gray);
set(gca, 'YDir','reverse');
xlim([0 im_info.width]+0.5);
ylim([0 im_info.height]+0.5)
pbaspect([im_info.width im_info.height im_info.height])
% plot scale bar
plot(([-scale_bar_dist 0]-round(scale_bar_dist/2))*(1/im_info.scale)+im_info.width, round([-scale_bar_dist/2 -scale_bar_dist/2])*(1/im_info.scale)+im_info.height, 'r-','LineWidth',  3);
text(-round(scale_bar_dist*3/2)*(1/im_info.scale)+im_info.width, -round(scale_bar_dist/2+2)*(1/im_info.scale)+im_info.height, [num2str(scale_bar_dist) ' um '], 'color', 'w')

h_ax(2)=subplot(1,2,2); hold on;
imagesc(im_l, [0 max(im_l(:))]);
colorbar;colormap(gca, parula);
set(gca, 'YDir','reverse');
xlim([0 im_info.width]+0.5);
ylim([0 im_info.height]+0.5)
pbaspect([im_info.width im_info.height im_info.height])
linkaxes(h_ax, 'xy')
