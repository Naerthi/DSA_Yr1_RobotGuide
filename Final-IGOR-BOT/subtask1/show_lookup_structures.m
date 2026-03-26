function show_lookup_structures(ctx)
%SHOW_LOOKUP_STRUCTURES Open a figure that explicitly displays the linked list and KD-tree.

fig = figure('Name','Subtask 1 Lookup Structures','Color','w', ...
    'NumberTitle','off','Units','normalized','Position',[0.12 0.12 0.70 0.72]);

uicontrol(fig,'Style','text','Units','normalized', ...
    'Position',[0.04 0.93 0.42 0.04],'String','Linked List over Key Points', ...
    'BackgroundColor','w','HorizontalAlignment','left','FontWeight','bold','FontSize',12);

uicontrol(fig,'Style','text','Units','normalized', ...
    'Position',[0.53 0.93 0.42 0.04],'String','KD-tree over Key Points', ...
    'BackgroundColor','w','HorizontalAlignment','left','FontWeight','bold','FontSize',12);

listRows = linked_list_rows(ctx.linkedList);
uitable(fig,'Units','normalized','Position',[0.04 0.48 0.42 0.42], ...
    'Data',listRows, ...
    'ColumnName',{'Index','Name','Latitude','Longitude','Prev','Next'}, ...
    'RowName',[]);

kdRows = kd_tree_rows(ctx.kdTree, 1, {}, 0, 'root');
uitable(fig,'Units','normalized','Position',[0.53 0.48 0.42 0.42], ...
    'Data',kdRows, ...
    'ColumnName',{'Depth','Branch','Name','Axis','Latitude','Longitude'}, ...
    'RowName',[]);

summary = summarise_lookup_structures(ctx);
uicontrol(fig,'Style','edit','Units','normalized','Position',[0.04 0.06 0.91 0.34], ...
    'Max',30,'Min',0,'Enable','inactive','HorizontalAlignment','left', ...
    'BackgroundColor',[0.98 0.99 1.00],'FontName','Courier New','FontSize',10, ...
    'String',summary);
end

function rows = linked_list_rows(list)
rows = cell(list.length, 6);
cur = list.head;
r = 1;
while cur ~= 0 && r <= list.length
    n = list.nodes(cur);
    rows{r,1} = cur;
    rows{r,2} = char(n.name);
    rows{r,3} = n.lat;
    rows{r,4} = n.lon;
    rows{r,5} = n.prev;
    rows{r,6} = n.next;
    cur = n.next;
    r = r + 1;
end
end

function rows = kd_tree_rows(node, depth, rows, axisId, branch)
if isempty(node)
    return;
end
if node.axis == 1
    axisName = 'Longitude';
else
    axisName = 'Latitude';
end
rows(end+1,:) = {depth, branch, char(node.name), axisName, node.lat, node.lon}; 
rows = kd_tree_rows(node.left, depth+1, rows, node.axis, 'left');
rows = kd_tree_rows(node.right, depth+1, rows, node.axis, 'right');
end
