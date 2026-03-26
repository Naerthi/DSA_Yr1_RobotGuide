% load('newMapReadings.mat');
load('sensorlog_20260326_122130.mat');

% convert lat and lon to coordinates
lat = deg2rad(Position.latitude);
lon = deg2rad(Position.longitude);

altitude = Position.altitude;

lat0 = lat(1);
lon0 = lon(1);
h0 = altitude(1);

R = 6371000;
x = R * (lon - lon0) .* cos(lat0);
y = R * (lat - lat0);
z = altitude - h0;


timestamp = Position.Timestamp;
t = seconds(timestamp-timestamp(1));

% velocity calculation
vx = gradient(x,t);
vy = gradient(y,t);
vz = gradient(z,t);

v = sqrt(vx.^2 + vy.^2 + vz.^2);

figure;

subplot(3,1,1)
plot(t, vx)
title('v_x')
xlabel('Time (s)')
ylabel('Velocity in x-direction (m/s)')
grid on

subplot(3,1,2)
plot(t, vy)
title('v_y')
xlabel('Time (s)')
ylabel('Velocity in y-direction (m/s)')
grid on

subplot(3,1,3)
plot(t, vz)
title('v_z')
xlabel('Time (s)')
ylabel('Velocity in z-direction (m/s)')
grid on

figure;
plot(t, v)
title('Total Velocity')
xlabel('Time (s)')
ylabel('Total Velocities (m/s)')
grid on

% Filtering
% Savitzky-Golay

window = 11;
polyorder = 2;

vx_f = sgolayfilt(vx, polyorder, window);
vy_f = sgolayfilt(vy, polyorder, window);
vz_f = sgolayfilt(vz, polyorder, window);

figure;

subplot(3,1,1)
plot(t, vx, 'b'); hold on
plot(t, vx_f, 'r', 'LineWidth', 1.5)
title('v_x')
xlabel('Time (s)')
ylabel('Velocities in x-direction (m/s)')
legend('Raw','Filtered')
grid on


subplot(3,1,2)
plot(t, vy, 'b'); hold on
plot(t, vy_f, 'r', 'LineWidth', 1.5)
title('v_y')
xlabel('Time (s)')
ylabel('Velocities in y-direction (m/s)')
legend('Raw','Filtered')
grid on

subplot(3,1,3)
plot(t, vz, 'b'); hold on
plot(t, vz_f, 'r', 'LineWidth', 1.5)
title('v_z')
xlabel('Time (s)')
ylabel('Velocities in z-direction (m/s)')
legend('Raw','Filtered')
grid on

% cross-check using speed & course
course = Position.course;
speed = Position.speed;

course_rad = deg2rad(course);

vx_check = speed .* sin(course_rad);
vy_check = speed .* cos(course_rad);

figure;
plot(t, vx, t, vx_check)
legend('Computed vx','GPS vx')





























