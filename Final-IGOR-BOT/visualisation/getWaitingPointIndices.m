function waitingIdx = getWaitingPointIndices(nodes)

waitingNames = ["OrbitRight", "Splash"];

waitingIdx = zeros(size(waitingNames));

for i = 1:numel(waitingNames)
    waitingIdx(i) = findNodeByName(nodes, waitingNames(i));
end

end