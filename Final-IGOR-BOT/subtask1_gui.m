function app = subtask1_gui(basePath)
%SUBTASK1_GUI Launch the Subtask 1 MATLAB GUI.

if nargin < 1 || isempty(basePath)
    basePath = fileparts(mfilename('fullpath'));
end

ctx = subtask1_build_context(basePath);

fig = figure('Name', 'Subtask 1 GUI - Robot Guide', ...
    'NumberTitle', 'off', ...
    'Color', 'w', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'Units', 'normalized', ...
    'Position', [0.03 0.05 0.94 0.88]);

leftPanel = uipanel(fig, 'Title', 'Controls', 'Units', 'normalized', 'Position', [0.01 0.26 0.26 0.73]);
centerPanel = uipanel(fig, 'Title', 'Embedded mainV visualisation', 'Units', 'normalized', 'Position', [0.28 0.26 0.46 0.73]);
rightTopPanel = uipanel(fig, 'Title', 'Linked list / KD-tree viewer', 'Units', 'normalized', 'Position', [0.75 0.55 0.24 0.44]);
rightBottomPanel = uipanel(fig, 'Title', 'Query answer', 'Units', 'normalized', 'Position', [0.75 0.26 0.24 0.28]);
bottomPanel = uipanel(fig, 'Title', 'Per-query timing / memory / Big-O', 'Units', 'normalized', 'Position', [0.01 0.01 0.98 0.23]);

% Controls 
y = 0.92; h = 0.06; gap = 0.015;

uicontrol(leftPanel, 'Style', 'text', 'String', 'Question', 'Units', 'normalized', ...
    'Position', [0.05 y 0.35 h], 'HorizontalAlignment', 'left', 'BackgroundColor', 'w', 'FontWeight', 'bold');
questionMenu = uicontrol(leftPanel, 'Style', 'popupmenu', 'String', ctx.questionList, ...
    'Units', 'normalized', 'Position', [0.42 y 0.53 h]);
y = y - h - gap;

nodeNames = ctx.nodes.names;
waitingNames = cellstr(ctx.waitingNames);
routeAlgorithms = {'BFS', 'Dijkstra', 'Dijkstra + PQ'};
lookupModes = {'Linked List', 'KD-Tree'};

uicontrol(leftPanel, 'Style', 'text', 'String', 'Point A', 'Units', 'normalized', ...
    'Position', [0.05 y 0.35 h], 'HorizontalAlignment', 'left', 'BackgroundColor', 'w', 'FontWeight', 'bold');
pointAMenu = uicontrol(leftPanel, 'Style', 'popupmenu', 'String', nodeNames, 'Units', 'normalized', 'Position', [0.42 y 0.53 h]);
y = y - h - gap;

uicontrol(leftPanel, 'Style', 'text', 'String', 'Point B', 'Units', 'normalized', ...
    'Position', [0.05 y 0.35 h], 'HorizontalAlignment', 'left', 'BackgroundColor', 'w', 'FontWeight', 'bold');
pointBMenu = uicontrol(leftPanel, 'Style', 'popupmenu', 'String', nodeNames, 'Units', 'normalized', 'Position', [0.42 y 0.53 h]);
y = y - h - gap;

uicontrol(leftPanel, 'Style', 'text', 'String', 'Waiting area', 'Units', 'normalized', ...
    'Position', [0.05 y 0.35 h], 'HorizontalAlignment', 'left', 'BackgroundColor', 'w', 'FontWeight', 'bold');
waitingMenu = uicontrol(leftPanel, 'Style', 'popupmenu', 'String', waitingNames, 'Units', 'normalized', 'Position', [0.42 y 0.53 h]);
y = y - h - gap;

uicontrol(leftPanel, 'Style', 'text', 'String', 'Algorithm', 'Units', 'normalized', ...
    'Position', [0.05 y 0.35 h], 'HorizontalAlignment', 'left', 'BackgroundColor', 'w', 'FontWeight', 'bold');
algorithmMenu = uicontrol(leftPanel, 'Style', 'popupmenu', 'String', routeAlgorithms, 'Units', 'normalized', 'Position', [0.42 y 0.53 h]);
y = y - h - gap;

uicontrol(leftPanel, 'Style', 'text', 'String', 'Lookup', 'Units', 'normalized', ...
    'Position', [0.05 y 0.35 h], 'HorizontalAlignment', 'left', 'BackgroundColor', 'w', 'FontWeight', 'bold');
lookupMenu = uicontrol(leftPanel, 'Style', 'popupmenu', 'String', lookupModes, 'Units', 'normalized', 'Position', [0.42 y 0.53 h]);
y = y - h - gap;

showRouteBox = uicontrol(leftPanel, 'Style', 'checkbox', 'String', 'Highlight route when needed', 'Value', 1, ...
    'Units', 'normalized', 'Position', [0.05 y 0.9 h], 'BackgroundColor', 'w');
y = y - h - gap;

animateBox = uicontrol(leftPanel, 'Style', 'checkbox', 'String', 'Robot playback if route exists', 'Value', 1, ...
    'Units', 'normalized', 'Position', [0.05 y 0.9 h], 'BackgroundColor', 'w');
y = y - h - gap;

runBtn = uicontrol(leftPanel, 'Style', 'pushbutton', 'String', 'Run query', 'Units', 'normalized', ...
    'Position', [0.05 y 0.42 0.08], 'FontWeight', 'bold');
resetBtn = uicontrol(leftPanel, 'Style', 'pushbutton', 'String', 'Reset view', 'Units', 'normalized', ...
    'Position', [0.53 y 0.42 0.08]);
y = y - 0.11;

summaryBox = uicontrol(leftPanel, 'Style', 'edit', 'Max', 20, 'Min', 0, 'Enable', 'inactive', ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.05 0.05 0.90 y-0.02], ...
    'BackgroundColor', [0.98 0.98 0.98], 'String', sprintf(['10 queries are preloaded.\n' ...
    'Use the dropdowns, then run a query.\n' ...
    'Routes reuse the repo BFS / Dijkstra code and draw through mainV.']));

% Embedded visualisation 
axMap = axes('Parent', centerPanel, 'Units', 'normalized', 'Position', [0.05 0.08 0.92 0.88]);

% Viewer panels 
axKD = axes('Parent', rightTopPanel, 'Units', 'normalized', 'Position', [0.08 0.50 0.84 0.44]);
listViewer = uicontrol(rightTopPanel, 'Style', 'listbox', 'Units', 'normalized', 'Position', [0.05 0.05 0.90 0.36], ...
    'FontName', 'Courier New');

answerTable = uitable(rightBottomPanel, 'Units', 'normalized', 'Position', [0.03 0.42 0.94 0.55], ...
    'ColumnName', {'Field', 'Value'}, 'ColumnWidth', {120, 230}, 'Data', {});
lookupBox = uicontrol(rightBottomPanel, 'Style', 'edit', 'Max', 20, 'Min', 0, 'Enable', 'inactive', ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.03 0.05 0.94 0.30], ...
    'BackgroundColor', [0.98 0.98 0.98]);

metricsTable = uitable(bottomPanel, 'Units', 'normalized', 'Position', [0.01 0.05 0.98 0.90], ...
    'ColumnName', {'Timestamp', 'Question', 'Lookup', 'Algorithm', 'Time (ms)', 'Approx memory (bytes)', 'Big-O'}, ...
    'ColumnWidth', {140, 300, 110, 110, 90, 140, 220}, 'Data', {});

app = struct();
app.fig = fig;
app.ctx = ctx;
app.axMap = axMap;
app.axKD = axKD;
app.listViewer = listViewer;
app.answerTable = answerTable;
app.lookupBox = lookupBox;
app.metricsTable = metricsTable;
app.summaryBox = summaryBox;
app.questionMenu = questionMenu;
app.pointAMenu = pointAMenu;
app.pointBMenu = pointBMenu;
app.waitingMenu = waitingMenu;
app.algorithmMenu = algorithmMenu;
app.lookupMenu = lookupMenu;
app.showRouteBox = showRouteBox;
app.animateBox = animateBox;
app.metricsRows = {};

setappdata(fig, 'subtask1_app', app);

set(questionMenu, 'Callback', @(~,~) onQuestionChanged());
set(lookupMenu, 'Callback', @(~,~) onViewerModeChanged());
set(runBtn, 'Callback', @(~,~) onRunQuery());
set(resetBtn, 'Callback', @(~,~) onResetView());

% initial draw
mainV('axes', axMap, 'ctx', ctx, 'showRoute', false, 'animate', false, 'title', 'Base map / route view');
refreshViewer(fig);
updateControlAvailability(fig);

if nargout == 0
    clear app;
end

    function onQuestionChanged()
        updateControlAvailability(fig);
    end

    function onViewerModeChanged()
        refreshViewer(fig);
    end

    function onResetView()
        app = getappdata(fig, 'subtask1_app');
        mainV('axes', app.axMap, 'ctx', app.ctx, 'showRoute', false, 'animate', false, 'title', 'Base map / route view');
        set(app.answerTable, 'Data', {});
        set(app.lookupBox, 'String', '');
        set(app.summaryBox, 'String', 'View reset.');
    end

    function onRunQuery()
        app = getappdata(fig, 'subtask1_app');
        req = collectRequest(app);
        tStart = tic;
        result = subtask1_run_query(app.ctx, req);
        elapsedMs = toc(tStart) * 1000;
        resultInfo = whos('result');
        reqInfo = whos('req');
        appInfo = whos('app');
        approxBytes = resultInfo.bytes + reqInfo.bytes + appInfo.bytes;

        mainV('axes', app.axMap, 'ctx', app.ctx, ...
            'showRoute', req.showRoute && ~isempty(result.routePaths), ...
            'routePaths', result.routePaths, ...
            'routeColors', result.routeColors, ...
            'routeLabels', result.routeLabels, ...
            'animate', req.animateRoute && ~isempty(result.fullRouteRC), ...
            'fullRouteRC', result.fullRouteRC, ...
            'currentNode', i_safeCurrentNode(req, app.ctx), ...
            'startNode', i_safeStartNode(req, app.ctx), ...
            'goalNode', i_safeGoalNode(req, app.ctx), ...
            'nearestWaitNode', i_safeReturnNode(result, req, app.ctx), ...
            'title', char(result.summary));

        set(app.answerTable, 'Data', normalizeTableCells(result.answerTable));
        detailText = sprintf('%s\n\n%s', char(result.lookupText), char(result.compareText));
        set(app.lookupBox, 'String', detailText);
        set(app.summaryBox, 'String', char(result.summary));

        qText = app.ctx.questionList{req.questionId};
        if isempty(result.metaRows)
            result.metaRows = {req.lookupMode, req.algorithm, '-'};
        end
        stamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
        for r = 1:size(result.metaRows,1)
            app.metricsRows(end+1, :) = {stamp, qText, result.metaRows{r,1}, result.metaRows{r,2}, sprintf('%.3f', elapsedMs), approxBytes, result.metaRows{r,3}};
        end
        set(app.metricsTable, 'Data', normalizeTableCells(app.metricsRows));
        setappdata(fig, 'subtask1_app', app);
    end
end

function req = collectRequest(app)
req = struct();
req.questionId = get(app.questionMenu, 'Value');
req.pointA = app.ctx.nodes.names{get(app.pointAMenu, 'Value')};
req.pointB = app.ctx.nodes.names{get(app.pointBMenu, 'Value')};
req.waitingName = app.ctx.waitingNames(get(app.waitingMenu, 'Value'));
algorithms = get(app.algorithmMenu, 'String');
lookupModes = get(app.lookupMenu, 'String');
req.algorithm = algorithms{get(app.algorithmMenu, 'Value')};
req.lookupMode = lookupModes{get(app.lookupMenu, 'Value')};
req.animateRoute = logical(get(app.animateBox, 'Value'));
req.showRoute = logical(get(app.showRouteBox, 'Value'));
end

function updateControlAvailability(fig)
app = getappdata(fig, 'subtask1_app');
qId = get(app.questionMenu, 'Value');
needsPointB = ismember(qId, [1 2 7]);
needsWaiting = ismember(qId, [5 6 7 8]);
needsAlgorithm = ismember(qId, [1 2 6 7 8]);
set(app.pointBMenu, 'Enable', onOff(needsPointB));
set(app.waitingMenu, 'Enable', onOff(needsWaiting));
set(app.algorithmMenu, 'Enable', onOff(needsAlgorithm));
end

function refreshViewer(fig)
app = getappdata(fig, 'subtask1_app');
lookupModes = get(app.lookupMenu, 'String');
lookupMode = lookupModes{get(app.lookupMenu, 'Value')};
if strcmpi(lookupMode, 'Linked List')
    lines = makeLinkedListLines(app.ctx);
    set(app.listViewer, 'String', lines);
    cla(app.axKD);
    set(app.axKD, 'Color', 'w');
    axis(app.axKD, 'off');
    text(app.axKD, 0.05, 0.7, 'KD-tree plot hidden in linked-list mode.', 'FontWeight', 'bold', 'Color', 'k');
    text(app.axKD, 0.05, 0.5, 'Use the list below to inspect next/prev order.', 'Interpreter', 'none', 'Color', 'k');
else
    lines = makeLinkedListLines(app.ctx);
    set(app.listViewer, 'String', lines);
    cla(app.axKD);
    hold(app.axKD, 'on');
    axis(app.axKD, 'off');
    set(app.axKD, 'Color', 'w');
    plotKDNode(app.axKD, app.ctx.keyKDTree, 0, 0, 8);
    title(app.axKD, 'Key-point KD-tree', 'Color', 'k');
end
end

function lines = makeLinkedListLines(ctx)
lines = cell(1, numel(ctx.keyLinkedList.nodes));
for i = 1:numel(ctx.keyLinkedList.nodes)
    node = ctx.keyLinkedList.nodes(i);
    prevLabel = 'HEAD';
    nextLabel = 'TAIL';
    if node.prev ~= -1
        prevLabel = char(ctx.keyLinkedList.nodes(node.prev).label);
    end
    if node.next ~= -1
        nextLabel = char(ctx.keyLinkedList.nodes(node.next).label);
    end
    lines{i} = sprintf('[%02d] %s | prev=%s | next=%s | (%.6f, %.6f)', ...
        i, char(node.label), prevLabel, nextLabel, node.lat, node.lon);
end
end

function plotKDNode(ax, node, x, y, dx)
if isempty(node)
    return;
end
plot(ax, x, y, 'ko', 'MarkerFaceColor', [0.2 0.8 0.2], 'MarkerSize', 7);
text(ax, x + 0.3, y, sprintf('%s\n[%s split]', char(node.label), ternary(node.split_axis == 0, 'x', 'y')), ...
    'Color', 'k', 'FontSize', 8);
if ~isempty(node.left)
    xL = x - dx; yL = y - 3;
    plot(ax, [x xL], [y yL], 'k-');
    plotKDNode(ax, node.left, xL, yL, dx / 1.5);
end
if ~isempty(node.right)
    xR = x + dx; yR = y - 3;
    plot(ax, [x xR], [y yR], 'k-');
    plotKDNode(ax, node.right, xR, yR, dx / 1.5);
end
end

function out = normalizeTableCells(in)
out = in;
if isempty(out)
    return;
end
for i = 1:numel(out)
    val = out{i};
    if isstring(val)
        if isscalar(val)
            out{i} = char(val);
        else
            out{i} = char(strjoin(val, ', '));
        end
    elseif ischar(val) || isnumeric(val) || islogical(val)
    else
        try
            out{i} = char(string(val));
        catch
            out{i} = char(class(val));
        end
    end
end
end

function s = onOff(tf)
if tf
    s = 'on';
else
    s = 'off';
end
end

function out = ternary(cond, a, b)
if cond
    out = a;
else
    out = b;
end
end

function nodeId = i_safeCurrentNode(req, ctx)
nodeId = find(strcmpi(ctx.nodes.names, char(req.waitingName)), 1);
if isempty(nodeId)
    nodeId = ctx.waitingIdx(1);
end
end

function nodeId = i_safeStartNode(req, ctx)
nodeId = find(strcmpi(ctx.nodes.names, char(req.pointA)), 1);
if isempty(nodeId)
    nodeId = ctx.waitingIdx(1);
end
end

function nodeId = i_safeGoalNode(req, ctx)
nodeId = find(strcmpi(ctx.nodes.names, char(req.pointB)), 1);
if isempty(nodeId)
    nodeId = i_safeStartNode(req, ctx);
end
end

function nodeId = i_safeReturnNode(result, req, ctx)
nodeId = i_safeCurrentNode(req, ctx);
if ~isempty(result.highlightNodes)
    nodeId = result.highlightNodes(end);
end
end
