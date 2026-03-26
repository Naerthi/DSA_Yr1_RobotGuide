function node = createDNode(lat, lon, label, type, next, prev)
    node = struct( ...
        "lat", lat, ...
        "lon", lon, ...
        "label", label, ...
        "type", type, ...
        "next", next, ...
        "prev", prev);
end

function [head, tail, list] = buildDListFromTable(T, type)
    n = height(T);

    if n == 0
        head = -1; tail = -1; list = [];
        return;
    end

    list(1) = createDNode(T{1,1}, T{1,2}, string(T{1,3}), type, -1, -1);
    head = 1;
    tail = 1;

    for i = 2:n
        list(i) = createDNode(T{i,1}, T{i,2}, string(T{i,3}), type, -1, tail);
        list(tail).next = i;
        tail = i;
    end
end

function printList(list, head)
    current = head;
    while current ~= -1
        fprintf('%s (%s) -> (%.5f, %.5f)\n', ...
            list(current).label, list(current).type, ...
            list(current).lat, list(current).lon);
        current = list(current).next;
    end
end

[keyHead, keyTail, keyList] = buildDListFromTable(keyP, "key");
[sigHead, sigTail, sigList] = buildDListFromTable(sigP, "signal");

disp("Key Points:");
printList(keyList, keyHead);

disp("Signal Points:");
printList(sigList, sigHead);