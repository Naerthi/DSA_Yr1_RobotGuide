function run_subtask1_interface()
%RUN_SUBTASK1_INTERFACE Subtask 1 UI for place lookup and navigation queries.
% Uses live per-query timings and memory notes in the bottom table.

ctx = load_subtask1_context();
allNames = ctx.nodes.names(:)';
waitingNames = ctx.waitingNames(:)';

fig = figure('Name', 'Tool Butler - Subtask 1', ...
    'Color', 'w', 'NumberTitle', 'off', 'Units', 'normalized', ...
    'Position', [0.04 0.06 0.92 0.84]);

axMap = axes('Parent', fig, 'Units', 'normalized', ...
    'Position', [0.04 0.08 0.54 0.84]);

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.61 0.91 0.15 0.03], 'String', 'Question', ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
queryPopup = uicontrol(fig, 'Style', 'popupmenu', 'Units', 'normalized', ...
    'Position', [0.61 0.875 0.33 0.04], 'String', ctx.queryNames, ...
    'FontSize', 10);

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.61 0.83 0.12 0.03], 'String', 'Point A', ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
pointAIdx = find(strcmpi(allNames, 'Marshgate'), 1); if isempty(pointAIdx), pointAIdx = 1; end
pointBIdx = find(strcmpi(allNames, 'OPS'), 1); if isempty(pointBIdx), pointBIdx = min(2, numel(allNames)); end
pointAPopup = uicontrol(fig, 'Style', 'popupmenu', 'Units', 'normalized', ...
    'Position', [0.61 0.795 0.16 0.04], 'String', allNames, ...
    'Value', pointAIdx, 'FontSize', 10);

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.78 0.83 0.12 0.03], 'String', 'Point B', ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
pointBPopup = uicontrol(fig, 'Style', 'popupmenu', 'Units', 'normalized', ...
    'Position', [0.78 0.795 0.16 0.04], 'String', allNames, ...
    'Value', pointBIdx, 'FontSize', 10);

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.61 0.75 0.10 0.03], 'String', 'Number k', ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
editK = uicontrol(fig, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.61 0.715 0.08 0.04], 'String', '3', 'BackgroundColor', 'w');

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.72 0.75 0.12 0.03], 'String', 'Waiting area', ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
waitingPopup = uicontrol(fig, 'Style', 'popupmenu', 'Units', 'normalized', ...
    'Position', [0.72 0.715 0.22 0.04], 'String', waitingNames, 'FontSize', 10);

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.61 0.67 0.12 0.03], 'String', 'Path algorithm', ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'left', 'FontWeight', 'bold');
algoPopup = uicontrol(fig, 'Style', 'popupmenu', 'Units', 'normalized', ...
    'Position', [0.72 0.635 0.22 0.04], ...
    'String', {'BFS','Dijkstra (normal)','Dijkstra (priority queue)'}, 'FontSize', 10);

uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.61 0.58 0.12 0.045], 'String', 'Run query', ...
    'FontWeight', 'bold', 'Callback', @runCallback);

uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.74 0.58 0.12 0.045], 'String', 'Play robot', ...
    'FontWeight', 'bold', 'Callback', @playCallback);

uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.87 0.58 0.07 0.045], 'String', 'Reset', ...
    'Callback', @resetCallback);

uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.61 0.52 0.18 0.045], 'String', 'Show KD / Linked List', ...
    'FontWeight', 'bold', 'Callback', @showStructuresCallback);

lookupBox = uicontrol(fig, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.61 0.33 0.33 0.18], 'Max', 20, 'Min', 0, ...
    'HorizontalAlignment', 'left', 'BackgroundColor', [0.96 0.99 0.96], ...
    'FontName', 'Courier New', 'FontSize', 8, 'Enable', 'inactive');

resultBox = uicontrol(fig, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.61 0.14 0.33 0.17], 'Max', 20, 'Min', 0, ...
    'HorizontalAlignment', 'left', 'BackgroundColor', [0.99 0.99 0.99], ...
    'FontName', 'Courier New', 'FontSize', 9);

complexityBox = uicontrol(fig, 'Style', 'edit', 'Units', 'normalized', ...
    'Position', [0.61 0.03 0.33 0.09], 'Max', 20, 'Min', 0, ...
    'HorizontalAlignment', 'left', 'BackgroundColor', [0.97 0.98 1.00], ...
    'FontName', 'Courier New', 'FontSize', 9, 'Enable', 'inactive');

benchTable = uitable(fig, 'Units', 'normalized', 'Position', [0.04 0.01 0.90 0.12], ...
    'ColumnName', {'Operation','Live time (ms)','Memory used','Theoretical complexity'}, ...
    'ColumnEditable', [false false false false], 'RowName', []);

blankResult = struct();
render_subtask1_map(axMap, ctx, blankResult);
setappdata(fig, 'ctx', ctx);
setappdata(fig, 'lastResult', blankResult);
set(resultBox, 'String', sprintf('Ready. Choose one of the 10 queries and press Run.\nKnown points: %s', strjoin(allNames, ', ')));
set(complexityBox, 'String', complexity_summary_text());
benchTable.Data = format_live_timing_table(blankResult);

    function runCallback(~, ~)
        inputs.pointA = string(allNames{get(pointAPopup, 'Value')});
        inputs.pointB = string(allNames{get(pointBPopup, 'Value')});
        inputs.k = max(1, round(str2double(get(editK, 'String'))));
        if isnan(inputs.k), inputs.k = 3; end
        inputs.queryId = get(queryPopup, 'Value');
        inputs.algorithmId = get(algoPopup, 'Value');
        inputs.waitingNode = ctx.waitingIdx(get(waitingPopup, 'Value'));

        try
            result = execute_subtask1_query(ctx, inputs);
            render_subtask1_map(axMap, ctx, result);
            setappdata(fig, 'lastResult', result);
            set(lookupBox, 'String', summarise_lookup_structures(ctx));
            set(resultBox, 'String', result.text);
            set(complexityBox, 'String', result.complexityText);
            benchTable.Data = format_live_timing_table(result);
        catch ME
            render_subtask1_map(axMap, ctx, struct());
            setappdata(fig, 'lastResult', struct());
            set(lookupBox, 'String', summarise_lookup_structures(ctx));
            set(resultBox, 'String', sprintf('Error: %s', ME.message));
            set(complexityBox, 'String', complexity_summary_text());
            benchTable.Data = {'Query failed', '-', '-', '-'};
        end
    end

    function playCallback(~, ~)
        result = getappdata(fig, 'lastResult');
        if isempty(result) || ~isstruct(result) || (~isfield(result, 'pathNodes') && ~isfield(result, 'secondaryPathNodes'))
            set(resultBox, 'String', 'No route to animate yet. Run a route-based query first.');
            return;
        end
        try
            play_route_animation(axMap, ctx, result);
        catch ME
            set(resultBox, 'String', sprintf('Animation error: %s', ME.message));
        end
    end

    function resetCallback(~, ~)
        blank = struct();
        render_subtask1_map(axMap, ctx, blank);
        setappdata(fig, 'lastResult', blank);
        set(resultBox, 'String', sprintf('Reset complete. Choose a query and press Run.\nKnown points: %s', strjoin(allNames, ', ')));
        set(complexityBox, 'String', complexity_summary_text());
        benchTable.Data = format_live_timing_table(blank);
    end

    function showStructuresCallback(~, ~)
        show_lookup_structures(ctx);
    end
end
