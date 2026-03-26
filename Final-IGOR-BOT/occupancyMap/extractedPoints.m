
clc

%disp(result)

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

allP = table(result.Latitude, result.Longitude, remark, ...
    'VariableNames', {'Latitude', 'Longitude', 'Remark'});

% disp(allP);

%% distinguish between key points and signal points

% indices of key points
keyIdx = [1 2 6 10 13 15 18 21 22];

% extract key points
keyP = allP(keyIdx, :);

% find remaining indices (signal points)
allIdx = 1:height(allP);
sigIdx = setdiff(allIdx, keyIdx);

% extract signal points
sigP = allP(sigIdx, :);

% disp("Key Points:")
% disp(keyP)
% 
% disp("Signal Points:")
% disp(sigP)


%% Key Points

% correction - to same sig figs, as this matches the accuracy of phone GPS

% The GPS measurement for the souvenir shop near the London Stadium is 
% inaccurate and lies far from its true location
% from google map: 51.53737492705889, -0.015488024790530292
keyP.Latitude(7) = 51.53737492705889;
keyP.Longitude(7) = -0.015488024790530292;

% GPS not accurate for OPS too
% from google map: 51.53852772902563, -0.009921762002202334
keyP.Latitude(9) = 51.53852772902563;
keyP.Longitude(9) = -0.009921762002202334;

% we decided to simplify the slide as a single point
% 51.53842917079937, -0.012905962023715878
keyP.Latitude(2) = 51.53842917079937;
keyP.Longitude(2) = -0.012905962023715878;
keyP.Remark(2) = "Orbit midP";

keyP(8,:) = [];
keyP(3,:) = [];

% Standardise the names

keyP.Remark = [
    "Marshgate"
    "OrbitMid"
    "AquaticsDoor"
    "IceCream"
    "StadiumDoor"
    "StadiumStore"
    "OPS"
];

% disp(keyP)

%% Signal Points
% for repeated points, take the average
% Calculate the average latitude and longitude for signal points

function sigP = takeMean(sigP, first, second)
    sigP.Latitude(first) = mean([sigP.Latitude(first), sigP.Latitude(second)]);
    sigP.Longitude(first) = mean([sigP.Longitude(first), sigP.Longitude(second)]);
end

sigP([9],:) = [];
sigP = takeMean(sigP, 2, 8);
sigP.Remark([2 8]) = "Splash";

sigP = takeMean(sigP, 5, 13);
sigP.Remark([5 13]) = "OPSTurn";

sigP = takeMean(sigP, 1, 12);
sigP.Remark([1 12]) = "MarshStadiumTurn";

sigP = takeMean(sigP, 10, 11);
sigP.Remark([10 11]) = "StadiumTurn";

sigP([13 12 11 8],:) = [];

% add signal point at 51.53876137402999, -0.013357685587769612
sigP.Latitude(10)  = 51.53876137402999;
sigP.Longitude(10) = -0.013357685587769612;
sigP.Remark(10)    = "OrbitFountainLeft";


% the turn from stadium to marshgate is off
% accoding to google map the coordinates should be
% 51.53777927895586, -0.014718683408085718
sigP.Latitude(9) = 51.53777927895586;
sigP.Longitude(9) = -0.014718683408085718;
sigP.Remark(9) = "NewStadiumTurn";


% Standardise the names
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


% %% Plot and show
% 
% figure;
% 
% % Signal Points - green
% geoscatter(sigP.Latitude, sigP.Longitude, 40, 'g', 'filled');
% hold on;
% 
% for i = 1:height(sigP)
%     text(sigP.Latitude(i), sigP.Longitude(i), ...
%         " " + sigP.Remark(i), ...
%         'Color','g', ...
%         'FontSize',8);
% end
% 
% % Key Points - red
% geoscatter(keyP.Latitude, keyP.Longitude, 70, 'r', 'filled');
% 
% for i = 1:height(keyP)
%     text(keyP.Latitude(i), keyP.Longitude(i), ...
%         " " + keyP.Remark(i), ...
%         'Color','r', ...
%         'FontSize',9, ...
%         'FontWeight','bold');
% end
% 
% legend('Signal Points','Key Points','Location','best');
% title('Key Points and Signal Points with Labels');
% 
% geobasemap streets




