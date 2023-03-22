% function [R] = cell_rotate(angle)
%  generate the 2D ration matrix given a rotation angle 
% 
% INPUT:
%     - angle:
% OUTPUT:
%     - R: 2x2 2D rotation matrix 
function [R] = cell_rotate(angle)

R = [cos(angle), -sin(angle);
     sin(angle), cos(angle)];
