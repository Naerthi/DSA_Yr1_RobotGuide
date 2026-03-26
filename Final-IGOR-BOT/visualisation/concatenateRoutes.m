function fullRouteRC = concatenateRoutes(varargin)

fullRouteRC = [];

for i = 1:nargin
    seg = varargin{i};
    if isempty(seg)
        continue;
    end

    if isempty(fullRouteRC)
        fullRouteRC = seg;
    else
        if isequal(fullRouteRC(end,:), seg(1,:))
            fullRouteRC = [fullRouteRC; seg(2:end,:)]; 
        else
            fullRouteRC = [fullRouteRC; seg]; 
        end
    end
end

end