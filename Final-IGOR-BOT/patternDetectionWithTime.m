clc
close all

% Load data
load('newMapReadings.mat');
% load('sensorlog_20260326_122130.mat');

% Convert latitude and longitude to local Cartesian coordinates
lat = deg2rad(Position.latitude);
lon = deg2rad(Position.longitude);
altitude = Position.altitude;

lat0 = lat(1);
lon0 = lon(1);
h0 = altitude(1);

R = 6371000; % Earth radius in metres

x = R * (lon - lon0) .* cos(lat0);
y = R * (lat - lat0);
z = altitude - h0;

% Time vector
timestamp = Position.Timestamp;
t = seconds(timestamp - timestamp(1));

% Raw velocity calculation
vx = gradient(x, t);
vy = gradient(y, t);
vz = gradient(z, t);

% Smooth velocity using Savitzky-Golay filter
window = 11;
polyorder = 2;

vx_f = sgolayfilt(vx, polyorder, window);
vy_f = sgolayfilt(vy, polyorder, window);
vz_f = sgolayfilt(vz, polyorder, window);

% Smoothed speed magnitude
v_f = sqrt(vx_f.^2 + vy_f.^2 + vz_f.^2);

% Smoothed acceleration
a_f = gradient(v_f, t);
a_f = sgolayfilt(a_f, polyorder, window);

% Smoothed turning rate
course_rad = unwrap(deg2rad(Position.course));
course_f = sgolayfilt(course_rad, polyorder, window);
turn_rate_f = gradient(course_f, t);
turn_rate_f = sgolayfilt(turn_rate_f, polyorder, window);

% Mask unrealistic spikes above 3.5 m/s
mask = v_f <= 3.5;

t_m = t(mask);
vx_m = vx_f(mask);
vy_m = vy_f(mask);
vz_m = vz_f(mask);
v_m = v_f(mask);
a_m = a_f(mask);
turn_m = turn_rate_f(mask);

% Thresholds
v_stop_th = 0.2;   % below this = stop
v_slow_th = 0.9;   % upper limit for slow walking
v_fast_th = 1.34;  % based on <30 average walking speed: above this = fast walking
a_acc_th  = 0.15;  % accelerating threshold
turn_th   = 0.3;   % turning threshold (rad/s)


% Preliminary pattern detection on masked smoothed data
N = length(t_m);
state = strings(N,1);

for i = 1:N
    if v_m(i) < v_stop_th
        state(i) = "Stop";

    elseif abs(turn_m(i)) > turn_th
        state(i) = "Turning";

    elseif a_m(i) > a_acc_th
        state(i) = "Accelerating";

    elseif v_m(i) > v_fast_th
        state(i) = "Fast";

    elseif v_m(i) < v_slow_th
        state(i) = "Slow walk";

    else
        state(i) = "Normal";
    end
end

% Extend accelerating periods so they last longer
% Mark raw acceleration points first
acc_raw = a_m > a_acc_th;

% Fill small gaps so nearby acceleration points become one longer period
gap_samples = 8;   % increase this if you want even longer acceleration blocks
for i = 2:length(acc_raw)-1
    if ~acc_raw(i)
        left = max(1, i-gap_samples);
        right = min(length(acc_raw), i+gap_samples);
        if any(acc_raw(left:i-1)) && any(acc_raw(i+1:right))
            acc_raw(i) = true;
        end
    end
end

% Enforce a minimum duration for acceleration
min_acc_duration = 2.0; % seconds
change_idx = [1; find(diff(acc_raw) ~= 0) + 1; length(acc_raw)+1];

acc_final = false(size(acc_raw));

for k = 1:length(change_idx)-1
    s = change_idx(k);
    e = change_idx(k+1)-1;

    if acc_raw(s)
        duration_seg = t_m(e) - t_m(s);
        if duration_seg >= min_acc_duration
            acc_final(s:e) = true;
        end
    end
end

% Overwrite state with improved acceleration periods,
% but keep Stop and Turning priority
for i = 1:N
    if state(i) ~= "Stop" && state(i) ~= "Turning"
        if acc_final(i)
            state(i) = "Accelerating";
        elseif v_m(i) > v_fast_th
            state(i) = "Fast";
        elseif v_m(i) < v_slow_th
            state(i) = "Slow walk";
        else
            state(i) = "Normal";
        end
    end
end

% Time step for duration calculation
dt = diff(t_m);
dt = [dt; dt(end)];

% Total time and percentage spent in each phase
states_list = ["Stop","Slow walk","Normal","Turning","Accelerating","Fast"];
total_time = zeros(length(states_list),1);

for k = 1:length(states_list)
    idx = state == states_list(k);
    total_time(k) = sum(dt(idx));
end

total_duration = sum(dt);
percentage = 100 * total_time / total_duration;

% Display summary
fprintf('\nTime spent in each phase\n');
for k = 1:length(states_list)
    fprintf('%-15s : %.2f s (%.2f%%)\n', states_list(k), total_time(k), percentage(k));
end

% Detect continuous periods
change_idx = [1; find(state(2:end) ~= state(1:end-1)) + 1];

period_state = strings(0,1);
period_start_time = [];
period_end_time = [];
period_duration = [];

for i = 1:length(change_idx)
    s = change_idx(i);

    if i < length(change_idx)
        e = change_idx(i+1) - 1;
    else
        e = length(state);
    end

    this_state = state(s);

    if this_state ~= "Normal"
        period_state(end+1,1) = this_state;
        period_start_time(end+1,1) = t_m(s);
        period_end_time(end+1,1) = t_m(e);
        period_duration(end+1,1) = t_m(e) - t_m(s);
    end
end

% Display detected periods
fprintf('\nDetected periods for the 5 phases\n');
for i = 1:length(period_state)
    fprintf('%-15s : start = %.2f s, end = %.2f s, duration = %.2f s\n', ...
        period_state(i), period_start_time(i), period_end_time(i), period_duration(i));
end

% Plot 1: Smoothed speed with detected phase points
figure;
plot(t_m, v_m, 'k', 'LineWidth', 0.5); hold on

idx_stop = state == "Stop";
idx_slow = state == "Slow walk";
idx_fast = state == "Fast";
idx_acc  = state == "Accelerating";
idx_turn = state == "Turning";

plot(t_m(idx_stop), v_m(idx_stop), 'ro', 'DisplayName', 'Stop');
plot(t_m(idx_slow), v_m(idx_slow), 'go', 'DisplayName', 'Slow walk');
plot(t_m(idx_fast), v_m(idx_fast), 'mo', 'DisplayName', 'Fast');
plot(t_m(idx_acc),  v_m(idx_acc),  'co', 'DisplayName', 'Accelerating');
plot(t_m(idx_turn), v_m(idx_turn), 'yo', 'DisplayName', 'Turning');

xlabel('Time (s)');
ylabel('Velocity (m/s)');
title('Pattern Detection Based on Smoothed and Masked Data');
legend('Smoothed Velocity', 'Stop', 'Slow walk', 'Fast', 'Accelerating', 'Turning');
grid on;

% Plot 2: Phase timeline
figure;
hold on

for i = 1:length(period_state)

    x_seg = [period_start_time(i), period_end_time(i)];
    y_seg = [1, 1];

    state_i = period_state(i);

    switch state_i
        case "Stop"
            c = 'r';
        case "Slow walk"
            c = 'g';
        case "Normal"
            c = 'b';
        case "Turning"
            c = 'y';
        case "Accelerating"
            c = 'c';
        case "Fast"
            c = 'm';
        otherwise
            c = 'k';
    end

    plot(x_seg, y_seg, 'Color', c, 'LineWidth', 50); 
end

xlabel('Time (s)');
title('Detected Motion Phases Over Time');
ylim([0.5 1.5]);
yticks([]);
grid on;

% Plot 3: Total time in each phase
figure;
bar(categorical(states_list), total_time);
ylabel('Total Time (s)');
title('Total Time Spent in Each Phase');
grid on;

% Plot 4: Percentage time in each phase
labels = strings(length(states_list),1);
for i = 1:length(states_list)
    labels(i) = sprintf('%s (%.1f%%)', states_list(i), percentage(i));
end

figure;
pie(percentage, labels);
title('Percentage of Time Spent in Each Phase');


