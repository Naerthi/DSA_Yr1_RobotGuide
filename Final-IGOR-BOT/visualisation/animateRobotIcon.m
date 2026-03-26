function animateRobotIcon(ax, routeRC, iconFile, scaleFactor)

[iconImg, ~, alpha] = imread(iconFile);


if isempty(alpha)
    if size(iconImg,3) == 3
        alpha = 255 * ones(size(iconImg,1), size(iconImg,2), 'uint8');
    else
        alpha = uint8(255 * (iconImg > 0));
    end
end

iconImg = imresize(iconImg, scaleFactor);
alpha   = imresize(alpha, scaleFactor);

iconH = size(iconImg,1);
iconW = size(iconImg,2);

r = routeRC(1,1);
c = routeRC(1,2);

xData = [c - iconW/2, c + iconW/2];
yData = [r - iconH/2, r + iconH/2];

hImg = image(ax, ...
    'XData', xData, ...
    'YData', yData, ...
    'CData', iconImg, ...
    'AlphaData', double(alpha)/255);

uistack(hImg, 'top');
drawnow;

for k = 2:size(routeRC,1)
    r = routeRC(k,1);
    c = routeRC(k,2);

    xData = [c - iconW/2, c + iconW/2];
    yData = [r - iconH/2, r + iconH/2];

    set(hImg, 'XData', xData, 'YData', yData);
    drawnow;
    pause(0.03);
end

end