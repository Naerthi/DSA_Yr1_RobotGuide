clc % don't clear

% Create a 10x10 map with 1 cell/meter resolution
map = binaryOccupancyMap(10, 10, 1);

% Define an obstacle
setOccupancy(map, [3 3; 3 4; 3 5], 1);

% Visualize
show(map)

% Check if a specific point is occupied
xy = [3 5];
isOccupied = checkOccupancy(map, xy) % Returns 1

%% 

% 1. Load your satellite image
rgbImg = imread('SatelliteImage.jpg');

% 2. Segment the 'Obstacles' (e.g., Water and Buildings)
% We'll use grayscale as a shortcut, but you can also use color thresholds
grayImg = rgb2gray(rgbImg);

% 3. Define Real-World Scale
% You need to know the actual width of this area in meters.
% Let's assume the London Stadium is roughly 250 meters wide.
% If the stadium is 500 pixels wide in the image, resolution is 2 cells/meter.
imageWidthInPixels = size(rgbImg, 2);
realWorldWidthInMeters = 800; % Estimate for this view
res = imageWidthInPixels / realWorldWidthInMeters;

% 4. Create the Map
map = occupancyMap(double(obstacles), res);

% 5. Inflate for Safety
% If your robot is 2 meters wide, use a 1.1m radius to be safe
inflate(map, 1.1);

% 6. Visualize the result
figure;
subplot(1,2,1); imshow(rgbImg); title('Original Satellite View');
subplot(1,2,2); show(map); title('Converted Occupancy Map');

%% 


% 1. Load the yellow/white image
rawImg = imread('handDrawnObstacles.jpg');

% 2. Convert to binary
% Since the background is white [255, 255, 255] and the shapes are yellow,
% we can just look at the Blue channel. Yellow has very little blue.
blueChannel = rawImg(:,:,3); 
binaryGrid = blueChannel < 128; % Yellow areas become 1 (Occupied), White becomes 0 (Free)

% 3. Define Scale (Crucial!)
% Let's say this drawing represents a 20m x 20m room.
% If the image is 1000 pixels wide, resolution is 1000/20 = 50.
res = 50; 

% 4. Create the Map
map = occupancyMap(binaryGrid, res);

% 5. Visualize
show(map);
title('Occupancy Map from Manual Drawing');


%% chaty

close all;
clc;

% Read image
img = imread('full.jpg');
img = im2double(img);

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

% 1) Detect colours

% White background / free space
maskWhite = R > 0.95 & G > 0.95 & B > 0.95;

% Yellow obstacles
maskYellow = R > 0.90 & G > 0.70 & B < 0.25;

% Red key points
maskRed = R > 0.85 & G < 0.25 & B < 0.25;

% Green signal points
maskGreen = R < 0.30 & G > 0.55 & B < 0.35;

% Blue robot path
maskBlue = R < 0.25 & G > 0.40 & B > 0.75;

% 2) Build occupancy grid
% Only yellow is occupied
occMatrix = maskYellow;

% Optional cleanup
occMatrix = bwareaopen(occMatrix, 5);
occMatrix = imclose(occMatrix, strel('disk', 1));

% 3) Show occupancy grid
figure;
imshow(occMatrix);
title('Occupancy Grid (Yellow = Occupied)');

% 4) Create binary occupancy map
resolution = 10;   % example resolution
map = binaryOccupancyMap(occMatrix, resolution);

figure;
show(map);
title('binaryOccupancyMap');

% 5) Separate normal red key points and special red area
ccRed = bwconncomp(maskRed);
redStats = regionprops(ccRed, 'Centroid', 'Area', 'PixelIdxList', 'BoundingBox');

% Threshold to separate small red points from the large red ellipse
areaThreshold = 200;   % adjust if needed

normalRedPoints = [];
specialKeyMask = false(size(maskRed));

for k = 1:length(redStats)
    if redStats(k).Area >= areaThreshold
        % Large red connected region = special key area
        specialKeyMask(redStats(k).PixelIdxList) = true;
    else
        % Small red connected region = normal key point
        normalRedPoints = [normalRedPoints; redStats(k).Centroid];
    end
end

greenStats = regionprops(maskGreen, 'Centroid', 'Area');

minArea = 5;
greenStats = greenStats([greenStats.Area] >= minArea);
greenPoints = reshape([greenStats.Centroid], 2, []).';



% 6) Show original image with detected points
figure;
imshow(img);
hold on;

if ~isempty(redPoints)
    plot(redPoints(:,1), redPoints(:,2), 'ro', ...
        'MarkerSize', 8, 'LineWidth', 2);
end

if ~isempty(greenPoints)
    plot(greenPoints(:,1), greenPoints(:,2), 'go', ...
        'MarkerSize', 8, 'LineWidth', 2);
end

title('Detected Key Points and Signal Points');
legend('Key Points (Red)', 'Signal Points (Green)');
hold off;

% 7) Show occupancy grid with blue path overlaid
figure;
imshow(~occMatrix);
hold on;

% Overlay blue path pixels
[yBlue, xBlue] = find(maskBlue);
plot(xBlue, yBlue, '.', 'Color', [0 0.45 0.95], 'MarkerSize', 4);

% Overlay red points
if ~isempty(redPoints)
    plot(redPoints(:,1), redPoints(:,2), 'ro', ...
        'MarkerSize', 8, 'LineWidth', 2);
end

% Overlay green points
if ~isempty(greenPoints)
    plot(greenPoints(:,1), greenPoints(:,2), 'go', ...
        'MarkerSize', 8, 'LineWidth', 2);
end

title('Occupancy Grid with Robot Path and Points');
hold off;

% 8) Create coloured label map
% 0 = free
% 1 = obstacle
% 2 = path
% 3 = key point
% 4 = signal point

labelMap = zeros(size(R));

labelMap(maskYellow) = 1;
labelMap(maskBlue)   = 2;
labelMap(maskRed)    = 3;
labelMap(maskGreen)  = 4;

figure;
imagesc(labelMap);
axis image;
colorbar;
title('Label Map');

% 9) Print coordinates
disp('Red key point centroids [x y]:');
disp(redPoints);

disp('Green signal point centroids [x y]:');
disp(greenPoints);




figure;
imshow(img);
hold on;

% normal red key points
if ~isempty(normalRedPoints)
    plot(normalRedPoints(:,1), normalRedPoints(:,2), 'ro', ...
        'MarkerSize', 8, 'LineWidth', 2);
end

% green signal points
if ~isempty(greenPoints)
    plot(greenPoints(:,1), greenPoints(:,2), 'go', ...
        'MarkerSize', 8, 'LineWidth', 2);
end

% boundary of the special red area
visboundaries(specialKeyMask, 'Color', 'r', 'LineWidth', 2);

title('Detected Key Points, Signal Points, and Special Key Area');
legend('Normal Key Points','Signal Points','Special Key Area');
hold off;





% 8) Create coloured label map

% 0 = free
% 1 = obstacle
% 2 = path
% 3 = normal key point
% 4 = signal point
% 5 = special key area

labelMap = zeros(size(R));

labelMap(maskYellow) = 1;
labelMap(maskBlue) = 2;
labelMap(maskGreen) = 4;
labelMap(specialKeyMask) = 5;

% Put small red point regions back as 3
smallRedMask = maskRed & ~specialKeyMask;
labelMap(smallRedMask) = 3;

figure;
imagesc(labelMap);
axis image;
colorbar;
title('Label Map with Special Key Area');








