function idx = findNodeByName(nodes, nameStr)

idx = find(strcmpi(nodes.names, char(nameStr)), 1);

if isempty(idx)
    error('Node name "%s" not found', nameStr);
end

end







