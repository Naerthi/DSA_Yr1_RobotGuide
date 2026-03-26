function [path, totalDist] = dijkstraPQ(L, startNode, goalNode)

n = length(L);

dist = inf(1, n);
parent = zeros(1, n);
visited = false(1, n);

dist(startNode) = 0;

% Priority queue: [distance, node]
pq = [0, startNode];

while ~isempty(pq)

    % Extract node with smallest distance
    [~, idx] = min(pq(:,1));
    current = pq(idx, :);
    pq(idx, :) = [];  % remove it

    u = current(2);

    if visited(u)
        continue;
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

            % Add updated distance to PQ
            pq = [pq; dist(v), v];
        end
    end
end

% If unreachable
if isinf(dist(goalNode))
    path = [];
    totalDist = inf;
    return;
end

% Reconstruct path
path = goalNode;
while path(1) ~= startNode
    path = [parent(path(1)), path];
end

totalDist = dist(goalNode);

end