function locations = parse_dialogue(text)
    url = 'http://localhost:11434/api/chat';
    prompt = "You are a navigation assistant. Extract ONLY the FINAL intended destinations in order from this conversation. Ignore any canceled or changed plans. Return ONLY a valid JSON array of strings (e.g., [""Copper Box"", ""Stadium""]), no other text. Conversation: " + text;
    
    body = struct();
    body.model = 'qwen2.5';
    body.messages = {struct('role', 'user', 'content', prompt)};
    body.stream = false;
    
    options = weboptions('MediaType', 'application/json', 'Timeout', 20);
    
    try
        response = webwrite(url, body, options);
        content = response.message.content;
        fprintf("LLM raw output: %s\n", content);

        clean_content = strrep(content, '```json', '');
        clean_content = strrep(clean_content, '```', '');
        clean_content = strtrim(clean_content);
        
        try
            locations = jsondecode(clean_content);
            if isstring(locations) || ischar(locations), locations = cellstr(locations); end
        catch
            warning("JSON parse failed, using fallback.");
            locations = fallback_extract(text);
        end
    catch
        warning("LLM request failed, using fallback.");
        locations = fallback_extract(text);
    end
end

function locations = fallback_extract(text)

    keywords = ["Stadium","Aquatics","Copper Box","OPS","Orbit","Store"];
    locations = {};
    for k = 1:length(keywords)
        if contains(lower(text), lower(keywords(k))), locations{end+1} = keywords(k); end
    end
end

