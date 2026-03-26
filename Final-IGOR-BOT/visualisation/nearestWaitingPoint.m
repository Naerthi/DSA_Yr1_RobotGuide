function bestWaitNode = nearestWaitingPoint(L_dij, waitingIdx, fromNode)

bestDist = inf;
bestWaitNode = waitingIdx(1);

for i = 1:numel(waitingIdx)
    candidate = waitingIdx(i);
    [~, d] = dijkstraShortestPath(L_dij, fromNode, candidate);

    if d < bestDist
        bestDist = d;
        bestWaitNode = candidate;
    end
end

end