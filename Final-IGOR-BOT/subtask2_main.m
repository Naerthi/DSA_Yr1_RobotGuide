% 1. 准备数据
landmarks = ["Stadium", "Aquatics Centre", "Copper Box", "Velodrome"]; % 你的 7 个地标
script = {
    3, "I think we should go first to the Stadium, then we go to Aquatics Centre.";
    10, "Wait, I changed my mind. Let's start from Copper Box instead, it's closer!";
    18, "Okay, so Copper Box first, then the Stadium."
};

% 2. 开始计时循环
startTime = tic;
history = "";
fprintf('Robot is listening...\n');

while toc(startTime) < 25
    currTime = toc(startTime);
    
    % 检查是否有新话语
    for i = 1:size(script, 1)
        if script{i,1} > 0 && currTime >= script{i,1}
            sentence = script{i,2};
            history = history + " " + sentence;
            fprintf('\n[%.1fs] Heard: "%s"\n', currTime, sentence);
            
            % 关键：调用本地 Qwen
            targets = parse_dialogue(history);
            
            if ~isempty(targets)
                fprintf('>>> Re-planning path to: %s\n', strjoin(targets, ' -> '));
                % 这里调用你的 Dijkstra 或 BFS
                % plan_path(current_pos, targets); 
            end
            
            script{i,1} = -1; % 标记已读
        end
    end
    pause(0.5);
end