function rows = format_live_timing_table(result)
%FORMAT_LIVE_TIMING_TABLE Build bottom-table rows from the current query.

if nargin < 1 || ~isstruct(result) || ~isfield(result, 'liveTimings') || isempty(result.liveTimings)
    rows = {
        'No operation run yet', '-', '-', '-'
    };
    return;
end

n = numel(result.liveTimings);
rows = cell(n, 4);
for i = 1:n
    rows{i,1} = result.liveTimings(i).operation;
    rows{i,2} = sprintf('%.4f', result.liveTimings(i).timeMs);
    if isfield(result.liveTimings(i), 'memoryText')
        rows{i,3} = result.liveTimings(i).memoryText;
    else
        rows{i,3} = '-';
    end
    rows{i,4} = result.liveTimings(i).complexity;
end
end
