clc
close all


% Load data
load("newMapReadings.mat");

% % FIGURE 1: GPS Track
% figure(1)
% geoplot(Position.latitude, Position.longitude, 'b', 'LineWidth', 1.5)
% geobasemap("streets")
% title('GPS Track (with 23 negative-spin events)')
% hold on

% FIGURE 2: Angular Velocity (Z)
t_all = datetime(AngularVelocity.Timestamp);

% figure(2)
% plot(t_all, AngularVelocity.Z, 'r', 'LineWidth', 1)
% hold on
% grid on
% 
% xlabel('Time')
% ylabel('Angular velocity Z')
% title('Angular Velocity (Z)')
% legend('Z')



% Prepare Angular Velocity Data
t = datetime(AngularVelocity.Timestamp);
w = AngularVelocity.Z;

% Remove invalid samples
valid = ~isnan(w) & ~isnat(t);
t = t(valid);
w = w(valid);



% Detect 4 Largest Negative Spins
[~, sortedIdx] = sort(w, 'ascend');

selectedIdx = [];
minSeparation = 200;

for i = 1:length(sortedIdx)
    candidate = sortedIdx(i);

    if isempty(selectedIdx) || all(abs(candidate - selectedIdx) > minSeparation)
        selectedIdx(end+1) = candidate; 
    end

    if numel(selectedIdx) == 23
        break
    end
end

selectedIdx = sort(selectedIdx);

eventTimes  = t(selectedIdx);
eventValues = w(selectedIdx);





% Mark Events on Angular Velocity Plot
% figure(2)
% plot(eventTimes, eventValues, 'ko', ...
%     'MarkerSize', 8, ...
%     'MarkerFaceColor', 'w')
% 
% legend('Z','23 negative-spin events')



% Match Events to GPS Samples
tPos = datetime(Position.Timestamp);

lat = zeros(23,1);
lon = zeros(23,1);
posIdx = zeros(23,1);

for k = 1:23
    [~, idxClosest] = min(abs(tPos - eventTimes(k)));

    posIdx(k) = idxClosest;
    lat(k) = Position.latitude(idxClosest);
    lon(k) = Position.longitude(idxClosest);
end


% Mark Events on GPS Map 
% figure(1)
% hold on
% geoplot(lat, lon, 'ro', ...
%     'MarkerSize', 10, ...
%     'MarkerFaceColor', 'r')
% 
% legend('Track','23 negative-spin events')



% % Display Results 
result = table( ...
    selectedIdx(:), ...
    eventTimes(:), ...
    eventValues(:), ...
    posIdx(:), ...
    lat(:), ...
    lon(:), ...
    'VariableNames', {'AV_Index','AV_Time','OmegaZ','GPS_Index','Latitude','Longitude'});

disp("Detected spin events:")
disp(result)


% Mark Events on GPS Map 
% figure(1)
% geoplot(lat, lon, 'ro', ...
%     'MarkerSize', 10, ...
%     'MarkerFaceColor', 'r')
% 
% legend('Track','4 negative-spin events')







