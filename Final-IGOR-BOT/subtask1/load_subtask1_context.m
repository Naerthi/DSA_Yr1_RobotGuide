function ctx = load_subtask1_context()
%LOAD_SUBTASK1_CONTEXT Load project data using repo-relative paths.

thisFile = mfilename('fullpath');
repoRoot = fileparts(fileparts(thisFile));
addpath(repoRoot);
addpath(fullfile(repoRoot, 'occupancyMap'));
addpath(fullfile(repoRoot, 'visualisation'));
addpath(fullfile(repoRoot, 'BfsAndDijkstra'));
addpath(fullfile(repoRoot, 'subtask1'));

[keyP, sigP, result, Position, AngularVelocity] = build_clean_points(repoRoot);

mapFile = fullfile(repoRoot, 'occupancyMap', 'occupancyGrid.mat');
mapData = load(mapFile, 'occGrid', 'cellSize_px', 'nRows', 'nCols');

ctx.repoRoot = repoRoot;
ctx.mapImage = imread(fullfile(repoRoot, 'occupancyMap', 'SatelliteImageNoLabel.png'));
ctx.occGrid = mapData.occGrid;
ctx.cellSizePx = mapData.cellSize_px;
ctx.nRows = mapData.nRows;
ctx.nCols = mapData.nCols;
ctx.mapRef.latTop = 51.5415;
ctx.mapRef.latBottom = 51.5370;
ctx.mapRef.lonLeft = -0.0160;
ctx.mapRef.lonRight = -0.0095;

ctx.keyP = keyP;
ctx.sigP = sigP;
ctx.result = result;
ctx.Position = Position;
ctx.AngularVelocity = AngularVelocity;
ctx.nodes = createNodesFromTables(keyP, sigP);
ctx.waitingIdx = getWaitingPointIndices(ctx.nodes);
ctx.waitingNames = ctx.nodes.names(ctx.waitingIdx);
ctx.graph = createGraph_Dijkstra(ctx.nodes);
ctx.linkedList = build_key_linked_list(keyP);
ctx.kdTree = build_kd_tree(keyP);
ctx.queryNames = {
    '1. How to get to point A from point B?'
    '2. What is the distance from point A to point B?'
    '3. Guide me to the k closest key points from point A'
    '4. What are the 2 closest key points to waiting area 1?'
    '5. What are the 2 closest key points to waiting area 2?'
    '6. What is the closest key point to point A?'
    '7. What is the nearest waiting point to point A?'
    '8. Show the full route: nearest waiting -> A -> B -> nearest waiting'
    '9. Compare BFS, Dijkstra, and Dijkstra+PQ for A to B'
    '10. List all key points sorted by distance from point A'
    };
end
