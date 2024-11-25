tic
clear all;
close all;
clc

%% Environment configuration

% Load and process map
lab = imread('mapBase.png'); 
labB = lab(:, :, 1) > 120;  

% Get map size
[m, n] = size(labB);

%% Agent's attributes

% Types and related colors
types = {'monitor', 'corvette', 'frigate', 'destroyer'};
colors = {[1, 0, 0], [0, 1, 0], [0, 0, 1], [1, 1, 0]};  
sunkenColor = [0.5, 0.5, 0.5];

% Corresponding Army
armies = {'ally', 'enemy'};

% firepower, speed, maneuverability, health, crew size
attributes = [10, 5, 5, 40, 50;         % monitor  
              25, 7, 4, 70, 75;         % corvette
              40, 5, 3, 80, 200;        % frigate
              50, 3, 2, 100, 300];      % destroyer

% Define ship as a structure
Ships = struct('type', [], 'army', [], 'firepower', [], 'speed', [], ...
               'maneuverability', [], 'life', [], 'crew', [], 'position', []);

%% Initial Configuration

numSteps = 100; % Number of iterations

% Amount of agents
numShipsPerArmy = 8;         
numShips = numShipsPerArmy * 2;

% Initialize agents
shipIndex = 1;
for typeIndex = 1:length(types)  % Iterate over ship types
    for armyIndex = 1:2          % Alternate over armies
        for count = 1:2          % Two ships per type per army

            Ships(shipIndex).army = armies{armyIndex};   % Assign army
            Ships(shipIndex).type = types{typeIndex};    % Assign type

            % Assign attributes according to the type of the ship
            Ships(shipIndex).firepower = attributes(typeIndex, 1);
            Ships(shipIndex).speed = attributes(typeIndex, 2);
            Ships(shipIndex).maneuverability = attributes(typeIndex, 3);
            Ships(shipIndex).life = attributes(typeIndex, 4);
            Ships(shipIndex).crew = attributes(typeIndex, 5);

            % Initialize in a random possition into a white space
            Ships(shipIndex).position = randomPosition(labB, m, n);
            shipIndex = shipIndex + 1;
        end
    end
end

%% Simulation 

for step = 1:numSteps
    % Update simulation
    cla;
    imshow(labB);
    hold on;
    
    % Move each ship
    for i = 1:numShips
        if Ships(i).life > 0
            % Verify if the ship is hasn't been sunk
            Ships(i).position = moveShip(Ships(i).position, labB);
        end
        % Re-draw ship
        plotShip(Ships(i), colors, sunkenColor);
    end
    pause(0.2);
end

%% Auxiliarly functions

% Randomly decide a possition to move
function position = randomPosition(labB, m, n)
    while true
        x = randi([2, n-1]);
        y = randi([2, m-1]);
        if labB(y, x)
            position = [y, x];
            return;
        end
    end
end

% Move ship to the randomly generated possition
function newPosition = moveShip(position, labB)
    % All possible eight directions
    moves = [0, 1; 1, 1; 1, 0; 1, -1; 0, -1; -1, -1; -1, 0; -1, 1];

    % Move to the calculated position in a random direction
    newPosition = position + moves(randi(8), :);

    % Get the size of the map (labB) 
    [m, n] = size(labB);
    % Ensure the position stays within the bounds
    newPosition = max(min(newPosition, [m, n]), [1, 1]);
    
    % If the new position is invalid, stay at the current position
    if ~labB(newPosition(1), newPosition(2))
        newPosition = position;
    end
end

%% Graph simulation

function plotShip(ship, colors, sunkenColor)

    typeIndex = find(strcmp({'monitor', 'corvette', 'frigate', 'destroyer'}, ship.type));

    % While the ship is still active, color it with the corresponding code
    if ship.life > 0
        color = colors{typeIndex};
    else
    % If the ship has been destroyed, graph it gray
        color = sunkenColor;
    end
    
    % Plot each ship with their corresponding coordinates and status
    plot(ship.position(2), ship.position(1), 'o', 'MarkerSize', 10, ...
         'MarkerFaceColor', color, 'MarkerEdgeColor', 'k');
    
    % Assign colors for army labels'
    if strcmp(ship.army, 'ally')
        textColor = 'blue';  % Blue for ALLY
    else
        textColor = 'red';   % Red for ENEMY
    end
    
    % Graph the label over each ship
    text(ship.position(2) + 5, ship.position(1), ship.army, 'Color', textColor, 'FontSize', 8);
end