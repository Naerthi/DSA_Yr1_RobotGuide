close all;
clc;



% Read image
img = imread('SateBW.jpg');

if ndims(img) == 3
    imgGray = rgb2gray(img);
else
    imgGray = img;
end

imgGray = im2double(imgGray);

% Pixel-level occupancy
% Black = occupied
occPixel = imgGray < 0.5;



% Grid settings
metersPerPixel = 0.36848;
cellSize_m = 3;
cellSize_px = cellSize_m / metersPerPixel;

[imgH, imgW] = size(occPixel);

nRows = floor(imgH / cellSize_px);
nCols = floor(imgW / cellSize_px);

occGrid = zeros(nRows, nCols);



% Convert pixel map to grid map
for r = 1:nRows
    for c = 1:nCols

        rowStart = round((r-1)*cellSize_px) + 1;
        rowEnd   = min(round(r*cellSize_px), imgH);

        colStart = round((c-1)*cellSize_px) + 1;
        colEnd   = min(round(c*cellSize_px), imgW);

        patch = occPixel(rowStart:rowEnd, colStart:colEnd);

        % If enough pixels in this cell are occupied, mark the grid cell occupied
        occupiedFraction = sum(patch(:)) / numel(patch);

        if occupiedFraction > 0.3
            occGrid(r,c) = 1;
        end
    end
end


% Show occupancy grid
figure;
imagesc(occGrid);
axis image;
colormap(flipud(gray));   % flip so 1=black, 0=white
title('Occupancy Grid Detected from Hand-Drawn Obstacles');

hold on
plot(nan,nan,'ks','MarkerFaceColor','k','DisplayName','Occupied (1)');
plot(nan,nan,'ws','MarkerFaceColor','w','DisplayName','Free (0)');
legend('Location','eastoutside')



% Save to reuse the map
save('occupancyGrid.mat', 'occGrid', 'cellSize_m', 'cellSize_px', ...
     'metersPerPixel', 'nRows', 'nCols');