function L = createGraph_Dijkstra(nodes)

neighbors = {
    [11 2 8]  % 1 Marshgate
    [10 17 8 1]  % 2 OrbitMid
    [13 14] %  3 AquaticsDoor
    [9]  % 4 IceCream
    [15 9]  % 5 StadiumDoor 
    [16]  % 6 StadiumStore
    [12]  % 7 OPS
    [1 2 16 17]  % 8 Turn-MarshgateStadium
    [4 14 5 17 10]  % 9 Splash
    [9 2 11]  % 10 OrbitRight
    [1 12]  % 11 MG-OPS-Bridge
    [11 7 13]  % 12 Turn-OPS
    [3 12]  % 13 AquaticsBottom
    [3 9]  % 14 AquaticsUpStairs
    [16 5]  % 15 MID-Stadium
    [8 15 6]  % 16 Stadium-MG-Bridge
    [2 8 9]  % 17 OrbitLeft
};

coords = nodes.coords;
L = cell(length(neighbors),1);

for i = 1:length(neighbors)
    nb = neighbors{i};
    temp = zeros(length(nb),2);

    for k = 1:length(nb)
        j = nb(k);

        lat1 = coords(i,1);
        lon1 = coords(i,2);
        lat2 = coords(j,1);
        lon2 = coords(j,2);

        d = latlonDistanceMeters(lat1, lon1, lat2, lon2);

        temp(k,:) = [j, d];
    end

    L{i} = temp;
end

end


