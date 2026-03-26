function [path, totalDist] = dijkstraShortestPath(L, startNode, goalNode)

n = length(L);

dist = inf(1, n);
visited = false(1, n);
parent = zeros(1, n);

dist(startNode) = 0;

for iter = 1:n
    minDist = inf;
    u = -1;

    for i = 1:n
        if ~visited(i) && dist(i) < minDist
            minDist = dist(i);
            u = i;
        end
    end

    if u == -1
        break;
    end

    visited(u) = true;

    if u == goalNode
        break;
    end

    neighbors = L{u}(:,1);
    weights   = L{u}(:,2);

    for k = 1:length(neighbors)
        v = neighbors(k);
        w = weights(k);

        if ~visited(v) && dist(u) + w < dist(v)
            dist(v) = dist(u) + w;
            parent(v) = u;
        end
    end
end

if isinf(dist(goalNode))
    path = [];
    totalDist = inf;
    return;
end

path = goalNode;
while path(1) ~= startNode
    path = [parent(path(1)), path]; 
end

totalDist = dist(goalNode);

end








