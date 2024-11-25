tic
clear all;
close all;
clc

lab = imread('mapBase.png');
labB = lab(:,:,1);

%visualizar el ambiente
mesh(labB);
xlabel('X');
ylabel('Y');
zlabel('Navegabilidad');
toc

%se define 4 tipos de navios disitntos con caracteristicas propias
% OJO!!! labB es el ambiente binarizado 
[m, n] = size(labB); %dimensiones del mapa

%cuantos barcos meto en el modelo
numNavios = 4;

%estructura para los barcos (agentes)
Ships(numNavios).tipo = '';
Ships(numNavios).poderDisparo = 0;%a
Ships(numNavios).velocidad = 0;%b
Ships(numNavios).maniobrabilidad = 0;%c
Ships(numNavios).barraVida = 0;%d
Ships(numNavios).posicion = [0, 0];

%types de barcos y  atributos
types = {'pesquero', 'fragata', 'submarino', 'destructor'};
attributes = [ ...
    0, 3, 2, 50;  % Pesquero: a,b, c, d
    40, 5, 4, 80; % Fragata
    60, 4, 3, 70; % Submarino
    50, 3, 2, 100]; % Destructor

%inicialización de cada barco en posiciones válidas
for i = 1:numNavios
    %asignar el tipo y atributos al barco
    Ships(i).tipo = types{i};
    Ships(i).poderDisparo = attributes(i, 1);
    Ships(i).velocidad = attributes(i, 2);
    Ships(i).maniobrabilidad = attributes(i, 3);
    Ships(i).barraVida = attributes(i, 4);
    
    %generar posición aleatoria dentro del mapa
    x = randi([2, n-1]);
    y = randi([2, m-1]);
    
    %Checo que la posición sea válida para ser navegable (no hay tierra)
    while labB(y, x) == 0 %mientras la posición del barco este en zona negra
        x = randi([2, n-1]); % cambia la posición aleatoria
        y = randi([2, m-1]);
    end
    
    %asigna una posición al barco
    Ships(i).posicion = [y, x];
end

%muestra las posiciones
disp('Posiciones:');
for i = 1:numNavios %iterar sobre el numero de navios accediendo a sus atributos y posiciones
    fprintf('%s: [%d, %d] - Vida: %d\n', Ships(i).tipo, Ships(i).posicion, Ships(i).barraVida);
    %jalatelos prro y me los muestras en la terminal con su formato y vida
end
