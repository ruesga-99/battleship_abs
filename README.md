# Battleship Agent-Based Simulation

This repository contains a collaborative effort of a agent-based model which simulates a naval battle scenario. 
The project is based on the Agent-Based Model proposed in this [article](An_Agent-Based_Model_Battle_of_Trafalgar.pdf).

```plaintext
                                     # #  ( )
                                  ___#_#___|__
                              _  |____________|  _
                       _=====| | |            | | |==== _
                 =====| |.---------------------------. | |====
   <--------------------'   .  .  .  .  .  .  .  .   '--------------/
     \                                                             /
      \___________________________________________________________/
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

## Funtionality
### Environment 
- Black pixels represent land and ships cannot navigate over them.
- White pixels represent water and ships will only navigate there.
- The map can be replaced for any image with similar characteristics.

![Base Map](mapBase.png)

### Agents 
| Type      | Firepower | Speed | Health | Max Range | Color  |
|-----------|-----------|-------|--------|-----------|--------|
| Monitor   | 10        | 3     | 400    | 30        | Red    |
| Corvette  | 25        | 2     | 700    | 25        | Green  |
| Frigate   | 40        | 2     | 800    | 20        | Blue   |
| Destroyer | 50        | 1     | 1000   | 15        | Yellow |

- Agents keep track of other characteristics such as their position and the nearest enemy.

- Whenever a ship is destroyed, the color will be switched to Gray.

- Ships will be assigned to different armies, being Ally (blue) and Enemy (red).

### Behaviours
**1. Random Movement:**
Ships will randomly move if no enemies are within their max range, the possible movements include 8 directions.
Movement will be influenced by their speed, which will act as a multiplier of the basic movement unit (1 px).
If combat occurs, ships will also move randomly (simulating retreat or attack). A validation will take place to
ensure no movements will occur outside the map, if thats the case, the ship will stay on its current position.

**2. Directed Movement:**
Ships will approach their enemies if there are any within their max range and if they're not sunk, for this the
nearest enemy will be calculated using the euclidean distance. Movement will be influenced by their speed, which 
will act as a multiplier of the basic movement unit (1 px).

**3. Combat:**
If a ship detects its nearest enemy within half-distance of its max range, the ship will atack it, lowering the
enemy's health according to the firepower, if a combat is held, the implicated ships will randomly move, whenever
a shio reaches 0 healthpoints it will be sunk and its color will be changed to Gray.

## Contributors 

![Alejandro](https://img.shields.io/badge/GitHub-Alejandro-181717?style=for-the-badge&logo=github)  ![Axel](https://img.shields.io/badge/GitHub-Axel-181717?style=for-the-badge&logo=github) ![Ruesga](https://img.shields.io/badge/GitHub-Ruesga-181717?style=for-the-badge&logo=github)

