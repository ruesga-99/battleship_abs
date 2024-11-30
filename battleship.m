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
labB = labOg(:, :, 1) > 120;  

% Get map size
[m, n] = size(labB);

%% Load sprites
sprites = struct();
sprites.corvette = imresize(imread('assets/corvette.png'), 2.2); 
sprites.destroyer = imresize(imread('assets/destroyer.png'), 2.2);
sprites.frigate = imresize(imread('assets/frigate.png'), 2.2);
sprites.monitor = imresize(imread('assets/monitor.png'), 2.2);

%% Agent's attributes

% Types and corresponding sprites
types = {'corvette', 'destroyer', 'frigate', 'monitor'};
attributes = [10, 3, 400, 30;        % Corvette
              25, 2, 700, 25;        % Destroyer
              40, 2, 800, 20;        % Frigate
              60, 1, 1000, 15];      % Monitor

% Corresponding Army
armies = {'ally', 'enemy'};

% Define ship as a structure
Ships = struct('type', [], 'army', [], 'firepower', [], 'speed', [], ...
                'life', [], 'position', [], 'maxRange', []);

%% Initial Configuration
numIte = 350; 

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

for step = 1:numIte
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

function Ships = simulateCombat(Ships, attackerIndex, enemyIndex)
    distance = norm(Ships(attackerIndex).position - Ships(enemyIndex).position);

    if distance <= Ships(attackerIndex).maxRange / 2
        Ships(enemyIndex).life = Ships(enemyIndex).life - Ships(attackerIndex).firepower;
    end
end

%% Movement Behaviour: approaching to nearest enemies

function newPosition = moveShipTowardsEnemy(ship, allShips, labB)
    closestEnemyIndex = findClosestEnemy(ship, allShips);

    if isempty(closestEnemyIndex)
        newPosition = moveRandomly(ship.position, ship.speed, labB);
        return;
    end

    direction = allShips(closestEnemyIndex).position - ship.position;
    if norm(direction) > 0
        direction = direction / norm(direction);
    end

    movement = round(direction * ship.speed);
    newPosition = ship.position + movement;

    [m, n] = size(labB);
    newPosition = max(min(newPosition, [m, n]), [1, 1]);

    if ~labB(newPosition(1), newPosition(2))
        newPosition = moveRandomly(ship.position, ship.speed, labB);
    end
end

%% Movement Behaviour: randomly moves if enemies are not found within the range

function newPosition = moveRandomly(position, speed, labB)
    randomMove = round((rand(1, 2) * 2 - 1) * speed);
    newPosition = position + randomMove;

    [m, n] = size(labB);
    newPosition = max(min(newPosition, [m, n]), [1, 1]);

    if ~labB(newPosition(1), newPosition(2))
        newPosition = position;
    end
end

%% Auxiliary Functions

function closestEnemyIndex = findClosestEnemy(ship, allShips)
    minDistance = inf;
    closestEnemyIndex = [];

    for i = 1:length(allShips)
        if strcmp(ship.army, allShips(i).army) || allShips(i).life <= 0
            continue;
        end

        distance = norm(ship.position - allShips(i).position);

        if distance < minDistance && distance <= ship.maxRange
            minDistance = distance;
            closestEnemyIndex = i;
        end
    end
end

function position = randomPosition(labB, m, n)
    while true
        x = randi([2, n - 1]);
        y = randi([2, m - 1]);
        if labB(y, x)
            position = [y, x];
            return;
        end
    end
end

function plotShip(ship, sprites)
    sprite = sprites.(ship.type);

    x = ship.position(2);
    y = ship.position(1);

    spriteHeight = size(sprite, 1);
    spriteWidth = size(sprite, 2);

    image([x - spriteWidth / 2, x + spriteWidth / 2], ...
          [y - spriteHeight / 2, y + spriteHeight / 2], ...
          sprite, 'AlphaData', 1.0);
end