function nodes = createNodesFromTables(keyP, sigP)

allP_nodes = [keyP; sigP];

nodes.names = cellstr(allP_nodes.Remark);
nodes.coords = [allP_nodes.Latitude, allP_nodes.Longitude];

% Optional: store counts
nodes.nKey = height(keyP);
nodes.nSig = height(sigP);
nodes.nTotal = height(allP_nodes);

end