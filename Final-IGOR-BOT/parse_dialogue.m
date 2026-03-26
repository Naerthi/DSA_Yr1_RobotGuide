function locations = parse_dialogue(text)
    url = 'http://localhost:11434/v1/chat/completions';
    
    % 构建针对 qwen2.5 的指令
    system_prompt = "You are a robot navigation assistant. Extract the final intended destinations from the conversation. Return ONLY a JSON array of strings. Example: ['Stadium', 'Aquatics Centre']";
    
    body = struct(...
        'model', 'qwen2.5', ...
        'messages', {{ ...
            struct('role', 'system', 'content', system_prompt), ...
            struct('role', 'user', 'content', text) ...
        }}, ...
        'stream', false ...
    );
    
    options = weboptions('MediaType', 'application/json', 'Timeout', 60);
    
    try
        response = webwrite(url, body, options);
        content = response.choices(1).message.content;
        % 去掉 AI 可能带的 Markdown 标签 (如 ```json)
        clean_content = regexprep(content, '```json|```|\[|\]', '');
        % 简单的处理：按逗号分割并清理空格和引号
        locations = strsplit(clean_content, ',');
        locations = strtrim(strrep(locations, '"', ''));
        locations = strtrim(strrep(locations, '''', ''));
    catch
        locations = {};
    end
end