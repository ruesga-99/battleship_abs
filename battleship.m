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

            % Initialize in a random position into a white space
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
            % Verify if the ship hasn't been sunk
            Ships(i).position = moveShipTowardsEnemy(Ships(i), Ships, labB);
        end
        % Re-draw ship
        plotShip(Ships(i), colors, sunkenColor);
    end
    pause(0.2);
end

%% Auxiliarly functions

% Move ship towards the closest enemy, or randomly if blocked or no enemies
function newPosition = moveShipTowardsEnemy(ship, allShips, labB)
    % Find the closest enemy
    closestEnemy = findClosestEnemy(ship, allShips);
    
    % If there's no enemy alive, move randomly
    if isempty(closestEnemy)
        newPosition = moveRandomly(ship.position, labB);
        return;
    end
    
    % Direction vector to the closest enemy
    direction = closestEnemy.position - ship.position;
    direction = sign(direction);  % Normalize to [-1, 0, 1] for discrete moves
    
    % Calculate the new position towards the enemy
    newPosition = ship.position + direction;
    
    % Ensure the position stays within the bounds
    [m, n] = size(labB);
    newPosition = max(min(newPosition, [m, n]), [1, 1]);
    
    % If the new position is invalid, move randomly
    if ~labB(newPosition(1), newPosition(2))
        newPosition = moveRandomly(ship.position, labB);
    end
end


% Find the closest enemy ship
function closestEnemy = findClosestEnemy(ship, allShips)
    minDistance = inf;
    closestEnemy = [];
    
    for i = 1:length(allShips)
        % Skip ships of the same army or sunken ships
        if strcmp(ship.army, allShips(i).army) || allShips(i).life <= 0
            continue;
        end
        
        % Calculate the Euclidean distance to the enemy ship
        distance = norm(ship.position - allShips(i).position);
        
        % Update the closest enemy if necessary
        if distance < minDistance
            minDistance = distance;
            closestEnemy = allShips(i);
        end
    end
end

% Randomly decide a position to move
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

% Randomly move the ship to a valid position
function newPosition = moveRandomly(position, labB)
    % All possible eight directions
    moves = [0, 1; 1, 1; 1, 0; 1, -1; 0, -1; -1, -1; -1, 0; -1, 1];

    % Try up to 8 random directions to find a valid position
    for attempt = 1:8
        randomMove = moves(randi(8), :);
        tentativePosition = position + randomMove;

        % Ensure the position stays within bounds
        [m, n] = size(labB);
        tentativePosition = max(min(tentativePosition, [m, n]), [1, 1]);
        
        % If the tentative position is valid, use it
        if labB(tentativePosition(1), tentativePosition(2))
            newPosition = tentativePosition;
            return;
        end
    end
    
    % If no valid position is found, stay in the same position
    newPosition = position;
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
