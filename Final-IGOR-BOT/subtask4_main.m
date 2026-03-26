clc

load('sensorlog_20260326_122130.mat'); 

t_gps = seconds(Position.Properties.RowTimes - Position.Properties.RowTimes(1));
v_gps = Position.speed; 


t_acc = seconds(Acceleration.Properties.RowTimes - Acceleration.Properties.RowTimes(1));
a_mag = sqrt(Acceleration.X.^2 + Acceleration.Y.^2 + Acceleration.Z.^2);
a_bias = mean(a_mag(1:min(100, length(a_mag)))); 
a_net = a_mag - a_bias;

v_acc = cumtrapz(t_acc, a_net);

v_gps_interp = interp1(t_gps, v_gps, t_acc, 'linear', 'extrap');
velocity_error = v_acc - v_gps_interp;

figure('Color', 'w', 'Position', [100, 100, 800, 850]);

subplot(3,1,1);
plot(t_acc, a_net, 'Color', [0.5 0.5 0.5]);
grid on;
title('1. Input: Net Acceleration (Gravity Removed)');
ylabel('Acc (m/s^2)');

subplot(3,1,2);
plot(t_gps, v_gps, 'b-', 'LineWidth', 2); hold on;
plot(t_acc, v_acc, 'r--', 'LineWidth', 1.5);
grid on;
title('2. Result: Velocity Comparison');
ylabel('Velocity (m/s)');
legend('GPS (Truth)', 'IMU (Integrated)', 'Location', 'northwest');

subplot(3,1,3);
area(t_acc, velocity_error, 'FaceColor', 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'r');
grid on;
title('3. Analysis: Cumulative Velocity Error (Drift)');
xlabel('Time (seconds)');
ylabel('Error (m/s)');

fprintf('Data Report\n');
fprintf('GPS max velocity: %.2f m/s\n', max(v_gps));
fprintf('IMU Integrated max speed: %.2f m/s\n', max(v_acc));
fprintf('Error: %.2f m/s\n', velocity_error(end));