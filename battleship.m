tic
clear all;
close all;
clc

%% Environment configuration

% Load visual map for display
visualMap = imread('assets/mapBase.png');

% Load logical map for computation
labOg = imread('assets/mapBaseOg.png');

% Ensure dimensions match
if size(labOg, 1) ~= size(visualMap, 1) || size(labOg, 2) ~= size(visualMap, 2)
    labOg = imresize(labOg, [size(visualMap, 1), size(visualMap, 2)]);
end

% Convert logical map to binary for movement logic
labB = labOg(:, :, 1) > 120;  % Adjust threshold if necessary

% Get map size
[m, n] = size(labB);

%% Load sprites
sprites = struct();
sprites.ship1 = imresize(imread('assets/ship1.png'), 1.25);
sprites.ship2 = imresize(imread('assets/ship2.png'), 1.25);
sprites.ship3 = imresize(imread('assets/ship3.png'), 1.25);

%% Agent's attributes

% Types and corresponding sprites
types = {'ship1', 'ship2', 'ship3'};
attributes = [10, 3, 400, 30;        % ship1
              25, 2, 700, 25;        % ship2
              40, 2, 800, 20];       % ship3

% Corresponding Army
armies = {'ally', 'enemy'};

% Define ship as a structure
Ships = struct('type', [], 'army', [], 'firepower', [], 'speed', [], ...
                'life', [], 'position', [], 'maxRange',[]);

%% Initial Configuration

numSteps = 250; % Number of iterations

% Amount of agents
numShipsPerArmy = 6;         
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
            Ships(shipIndex).life = attributes(typeIndex, 3);
            Ships(shipIndex).maxRange = attributes(typeIndex, 4);

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
    imshow(visualMap); % Render the visual map as the base layer
    hold on;

    % Display current iteration
    text(10, 10, sprintf('Iteration: %d', step), 'Color', 'white', ...
         'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'black');
    
    % Simulate in each ship
    for i = 1:numShips
        if Ships(i).life > 0
            % Verify if the ship hasn't been sunk
            closestEnemyIndex = findClosestEnemy(Ships(i), Ships);
            
            if ~isempty(closestEnemyIndex)
                % Simulate combat if within range
                Ships = simulateCombat(Ships, i, closestEnemyIndex);
                Ships(i).position = moveRandomly(Ships(i).position, Ships(i).speed, labB);
            else
                % Move the ship if no combat occurs
                Ships(i).position = moveShipTowardsEnemy(Ships(i), Ships, labB);
            end
        end
        % Re-draw ship
        plotShip(Ships(i), sprites);
    end
    pause(0.1);
end

%% Combat Behaviour

% Simulate combat between ships
function Ships = simulateCombat(Ships, attackerIndex, enemyIndex)
    % Calculate the distance between the attacker and the enemy
    distance = norm(Ships(attackerIndex).position - Ships(enemyIndex).position);
    
    % Check if the distance is within half of the attacker's max range
    if distance <= Ships(attackerIndex).maxRange / 2
        % Reduce the enemy's life by the attacker's firepower
        Ships(enemyIndex).life = Ships(enemyIndex).life - Ships(attackerIndex).firepower;
    end
end

%% Movement Behaviour: approaching to nearest enemies

function newPosition = moveShipTowardsEnemy(ship, allShips, labB)
    % Find the closest enemy
    closestEnemyIndex = findClosestEnemy(ship, allShips);
    
    % If there's no enemy alive, move randomly
    if isempty(closestEnemyIndex)
        newPosition = moveRandomly(ship.position, ship.speed, labB);
        return;
    end
    
    % Direction vector to the closest enemy
    direction = allShips(closestEnemyIndex).position - ship.position;
    if norm(direction) > 0
        direction = direction / norm(direction);  % Normalize to unit vector
    end
    
    % Scale the movement by the ship's speed
    movement = round(direction * ship.speed);
    
    % Calculate the new position
    newPosition = ship.position + movement;
    
    % Ensure the position stays in the map
    [m, n] = size(labB);
    newPosition = max(min(newPosition, [m, n]), [1, 1]);
    
    % If the new position is invalid, move randomly
    if ~labB(newPosition(1), newPosition(2))
        newPosition = moveRandomly(ship.position, ship.speed, labB);
    end
end

%% Movement Behaviour: randomly moves if enemies are not found within the range

function newPosition = moveRandomly(position, speed, labB)
    % Generate random movement scaled by speed
    randomMove = round((rand(1, 2) * 2 - 1) * speed);  % Random values in [-speed, speed]
    
    % Calculate new position
    newPosition = position + randomMove;
    
    % Ensure the position stays in the map
    [m, n] = size(labB);
    newPosition = max(min(newPosition, [m, n]), [1, 1]);
    
    % If the new position is invalid, stay at the current position
    if ~labB(newPosition(1), newPosition(2))
        newPosition = position;
    end
end

%% Auxiliary Functions

% Find the index of the closest enemy ship
function closestEnemyIndex = findClosestEnemy(ship, allShips)
    minDistance = inf;
    closestEnemyIndex = [];
    
    for i = 1:length(allShips)
        % Skip ships of the same army or sunken ships
        if strcmp(ship.army, allShips(i).army) || allShips(i).life <= 0
            continue;
        end
        
        % Calculate the Euclidean distance to the enemy ship
        distance = norm(ship.position - allShips(i).position);
        
        % Update the closest enemy if within range and closer
        if distance < minDistance && distance <= ship.maxRange
            minDistance = distance;
            closestEnemyIndex = i;
        end
    end
end

% Randomly decide a position to move
function position = randomPosition(labB, m, n)
    while true
        x = randi([2, n-1]);
        y = randi([2, m-1]);
        if labB(y, x)  % Ensure the position is on water
            position = [y, x];
            return;
        end
    end
end

%% Graph simulation

function plotShip(ship, sprites)
    % Determine the sprite based on the ship type
    sprite = sprites.(ship.type);

    % Calculate the ship position
    x = ship.position(2); % Horizontal position
    y = ship.position(1); % Vertical position

    % Sprite dimensions
    spriteHeight = size(sprite, 1);
    spriteWidth = size(sprite, 2);

    % Plot the sprite
    image([x - spriteWidth / 2, x + spriteWidth / 2], ...
          [y - spriteHeight / 2, y + spriteHeight / 2], ...
          sprite, 'AlphaData', 1.0); % No transparency
end
