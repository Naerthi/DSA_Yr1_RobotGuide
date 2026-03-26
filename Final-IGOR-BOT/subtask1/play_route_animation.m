function play_route_animation(ax, ctx, result)
%PLAY_ROUTE_ANIMATION Animate the robot over the selected route on the generated map.
% Uses the repo's robot icon if available, otherwise falls back to a marker.

xy = build_animation_xy(ctx, result);
if size(xy,1) < 2
    return;
end

routeRC = [xy(:,2), xy(:,1)]; % [row, col]
iconFile = fullfile(ctx.repoRoot, 'visualisation', 'igor.jpeg');

hold(ax, 'on');
if isfile(iconFile)
    try
        animateRobotIcon(ax, routeRC, iconFile, 0.08);
        return;
    catch
        % fall back below
    end
end

robotH = plot(ax, xy(1,1), xy(1,2), 'p', ...
    'MarkerSize', 16, 'MarkerFaceColor', [0.15 0.85 1.0], ...
    'MarkerEdgeColor', 'k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
trailH = plot(ax, xy(1,1), xy(1,2), '-', ...
    'Color', [0.10 0.95 0.95], 'LineWidth', 2.0, 'HandleVisibility', 'off');

for k = 2:size(xy,1)
    set(robotH, 'XData', xy(k,1), 'YData', xy(k,2));
    set(trailH, 'XData', xy(1:k,1), 'YData', xy(1:k,2));
    drawnow;
    pause(0.04);
end
end

function xy = build_animation_xy(ctx, result)
paths = {};
if isfield(result, 'secondaryPathNodes') && ~isempty(result.secondaryPathNodes)
    paths = result.secondaryPathNodes;
elseif isfield(result, 'pathNodes') && ~isempty(result.pathNodes)
    paths = {result.pathNodes};
end

xy = [];
for i = 1:numel(paths)
    p = paths{i};
    if isempty(p)
        continue;
    end
    segXY = zeros(numel(p), 2);
    for j = 1:numel(p)
        [r, c] = latlonToGridRC(ctx.nodes.coords(p(j),1), ctx.nodes.coords(p(j),2), ctx.mapRef, ctx.occGrid);
        segXY(j,:) = [c, r];
    end
    segXY = interpolate_xy(segXY, 16);
    if ~isempty(xy) && ~isempty(segXY)
        segXY = segXY(2:end,:);
    end
    xy = [xy; segXY];
end
end

function xyOut = interpolate_xy(xyIn, nPerSeg)
if size(xyIn,1) <= 1
    xyOut = xyIn;
    return;
end
xyOut = [];
for i = 1:size(xyIn,1)-1
    xSeg = linspace(xyIn(i,1), xyIn(i+1,1), nPerSeg+1)';
    ySeg = linspace(xyIn(i,2), xyIn(i+1,2), nPerSeg+1)';
    seg = [xSeg ySeg];
    if i > 1
        seg = seg(2:end,:);
    end
    xyOut = [xyOut; seg];
end
end
