close all;
clc;

% Go to repo root
basePath = fileparts(fileparts(mfilename('fullpath')));

addpath(basePath);
addpath(fullfile(basePath, 'occupancyMap'));
addpath(fullfile(basePath, 'visualisation'));
addpath(fullfile(basePath, 'BfsAndDijkstra'));

load(fullfile(basePath, 'newMapReadings.mat'));

run('AngularV.m');
run('extractedPoints.m');

% Load occupancy grid data
load(fullfile(basePath, 'occupancyMap', 'occupancyGrid.mat'), 'occGrid', 'cellSize_m', 'nRows', 'nCols'); 

% calibration bounds for the image
mapRef.latTop    = (51.5413023377624 + 51.54128358792175) / 2;
mapRef.latBottom = (51.53637540808553 + 51.53637740926019) / 2;
mapRef.lonLeft   = (-0.02113822581864861 + -0.021159663821911742) / 2;
mapRef.lonRight  = (-0.0053338668458112635 + -0.00531892350591541) / 2;

% Build node structure
nodes = createNodesFromTables(keyP, sigP);

% Build weighted graph for Dijkstra
L_dij = createGraph_Dijkstra(nodes);

% Define waiting points
waitingIdx = getWaitingPointIndices(nodes);
waitingNames = string(nodes.names(waitingIdx));

% Dynamic obstacles
enableDynamicObstacles = true;
nDynamicObstacles      = 6; % number of moving obstacles
obstacleRadiusCells    = 1; % 1 means obstacle occupies a 3x3 neighbourhood
framePause             = 0.05; % walking speed
replanPause            = 0.20; % short pause when replanning happens

% Randomly choose initial waiting point
rng('shuffle');
currentNode = waitingIdx(randi(numel(waitingIdx)));

fprintf('IGOR is currently waiting for you at: %s\n', nodes.names{currentNode});
fprintf('(All WAITING points: %s)\n\n', strjoin(waitingNames, ", "));

missionActive = true;
firstMission = true;

while missionActive

    fprintf('All available points:\n');
    for i = 1:nodes.nTotal
        fprintf('%2d: %s\n', i, nodes.names{i});
    end
    fprintf('\n');

    if firstMission
        validStart = false;
        while ~validStart
            startInput = strtrim(input('Enter your START point name or number: ', 's'));
            startNode = parsePointInput(nodes, startInput);

            if ~isempty(startNode)
                validStart = true;
            else
                fprintf('Invalid START point. Please enter a valid point name or number from the list above.\n');
            end
        end
    else
        startNode = currentNode;
        fprintf('Continuing from the current location: %s\n', nodes.names{startNode});
    end

    validGoal = false;
    while ~validGoal
        if firstMission
            goalPrompt = 'Enter your DESTINATION name or number: ';
        else
            goalPrompt = 'Enter your NEXT DESTINATION name or number: ';
        end

        goalInput = strtrim(input(goalPrompt, 's'));
        goalNode = parsePointInput(nodes, goalInput);

        if ~isempty(goalNode)
            validGoal = true;
        else
            fprintf('Invalid DESTINATION point. Please enter a valid point name or number from the list above.\n');
        end
    end

    if firstMission
        [path_to_start_nodes, dist_to_start] = dijkstraPQ(L_dij, currentNode, startNode);
    else
        path_to_start_nodes = startNode;
        dist_to_start = 0;
    end

    [path_to_goal_nodes, dist_to_goal] = dijkstraPQ(L_dij, startNode, goalNode);

    fprintf('\nROUTES: \n');

    if firstMission
        fprintf('Waiting point -> Starting point distance: %.2f m\n', dist_to_start);
        disp(nodes.names(path_to_start_nodes));
    end

    fprintf('Starting point -> Destination distance: %.2f m\n', dist_to_goal);
    disp(nodes.names(path_to_goal_nodes));

    if firstMission
        seg1 = buildDetailedRoute(path_to_start_nodes, nodes, mapRef, occGrid);
    else
        seg1 = [];
    end

    seg2 = buildDetailedRoute(path_to_goal_nodes, nodes, mapRef, occGrid);

    fig = figure('Name', 'Robot Navigation', 'Color', 'w');
    ax = axes(fig);

    plotOccupancyAndGraph(ax, occGrid, nodes, mapRef, L_dij, waitingIdx, currentNode, startNode, goalNode, []);

    if firstMission && ~isempty(seg1)
        h1 = plotNodePath(ax, nodes, mapRef, occGrid, path_to_start_nodes, 'c-', 2.5);
        set(h1, 'DisplayName', 'Waiting Point to Starting Point');
    end

    h2 = plotNodePath(ax, nodes, mapRef, occGrid, path_to_goal_nodes, 'r-', 3.0);
    set(h2, 'DisplayName', 'Starting Point to Destination');

    if enableDynamicObstacles
        startRC_forDyn = chooseFirstRouteCell(seg1, seg2);
        goalRC_forDyn  = chooseLastRouteCell(seg1, seg2);
        dynState = initDynamicObstacles(occGrid, nDynamicObstacles, obstacleRadiusCells, startRC_forDyn, goalRC_forDyn);

        if firstMission && ~isempty(seg1)
            [~, dynState] = animateSegmentWithDynamicObstacles(ax, occGrid, seg1, dynState, ...
                fullfile(basePath, 'visualisation', 'igor.jpeg'), 0.05, framePause, replanPause, obstacleRadiusCells);
        end

        [~, dynState] = animateSegmentWithDynamicObstacles(ax, occGrid, seg2, dynState, ...
            fullfile(basePath, 'visualisation', 'igor.jpeg'), 0.05, framePause, replanPause, obstacleRadiusCells);
    else
        if isempty(seg1)
            fullRouteRC = seg2;
        elseif isempty(seg2)
            fullRouteRC = seg1;
        else
            fullRouteRC = [seg1; seg2(2:end,:)];
        end
        animateRobotIcon(ax, fullRouteRC, fullfile(basePath, 'visualisation', 'igor.jpeg'), 0.05);
    end

    fprintf('Safely arrived from %s to %s\n', nodes.names{startNode}, nodes.names{goalNode});

    currentNode = goalNode;
    firstMission = false;

    validReply = false;
    while ~validReply
        reply = upper(strtrim(input('Any other need for help? Key in YES or NO to tell IGOR the GOAT: ', 's')));

        if strcmp(reply, 'YES')
            fprintf('\nPlease enter your next DESTINATION.\n\n');
            validReply = true;

        elseif strcmp(reply, 'NO')
            nearestWaitNode = nearestWaitingPoint(L_dij, waitingIdx, currentNode);
            [path_to_wait_nodes, dist_to_wait] = dijkstraPQ(L_dij, currentNode, nearestWaitNode);

            fprintf('\nDestination -> Nearest waiting point distance: %.2f m\n', dist_to_wait);
            disp(nodes.names(path_to_wait_nodes));

            seg3 = buildDetailedRoute(path_to_wait_nodes, nodes, mapRef, occGrid);

            fig2 = figure('Name', 'Return to waiting point', 'Color', 'w');
            ax2 = axes(fig2);
            plotOccupancyAndGraph(ax2, occGrid, nodes, mapRef, L_dij, waitingIdx, currentNode, currentNode, currentNode, nearestWaitNode);

            h3 = plotNodePath(ax2, nodes, mapRef, occGrid, path_to_wait_nodes, 'm-', 2.5);
            set(h3, 'DisplayName', 'Destination to Waiting Point');

            if enableDynamicObstacles
                startRC_return = seg3(1,:);
                goalRC_return  = seg3(end,:);
                dynStateReturn = initDynamicObstacles(occGrid, nDynamicObstacles, obstacleRadiusCells, startRC_return, goalRC_return);
                animateSegmentWithDynamicObstacles(ax2, occGrid, seg3, dynStateReturn, ...
                    fullfile(basePath, 'visualisation', 'igor.jpeg'), 0.05, framePause, replanPause, obstacleRadiusCells);
            else
                animateRobotIcon(ax2, seg3, fullfile(basePath, 'visualisation', 'igor.jpeg'), 0.05);
            end

            fprintf('IGOR returned to waiting point: %s, that is all folks, please say THANK YOU! You belong here!\n', nodes.names{nearestWaitNode});

            missionActive = false;
            validReply = true;

        else
            fprintf('Invalid input. Please enter YES or NO\n');
        end
    end
end


function rc = chooseFirstRouteCell(seg1, seg2)
if ~isempty(seg1)
    rc = seg1(1,:);
elseif ~isempty(seg2)
    rc = seg2(1,:);
else
    rc = [1 1];
end
end


function rc = chooseLastRouteCell(seg1, seg2)
if ~isempty(seg2)
    rc = seg2(end,:);
elseif ~isempty(seg1)
    rc = seg1(end,:);
else
    rc = [1 1];
end
end


function dynState = initDynamicObstacles(staticOccGrid, nObs, radiusCells, startRC, goalRC)
[nRows, nCols] = size(staticOccGrid);

dynState.pos  = zeros(nObs, 2);
dynState.vel  = zeros(nObs, 2);
dynState.mode = strings(nObs, 1);
dynState.stepCounter = zeros(nObs, 1);
dynState.handle = gobjects(0);

freeCells = find(staticOccGrid == 0);
trialsMax = 2000;

for i = 1:nObs
    placed = false;
    trials = 0;

    while ~placed && trials < trialsMax
        trials = trials + 1;
        pick = freeCells(randi(numel(freeCells)));
        [r, c] = ind2sub([nRows, nCols], pick);

        if norm([r c] - startRC) < 8 || norm([r c] - goalRC) < 8
            continue;
        end

        tooClose = false;
        for j = 1:i-1
            if norm([r c] - dynState.pos(j,:)) < 6
                tooClose = true;
                break;
            end
        end
        if tooClose
            continue;
        end

        dynState.pos(i,:) = [r c];
        dynState.vel(i,:) = randomDirection();

        if rand < 0.5
            dynState.mode(i) = "patrol";
        else
            dynState.mode(i) = "random";
        end

        placed = true;
    end
end

dynState.radiusCells = radiusCells;
dynState.staticOccGrid = staticOccGrid;
end


function [robotRoute, dynState] = animateSegmentWithDynamicObstacles(ax, staticOccGrid, initialRouteRC, dynState, iconFile, scaleFactor, framePause, replanPause, radiusCells)
if isempty(initialRouteRC)
    robotRoute = [];
    return;
end

routeRC = initialRouteRC;
goalRC = initialRouteRC(end,:);
robotRC = routeRC(1,:);
robotRoute = robotRC;

[iconImg, ~, alpha] = imread(iconFile);
if isempty(alpha)
    if size(iconImg,3) == 3
        alpha = 255 * ones(size(iconImg,1), size(iconImg,2), 'uint8');
    else
        alpha = uint8(255 * (iconImg > 0));
    end
end

iconImg = imresize(iconImg, scaleFactor);
alpha   = imresize(alpha, scaleFactor);
iconH = size(iconImg,1);
iconW = size(iconImg,2);

xData = [robotRC(2) - iconW/2, robotRC(2) + iconW/2];
yData = [robotRC(1) - iconH/2, robotRC(1) + iconH/2];

hRobot = image(ax, 'XData', xData, 'YData', yData, 'CData', iconImg, 'AlphaData', double(alpha)/255);
uistack(hRobot, 'top');

if isempty(dynState.handle) || ~all(isgraphics(dynState.handle))
    dynState.handle = plot(ax, dynState.pos(:,2), dynState.pos(:,1), 'ks', ...
        'MarkerFaceColor', [1 0.4 0], 'MarkerSize', 8, 'LineWidth', 1.0, ...
        'DisplayName', 'Dynamic obstacle');
else
    set(dynState.handle, 'XData', dynState.pos(:,2), 'YData', dynState.pos(:,1));
end

drawnow;

routeIdx = 2;
while true
    if robotRC(1) == goalRC(1) && robotRC(2) == goalRC(2)
        break;
    end

    dynState = updateDynamicObstacles(dynState, robotRC, goalRC);
    dynamicOcc = buildDynamicOccupancy(staticOccGrid, dynState, radiusCells, robotRC, goalRC);

    if routeIdx > size(routeRC,1)
        routeRC = astarGridPath(dynamicOcc, robotRC, goalRC);
        routeIdx = 2;
        title(ax, 'IGOR GUIDE');
        drawnow;
        pause(replanPause);
        title(ax, 'IGOR GUIDE');
    end

    nextRC = routeRC(routeIdx,:);

    if dynamicOcc(nextRC(1), nextRC(2)) == 1
        routeRC = astarGridPath(dynamicOcc, robotRC, goalRC);
        routeIdx = 2;
        title(ax, 'IGOR GUIDE');
        drawnow;
        pause(replanPause);
        title(ax, 'IGOR GUIDE');
        continue;
    end

    robotRC = nextRC;
    robotRoute = [robotRoute; robotRC];
    routeIdx = routeIdx + 1;

    xData = [robotRC(2) - iconW/2, robotRC(2) + iconW/2];
    yData = [robotRC(1) - iconH/2, robotRC(1) + iconH/2];
    set(hRobot, 'XData', xData, 'YData', yData);
    set(dynState.handle, 'XData', dynState.pos(:,2), 'YData', dynState.pos(:,1));

    drawnow;
    pause(framePause);
end
if isgraphics(hRobot)
    delete(hRobot);
end
end


function dynState = updateDynamicObstacles(dynState, robotRC, goalRC)
staticOccGrid = dynState.staticOccGrid;
[nRows, nCols] = size(staticOccGrid);

for i = 1:size(dynState.pos, 1)
    cur = dynState.pos(i,:);
    dynState.stepCounter(i) = dynState.stepCounter(i) + 1;

    if dynState.mode(i) == "random"
        if mod(dynState.stepCounter(i), 3) == 1
            dynState.vel(i,:) = randomDirection();
        end
        candidate = cur + dynState.vel(i,:);

    else % patrol
        candidate = cur + dynState.vel(i,:);
        if ~isDynamicCellValid(staticOccGrid, candidate, robotRC, goalRC)
            dynState.vel(i,:) = -dynState.vel(i,:);
            candidate = cur + dynState.vel(i,:);
        end
    end

    if ~isDynamicCellValid(staticOccGrid, candidate, robotRC, goalRC)
        dirs = [ -1 0; 1 0; 0 -1; 0 1; -1 -1; -1 1; 1 -1; 1 1 ];
        found = false;
        order = randperm(size(dirs,1));
        for k = order
            trial = cur + dirs(k,:);
            if isDynamicCellValid(staticOccGrid, trial, robotRC, goalRC)
                candidate = trial;
                dynState.vel(i,:) = dirs(k,:);
                found = true;
                break;
            end
        end
        if ~found
            candidate = cur;
        end
    end

    candidate(1) = min(max(candidate(1), 1), nRows);
    candidate(2) = min(max(candidate(2), 1), nCols);
    dynState.pos(i,:) = candidate;
end
end


function occ = buildDynamicOccupancy(staticOccGrid, dynState, radiusCells, robotRC, goalRC)
occ = staticOccGrid;
[nRows, nCols] = size(occ);

for i = 1:size(dynState.pos,1)
    r = dynState.pos(i,1);
    c = dynState.pos(i,2);

    for rr = max(1, r-radiusCells):min(nRows, r+radiusCells)
        for cc = max(1, c-radiusCells):min(nCols, c+radiusCells)
            occ(rr,cc) = 1;
        end
    end
end

occ(robotRC(1), robotRC(2)) = 0;
occ(goalRC(1), goalRC(2)) = 0;
end


function tf = isDynamicCellValid(staticOccGrid, rc, robotRC, goalRC)
r = rc(1);
c = rc(2);
[nRows, nCols] = size(staticOccGrid);

tf = true;
if r < 1 || r > nRows || c < 1 || c > nCols
    tf = false;
    return;
end
if staticOccGrid(r,c) == 1
    tf = false;
    return;
end
if isequal([r c], robotRC) || isequal([r c], goalRC)
    tf = false;
end
end


function dir = randomDirection()
dirs = [ -1 0; 1 0; 0 -1; 0 1; -1 -1; -1 1; 1 -1; 1 1 ];
dir = dirs(randi(size(dirs,1)), :);
end
