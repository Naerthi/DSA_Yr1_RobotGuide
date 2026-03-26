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
load('occupancyGrid.mat', 'occGrid', 'cellSize_m', 'nRows', 'nCols');

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
        [path_to_start_nodes, dist_to_start] = dijkstraShortestPath(L_dij, currentNode, startNode);
    else
        path_to_start_nodes = startNode;
        dist_to_start = 0;
    end

    [path_to_goal_nodes, dist_to_goal] = dijkstraShortestPath(L_dij, startNode, goalNode);

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

    if isempty(seg1)
        fullRouteRC = seg2;
    elseif isempty(seg2)
        fullRouteRC = seg1;
    else
        fullRouteRC = [seg1; seg2(2:end,:)];
    end

    fig = figure('Name', 'Robot Navigation', 'Color', 'w');
    ax = axes(fig);

    plotOccupancyAndGraph(ax, occGrid, nodes, mapRef, L_dij, waitingIdx, currentNode, startNode, goalNode, []);

    if firstMission
        h1 = plotNodePath(ax, nodes, mapRef, occGrid, path_to_start_nodes, 'c-', 2.5);
        set(h1, 'DisplayName', 'Waiting Point to Starting Point');
    end

    h2 = plotNodePath(ax, nodes, mapRef, occGrid, path_to_goal_nodes, 'r-', 3.0);
    set(h2, 'DisplayName', 'Starting Point to Destination');

    animateRobotIcon(ax, fullRouteRC, 'igor.jpeg', 0.04);

    fprintf('Safely arrived from %s to %s\n', nodes.names{startNode}, nodes.names{goalNode});

    currentNode = goalNode;
    firstMission = false;

    validReply = false;
    while ~validReply
        reply = upper(strtrim(input('Any other need for help? Key in YES or NO to tell IGOR the GOAT: ', 's')));

        if (strcmpi(reply, 'YES'))
            fprintf('\nPlease enter your next DESTINATION.\n\n');
            validReply = true;

        elseif (strcmpi(reply, 'NO'))
            nearestWaitNode = nearestWaitingPoint(L_dij, waitingIdx, currentNode);
            [path_to_wait_nodes, dist_to_wait] = dijkstraShortestPath(L_dij, currentNode, nearestWaitNode);

            fprintf('\nDestination -> Nearest waiting point distance: %.2f m\n', dist_to_wait);
            disp(nodes.names(path_to_wait_nodes));

            seg3 = buildDetailedRoute(path_to_wait_nodes, nodes, mapRef, occGrid);

            fig2 = figure('Name', 'Return to waiting point', 'Color', 'w');
            ax2 = axes(fig2);
            plotOccupancyAndGraph(ax2, occGrid, nodes, mapRef, L_dij, waitingIdx, currentNode, currentNode, currentNode, nearestWaitNode);

            h3 = plotNodePath(ax2, nodes, mapRef, occGrid, path_to_wait_nodes, 'm-', 2.5);
            set(h3, 'DisplayName', 'Destination to Waiting Point');

            animateRobotIcon(ax2, seg3, 'igor.jpeg', 0.05);

            fprintf('IGOR returned to waiting point: %s, Please say THANK YOU!\n', nodes.names{nearestWaitNode});

            missionActive = false;
            validReply = true;

        else
            fprintf('Invalid input. Please enter YES or NO\n');
        end
    end
end









