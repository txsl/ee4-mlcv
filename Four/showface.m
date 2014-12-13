function [  ] = showface( face )
%SHOWFACE Summary of this function goes here
%   Detailed explanation goes here

init
imagesc(reshape(face, [ IM_HEIGHT IM_WIDTH ]));

end

