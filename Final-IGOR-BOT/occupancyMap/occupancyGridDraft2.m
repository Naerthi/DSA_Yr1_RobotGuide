close all;
clc;

% Section 1 — load the satellite image and define grid from scale bar
img = imread('SatelliteImageNoLabel.png');
img = im2double(img);

[imgH, imgW, ~] = size(img);


% % Click the left and right ends of the 50 m scale bar
% [xScale, yScale] = ginput(2);
% plot(xScale, yScale, 'r-o', 'LineWidth', 2);
% 
% scalePixels = sqrt((xScale(2)-xScale(1))^2 + (yScale(2)-yScale(1))^2);
% metersPerPixel = 50 / scalePixels;
% 
% disp(['Scale length in pixels = ', num2str(scalePixels)]);
% disp(['Meters per pixel = ', num2str(metersPerPixel)]);

% result: 
% scalePixels = 135.6923
% metersPerPixel = 0.36848



% Section 2 — choose grid cell size and generate map grid
metersPerPixel = 0.36848;   % from your measured scale
cellSize_m = 5;             % choose 10 m per grid cell
cellSize_px = cellSize_m / metersPerPixel;

nRows = floor(imgH / cellSize_px);
nCols = floor(imgW / cellSize_px);

disp(['Meters per pixel = ', num2str(metersPerPixel)]);
disp(['Cell size (m) = ', num2str(cellSize_m)]);
disp(['Cell size (px) = ', num2str(cellSize_px)]);
disp(['Grid size = ', num2str(nRows), ' rows x ', num2str(nCols), ' cols']);


% Section 3 — create an empty occupancy grid
occGrid = zeros(nRows, nCols);   % 0 = free, 1 = occupied


%% auto generate

for r = 1:nRows
    for c = 1:nCols

        % pixel range of this grid cell
        rowStart = round((r-1)*cellSize_px) + 1;
        rowEnd   = min(round(r*cellSize_px), imgH);

        colStart = round((c-1)*cellSize_px) + 1;
        colEnd   = min(round(c*cellSize_px), imgW);

        cellPatch = img(rowStart:rowEnd, colStart:colEnd, :);

        R = cellPatch(:,:,1);
        G = cellPatch(:,:,2);
        B = cellPatch(:,:,3);

        % Rough colour rules
        % Dark blue water / canal
        waterMask = (B > G) & (B > R) & (mean(B(:)) < 0.55);

        % Light grey / white roof / rail / paved hard structures
        greyMask = abs(R-G) < 0.08 & abs(G-B) < 0.08 & mean(R(:)) > 0.45;

        % Very dark regions
        darkMask = mean(R(:)) < 0.25 & mean(G(:)) < 0.25 & mean(B(:)) < 0.25;

        % fraction of matching pixels in this cell
        fracWater = sum(waterMask(:)) / numel(waterMask);
        fracGrey  = sum(greyMask(:))  / numel(greyMask);
        fracDark  = sum(darkMask(:))  / numel(darkMask);

        % Occupancy decision
        if fracWater > 0.35 || fracGrey > 0.45 || fracDark > 0.40
            occGrid(r,c) = 1;
        end
    end
end

%%

% Section 4 — show satellite image with grid on top
figure;
imshow(img);
hold on;
title('Satellite Map with Grid');

for c = 0:nCols
    x = c * cellSize_px;
    plot([x x], [0 imgH], 'y-', 'LineWidth', 0.3);
end

for r = 0:nRows
    y = r * cellSize_px;
    plot([0 imgW], [y y], 'y-', 'LineWidth', 0.3);
end
hold off;



% Section 5 — Show auto-generated occupancy grid
figure;
imagesc(occGrid);
axis image;
colormap(gray);
colorbar;
title('Auto-generated Occupancy Grid (1 = occupied, 0 = free)');
xlabel('Column');
ylabel('Row');


% Overlay occupied cells on satellite image
figure;
imshow(img);
hold on;
title('Satellite Map with Auto-detected Occupied Cells');

for r = 1:nRows
    for c = 1:nCols
        if occGrid(r,c) == 1
            x1 = (c-1) * cellSize_px;
            y1 = (r-1) * cellSize_px;

            rectangle('Position', [x1, y1, cellSize_px, cellSize_px], ...
                'FaceColor', [1 0 0 0.30], ...
                'EdgeColor', 'none');
        end
    end
end
hold off;


%% Section 6 — Manual editing in code
% Example: mark one cell as occupied
 occGrid(20, 35) = 1;

% Example: mark a rectangular block as occupied
% occGrid(30:35, 40:50) = 1;

% Example: clear a cell back to free
% occGrid(20, 35) = 0;

% Example: clear a rectangular block
% occGrid(30:35, 40:50) = 0;



% Section 7 — Show updated occupancy grid after manual edits
figure;
imagesc(occGrid);
axis image;
colormap(gray);
colorbar;
title('Updated Occupancy Grid');



%% Overlay occupied cells back onto satellite image
% map lat/lon onto the image

% Section 8 — define control points for GPS-to-image mapping
figure;
imshow(img);
hold on;
title('Satellite Map with Occupied Cells');

% Draw grid
for c = 0:nCols
    x = c * cellSize_px;
    plot([x x], [0 imgH], 'y-', 'LineWidth', 0.3);
end

for r = 0:nRows
    y = r * cellSize_px;
    plot([0 imgW], [y y], 'y-', 'LineWidth', 0.3);
end

% Draw occupied cells
for r = 1:nRows
    for c = 1:nCols
        if occGrid(r,c) == 1
            x1 = (c-1) * cellSize_px;
            y1 = (r-1) * cellSize_px;

            rectangle('Position', [x1, y1, cellSize_px, cellSize_px], ...
                'FaceColor', [1 0 0 0.35], ...
                'EdgeColor', 'none');
        end
    end
end

hold off;

% Section 8 - Save occupancy grid
save('occupancyGrid.mat', 'occGrid', 'cellSize_m', 'cellSize_px', ...
     'metersPerPixel', 'nRows', 'nCols');


%% SECTION: Interactive occupancy grid editing

figure
imagesc(occGrid)
axis image
colormap(gray)
colorbar
title('Click cells to toggle occupancy (Press ENTER when finished)')
hold on

while true
    
    [x,y] = ginput(1);

    % ENTER pressed → stop editing
    if isempty(x)
        break
    end

    col = round(x);
    row = round(y);

    % check bounds
    if row>=1 && row<=nRows && col>=1 && col<=nCols
        
        % toggle cell
        occGrid(row,col) = 1 - occGrid(row,col);

        % update the display
        imagesc(occGrid)
        axis image
        colormap(gray)
        drawnow
        
    end

end







