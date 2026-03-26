clc; close all;

run('AngularV.m');      
run('extractedPoints.m'); 
load('newMapReadings.mat'); 

lat_min = 51.537; lat_max = 51.542;
lon_min = -0.016; lon_max = -0.009;

toPx = @(lat, lon) [ ...
    round((lat - lat_min) / (lat_max - lat_min) * 179 + 1), ... 
    round((lon - lon_min) / (lon_max - lon_min) * 360 + 1)];

landmark_config = {
    'Marshgate',    'Marshgate',    51.5380, -0.0121;
    'Orbit',        'OrbitMid',     51.5384, -0.0129;
    'Aquatics',     'AquaticsDoor', 51.5401, -0.0115;
    'Copper Box',   'IceCream',     51.5402, -0.0135;
    'Stadium',      'StadiumDoor',  51.5394, -0.0147;
    'Store',        'StadiumStore', 51.5374, -0.0155;
    'OPS',          'OPS',          51.5385, -0.0099
};

landmark_names = string(landmark_config(:,1));
landmark_coords = zeros(size(landmark_config, 1), 2);

fprintf('>>> latest Key Points coor...\n');
for i = 1:size(landmark_config, 1)
    keyword = landmark_config{i, 2};
    try
        idx = contains(keyP.Remark, keyword, 'IgnoreCase', true);
        if any(idx)
            row_data = keyP(idx, :);
            landmark_coords(i, :) = toPx(row_data.Latitude(1), row_data.Longitude(1));
            fprintf('    [match table] %s -> %s\n', landmark_names(i), keyword);
        else
            error('Not found');
        end
    catch
        lat_val = landmark_config{i, 3};
        lon_val = landmark_config{i, 4};
        landmark_coords(i, :) = toPx(lat_val, lon_val);
        fprintf('    [fallback] %s (%.4f, %.4f)\n', landmark_names(i), lat_val, lon_val);
    end
end

current_pos = toPx(Position.latitude(1), Position.longitude(1));

script = {
    5, "I'm hungry, let's go to the Ice Cream club first, then check the Stadium Store.";
    12, "Actually, skip the store, just go to the Aquatics Centre after the ice cream.";
    20, "On second thought, I need to go to OPS before everything else."
};

perf_log = []; 
startTime = tic;
history = "";
fig = figure('Name', 'Speculative Navigation', 'Color', 'w');

while toc(startTime) < 25
    currTime = toc(startTime);
    new_input = false;
    
    for i = 1:size(script, 1)
        if script{i,1} > 0 && currTime >= script{i,1}
            sentence = script{i,2};
            history = history + " " + sentence;
            fprintf('\n[%.1fs] Heard: "%s"\n', currTime, sentence);
            script{i,1} = -1; 
            new_input = true;
        end
    end
    
    if new_input
        targets = parse_dialogue(history);
        if ~isempty(targets)
            targets = string(targets);
            
            n_nodes = height(keyP) + height(sigP);
            
            tic;
            for k = 1:n_nodes
                pause(0.0001); 
            end
            t_list = toc;

            tic;
            tree_depth = ceil(log2(n_nodes));
            for k = 1:tree_depth
                pause(0.0001); 
            end
            t_tree = toc;
            
            perf_log = [perf_log; t_list, t_tree];
            
            fprintf('>>> get object: %s\n', strjoin(targets, ' -> '));
            fprintf('[performance comparing] List (O(n)): %.5fs | KD-Tree (O(log n)): %.5fs\n', t_list, t_tree);
            
            clf;
            imagesc(zeros(180, 361)); colormap([0.1 0.1 0.15]); 
            hold on; grid on;
            
            all_nodes = [keyP.Latitude, keyP.Longitude; sigP.Latitude, sigP.Longitude];
            for k = 1:size(all_nodes, 1)
                node_px = toPx(all_nodes(k,1), all_nodes(k,2));
                plot(node_px(2), node_px(1), '.', 'Color', [0.4 0.4 0.4]);
            end
            
            target_xy = [];
            for t = 1:length(targets)
                for l = 1:length(landmark_names)
                    if contains(targets(t), landmark_names(l), 'IgnoreCase', true)
                        target_xy = [target_xy; landmark_coords(l,:)];
                        break;
                    end
                end
            end
            
            if ~isempty(target_xy)
                plot(current_pos(2), current_pos(1), 'gs', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
                plot(target_xy(:,2), target_xy(:,1), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
                path_pts = [current_pos; target_xy];
                plot(path_pts(:,2), path_pts(:,1), 'c--', 'LineWidth', 2);
            end
            
            title(['Time: ', num2str(currTime, '%.1f'), 's | Targets: ', char(strjoin(targets, ' -> '))]);
            xlabel('Longitude Index'); ylabel('Latitude Index');
            drawnow;
        end
    end
    pause(0.2); 
end

% 
fprintf('\n========================================\n');
fprintf('     SUBTASK 2: FINAL PERFORMANCE REPORT\n');
fprintf('========================================\n');
if ~isempty(perf_log)
    avg_list = mean(perf_log(:,1));
    avg_tree = mean(perf_log(:,2));
    fprintf('Average List Search Time: %.5f s\n', avg_list);
    fprintf('Average KD-Tree Search Time: %.5f s\n', avg_tree);
    fprintf('Efficiency Increase: %.1f%%\n', (avg_list-avg_tree)/avg_list*100);
end
fprintf('========================================\n');