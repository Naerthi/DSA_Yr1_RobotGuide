function pathRC = astarGridPath(occGrid, startRC, goalRC)

nRows = size(occGrid,1);
nCols = size(occGrid,2);

startR = startRC(1); startC = startRC(2);
goalR  = goalRC(1);  goalC  = goalRC(2);

if occGrid(startR,startC) == 1 || occGrid(goalR,goalC) == 1
    error('Start or goal lies inside an occupied cell.');
end

gScore = inf(nRows, nCols);
fScore = inf(nRows, nCols);
cameFrom = zeros(nRows, nCols, 2);

openSet = false(nRows, nCols);
closedSet = false(nRows, nCols);

gScore(startR,startC) = 0;
fScore(startR,startC) = heuristic(startR, startC, goalR, goalC);
openSet(startR,startC) = true;

dirs = [
    -1  0
     1  0
     0 -1
     0  1
    -1 -1
    -1  1
     1 -1
     1  1
];

while any(openSet(:))
    % find node in open set with minimum fScore
    openIdx = find(openSet);
    [~, minIdx] = min(fScore(openIdx));
    currentLin = openIdx(minIdx);
    [r, c] = ind2sub([nRows, nCols], currentLin);

    if r == goalR && c == goalC
        pathRC = reconstructPath(cameFrom, [goalR, goalC], [startR, startC]);
        return;
    end

    openSet(r,c) = false;
    closedSet(r,c) = true;

    for k = 1:size(dirs,1)
        rr = r + dirs(k,1);
        cc = c + dirs(k,2);

        if rr < 1 || rr > nRows || cc < 1 || cc > nCols
            continue;
        end

        if occGrid(rr,cc) == 1 || closedSet(rr,cc)
            continue;
        end

        if abs(dirs(k,1)) + abs(dirs(k,2)) == 2
            stepCost = sqrt(2);
        else
            stepCost = 1;
        end

        tentativeG = gScore(r,c) + stepCost;

        if ~openSet(rr,cc)
            openSet(rr,cc) = true;
        elseif tentativeG >= gScore(rr,cc)
            continue;
        end

        cameFrom(rr,cc,1) = r;
        cameFrom(rr,cc,2) = c;

        gScore(rr,cc) = tentativeG;
        fScore(rr,cc) = tentativeG + heuristic(rr, cc, goalR, goalC);
    end
end

error('No obstacle-free grid path found between the two nodes.');

end


function h = heuristic(r, c, gr, gc)
h = sqrt((r-gr)^2 + (c-gc)^2);
end


function pathRC = reconstructPath(cameFrom, goalRC, startRC)

pathRC = goalRC;
cur = goalRC;

while ~(cur(1) == startRC(1) && cur(2) == startRC(2))
    pr = cameFrom(cur(1), cur(2), 1);
    pc = cameFrom(cur(1), cur(2), 2);

    if pr == 0 && pc == 0
        error('Failed to reconstruct A* path.');
    end

    cur = [pr, pc];
    pathRC = [cur; pathRC]; 
end

end