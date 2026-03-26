function nodeIdx = parsePointInput(nodes, userInput)
    userInput = strtrim(userInput);

    numVal = str2double(userInput);

    if ~isnan(numVal) && isfinite(numVal) && floor(numVal) == numVal
        if numVal >= 1 && numVal <= nodes.nTotal
            nodeIdx = numVal;
            return;
        else
            nodeIdx = [];
            return;
        end
    end

    matchIdx = find(strcmpi(strtrim(nodes.names), userInput), 1);

    if ~isempty(matchIdx)
        nodeIdx = matchIdx;
    else
        nodeIdx = [];
    end
end