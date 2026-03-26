function [rr, cc] = snapToNearestFree(occGrid, r, c)

if occGrid(r,c) == 0
    rr = r;
    cc = c;
    return;
end

nRows = size(occGrid,1);
nCols = size(occGrid,2);

maxRadius = max(nRows, nCols);

for rad = 1:maxRadius
    rMin = max(1, r-rad);
    rMax = min(nRows, r+rad);
    cMin = max(1, c-rad);
    cMax = min(nCols, c+rad);

    for rrTry = rMin:rMax
        for ccTry = cMin:cMax
            if occGrid(rrTry,ccTry) == 0
                rr = rrTry;
                cc = ccTry;
                return;
            end
        end
    end
end

error('No free cell found near requested location.');

end