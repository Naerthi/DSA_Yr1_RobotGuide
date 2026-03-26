clc

% Build nodes
nodes = createNodesFromTables(keyP, sigP);

% Build graphs
L_bfs = createGraph_BFS(nodes);
L_dij = createGraph_Dijkstra(nodes);

% Choose start and goal from keyP
startName = "Marshgate";
goalName  = "OPS";

% Or userinput
% startName = input('Enter start key point name: ', 's');
% goalName  = input('Enter goal key point name: ', 's');

startNode = findNodeByName(nodes, startName);
goalNode  = findNodeByName(nodes, goalName);

% BFS
[path_bfs, steps_bfs] = bfsShortestPath(L_bfs, startNode, goalNode);

% Dijkstra
[path_dij, dist_dij] = dijkstraShortestPath(L_dij, startNode, goalNode);

% Display BFS result
disp('BFS result:')
disp('indices:')
disp(path_bfs)

disp('points:')
disp(nodes.names(path_bfs))

fprintf('Number of steps: %d\n\n', steps_bfs);

% Display Dijkstra result
disp('Dijkstra result:')
disp('indices:')
disp(path_dij)

disp('points:')
disp(nodes.names(path_dij))

fprintf('Total distance: %.2f m\n', dist_dij);




