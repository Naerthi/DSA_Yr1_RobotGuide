function [path, numSteps] = bfsShortestPath(L, startNode, goalNode)

n = length(L);
visited = false(1, n);
parent = zeros(1, n);

q = startNode;
visited(startNode) = true;

while ~isempty(q)
    current = q(1);
    q(1) = [];

    if current == goalNode
        break;
    end

    neighbors = L{current}(:,1)';

    for nb = neighbors
        if ~visited(nb)
            visited(nb) = true;
            parent(nb) = current;
            q(end+1) = nb; 
        end
    end
end

if ~visited(goalNode)
    path = [];
    numSteps = inf;
    return;
end

path = goalNode;
while path(1) ~= startNode
    path = [parent(path(1)), path];
end

numSteps = length(path) - 1;

end