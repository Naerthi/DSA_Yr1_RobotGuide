function [keyP, sigP, result, Position, AngularVelocity] = build_clean_points(repoRoot)
%BUILD_CLEAN_POINTS Build key points / signal points for Subtask 1
% Robust to:
% - repo root passed as repo root or subtask1 folder
% - Position / AngularVelocity being tables or timetables
% - slightly different time column names
%
% Output:
%   keyP, sigP : tables with Latitude, Longitude, Remark
%   result     : detected angular event table
%   Position, AngularVelocity : original loaded variables

    if nargin < 1 || isempty(repoRoot)
        repoRoot = fileparts(mfilename('fullpath'));
    end

    % If repoRoot points to /subtask1, move one level up
    if isfolder(fullfile(repoRoot, 'subtask1')) == 0 && ...
       isfile(fullfile(repoRoot, 'newMapReadings.mat')) == 0
        parentDir = fileparts(repoRoot);
        if isfile(fullfile(parentDir, 'newMapReadings.mat'))
            repoRoot = parentDir;
        end
    end

    % Candidate MAT files
    candidateFiles = {
        fullfile(repoRoot, 'newMapReadings.mat')
        fullfile(repoRoot, 'sensorlog_20260302_124459Mila.mat')
        fullfile(repoRoot, 'MarshgateTest.mat')
        fullfile(repoRoot, 'firsttry.mat')
    };

    data = [];
    chosenFile = "";

    for i = 1:numel(candidateFiles)
        if isfile(candidateFiles{i})
            tmp = load(candidateFiles{i});
            if isfield(tmp, 'Position') && isfield(tmp, 'AngularVelocity')
                data = tmp;
                chosenFile = candidateFiles{i};
                break;
            end
        end
    end

    if isempty(data)
        error(['Could not find a MAT file containing both Position and AngularVelocity. ', ...
               'Checked: %s'], strjoin(candidateFiles, ' | '));
    end

    fprintf('Using data file: %s\n', chosenFile);

    Position = data.Position;
    AngularVelocity = data.AngularVelocity;

    % ========= Extract angular velocity data =========
    tAV = getTimeVectorRobust(AngularVelocity);
    wZ  = getNumericColumnRobust(AngularVelocity, ...
        {'Z','z','AngularVelocityZ','OmegaZ','omegaZ','GyroscopeZ','gyroZ'});

    validAV = ~isnat(tAV) & ~isnan(wZ);
    tAV = tAV(validAV);
    wZ  = wZ(validAV);

    if isempty(tAV) || isempty(wZ)
        error('AngularVelocity time or Z data could not be extracted.');
    end

    % ========= Detect strongest negative-spin events =========
    [~, sortedIdx] = sort(wZ, 'ascend');

    selectedIdx = [];
    minSeparation = 200;
    targetCount = min(23, numel(sortedIdx));

    for i = 1:numel(sortedIdx)
        candidate = sortedIdx(i);
        if isempty(selectedIdx) || all(abs(candidate - selectedIdx) > minSeparation)
            selectedIdx(end+1) = candidate;
        end
        if numel(selectedIdx) >= targetCount
            break;
        end
    end

    selectedIdx = sort(selectedIdx);
    eventTimes  = tAV(selectedIdx);
    eventValues = wZ(selectedIdx);

    % ========= Extract GPS data =========
    tPos = getTimeVectorRobust(Position);
    latP = getNumericColumnRobust(Position, {'latitude','Latitude','lat','Lat'});
    lonP = getNumericColumnRobust(Position, {'longitude','Longitude','lon','Lon','lng','Lng'});

    validPos = ~isnat(tPos) & ~isnan(latP) & ~isnan(lonP);
    tPos = tPos(validPos);
    latP = latP(validPos);
    lonP = lonP(validPos);

    if isempty(tPos) || isempty(latP) || isempty(lonP)
        error('Position time/lat/lon data could not be extracted.');
    end

    % ========= Match angular events to nearest GPS sample =========
    nEvents = numel(eventTimes);
    gpsIdx = zeros(nEvents,1);
    lat = zeros(nEvents,1);
    lon = zeros(nEvents,1);

    for k = 1:nEvents
        [~, idxClosest] = min(abs(tPos - eventTimes(k)));
        gpsIdx(k) = idxClosest;
        lat(k) = latP(idxClosest);
        lon(k) = lonP(idxClosest);
    end

    result = table( ...
        selectedIdx(:), ...
        eventTimes(:), ...
        eventValues(:), ...
        gpsIdx(:), ...
        lat(:), ...
        lon(:), ...
        'VariableNames', {'AV_Index','AV_Time','OmegaZ','GPS_Index','Latitude','Longitude'});

    % ========= Labels =========
    remark = [
        "Marshgate"
        "ArcelorMittal Orbit right"
        "Marshgate-Stadium ThorntonSt Bridge lower point"
        "Splash Fountain left"
        "mid random point not close to the Orbit"
        "ArcelorMittal Orbit up"
        "bridge start from Marshgate to OPS"
        "bridgeend up from Marshgate to OPS"
        "London Aquatics Centre down"
        "London Aquatics Centre door"
        "London Aquatics Centre upper stairs"
        "Splash Fountain right"
        "Dessert Ice Cream Club"
        "Splash Fountain right - overlapped"
        "London Stadium door"
        "MID London Stadium down"
        "Lower London Stadium up"
        "West Ham United Stadium Store"
        "Lower London Stadium down"
        "Marshgate-Stadium ThorntonSt Bridge upper"
        "ArcelorMittal Orbit left"
        "One Pool Street"
        "Bridgeend low from Marshgate to One Pool Street"
    ];

    n = min(numel(remark), height(result));

    allP = table( ...
        result.Latitude(1:n), ...
        result.Longitude(1:n), ...
        remark(1:n), ...
        'VariableNames', {'Latitude','Longitude','Remark'});

    % ========= Split key points / signal points =========
    keyIdx = [1 2 6 10 13 15 18 21 22];
    keyIdx = keyIdx(keyIdx <= height(allP));

    keyP = allP(keyIdx, :);
    sigIdx = setdiff(1:height(allP), keyIdx);
    sigP = allP(sigIdx, :);

    % ========= Keep compatibility with existing manual cleanup =========
    if height(keyP) >= 9
        keyP.Latitude(7)  = 51.53737492705889;
        keyP.Longitude(7) = -0.015488024790530292;

        keyP.Latitude(9)  = 51.53852772902563;
        keyP.Longitude(9) = -0.009921762002202334;

        keyP.Latitude(2)  = 51.53842917079937;
        keyP.Longitude(2) = -0.012905962023715878;
        keyP.Remark(2)    = "OrbitMid";

        if height(keyP) >= 8
            keyP(8,:) = [];
        end
        if height(keyP) >= 3
            keyP(3,:) = [];
        end

        if height(keyP) == 7
            keyP.Remark = [
                "Marshgate"
                "OrbitMid"
                "AquaticsDoor"
                "IceCream"
                "StadiumDoor"
                "StadiumStore"
                "OPS"
            ];
        end
    end

    if height(sigP) >= 13
        % Mirror the repo's extractedPoints.m logic exactly so we end up
        % with the canonical 10 signal points expected by the graph code.
        sigP(9,:) = [];

        sigP = mergePointRows(sigP, 2, 8);
        sigP.Remark([2 8]) = "Splash";

        sigP = mergePointRows(sigP, 5, 13);
        sigP.Remark([5 13]) = "OPSTurn";

        sigP = mergePointRows(sigP, 1, 12);
        sigP.Remark([1 12]) = "MarshStadiumTurn";

        sigP = mergePointRows(sigP, 10, 11);
        sigP.Remark([10 11]) = "StadiumTurn";

        sigP([13 12 11 8],:) = [];

        % The original script intentionally grows the table back from 9 to 10
        % rows by inserting the final orbit-side signal point here.
        sigP.Latitude(10)  = 51.53876137402999;
        sigP.Longitude(10) = -0.013357685587769612;
        sigP.Remark(10)    = "OrbitLeft";

        sigP.Latitude(9)  = 51.53777927895586;
        sigP.Longitude(9) = -0.014718683408085718;
        sigP.Remark(9)    = "Stadium-MG-Bridge";

        sigP.Remark = [
            "Turn-MarshgateStadium"
            "Splash"
            "OrbitRight"
            "MG-OPS-Bridge"
            "Turn-OPS"
            "AquaticsBottom"
            "AquaticsUpStairs"
            "MID-Stadium"
            "Stadium-MG-Bridge"
            "OrbitLeft"
        ];
    end
end

function T = mergePointRows(T, i, j)
    if i <= height(T) && j <= height(T)
        T.Latitude(i)  = mean([T.Latitude(i),  T.Latitude(j)],  'omitnan');
        T.Longitude(i) = mean([T.Longitude(i), T.Longitude(j)], 'omitnan');
    end
end

function t = getTimeVectorRobust(T)
    if istimetable(T)
        rt = T.Properties.RowTimes;
        if ~isempty(rt)
            t = datetime(rt);
            return;
        end
    end

    if ~(istable(T) || istimetable(T))
        error('Expected a table or timetable, got %s.', class(T));
    end

    names = string(T.Properties.VariableNames);
    candidates = ["Timestamp","timestamp","Time","time","DateTime","Datetime","datetime"];

    for k = 1:numel(candidates)
        idx = find(strcmpi(names, candidates(k)), 1);
        if ~isempty(idx)
            raw = T.(names(idx));
            t = forceDatetimeRobust(raw);
            return;
        end
    end

    error('Missing expected time column. Available columns are: %s', strjoin(names, ', '));
end

function v = getNumericColumnRobust(T, wantedNames)
    names = string(T.Properties.VariableNames);

    for k = 1:numel(wantedNames)
        idx = find(strcmpi(names, string(wantedNames{k})), 1);
        if ~isempty(idx)
            raw = T.(names(idx));

            if isnumeric(raw)
                v = double(raw);
                return;
            elseif islogical(raw)
                v = double(raw);
                return;
            elseif iscell(raw)
                try
                    v = cellfun(@double, raw);
                    return;
                catch
                end
            elseif isstring(raw) || ischar(raw) || iscategorical(raw)
                tmp = str2double(string(raw));
                if ~all(isnan(tmp))
                    v = tmp;
                    return;
                end
            end
        end
    end

    error('Missing expected column. Wanted one of: %s. Available columns are: %s', ...
        strjoin(string(wantedNames), ', '), strjoin(names, ', '));
end

function t = forceDatetimeRobust(raw)
    if isa(raw, 'datetime')
        t = raw;
        return;
    end

    if iscell(raw)
        raw = string(raw);
    end

    if isstring(raw) || ischar(raw) || iscategorical(raw)
        t = datetime(string(raw));
        return;
    end

    if isnumeric(raw)
        raw = double(raw);
        good = raw(~isnan(raw));
        if isempty(good)
            error('Time data is numeric but contains no valid values.');
        end

        if median(good) > 1e12
            t = datetime(raw./1000, 'ConvertFrom', 'posixtime');
        else
            t = datetime(raw, 'ConvertFrom', 'posixtime');
        end
        return;
    end

    error('Unsupported time column type: %s', class(raw));
end
