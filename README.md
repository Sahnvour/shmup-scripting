# SHMµP scripting documentation

**SHMµP** features an easy way to create new enemies and waves by scripting. In fact, all the enemies and waves present in the game are scripts. This allows quick development and debugging : no compilation required, and even real-time reloading of scripts.

The scripts are written in Lua, an interpreted language chosen for its speed and low memory footprint. Credit must be given to Tomaka17 for his awesome [LuaWrapper](https://github.com/tomaka/luawrapper) and to [LuaJIT](http://luajit.org/) for its incredible performance. Thanks!


## 1. General information

### 1.1 Scripting structure
A script (be it an enemy or a wave) is a simple text file with `.lua` extension. The structure is based on the filesystem, so a script name must be unique. They are executed in a sandbox, to avoid potential security problems.

This means two things :
- the available functions are very limited, but it should not be a problem. In any case, tell me if something is missing.
- Each script (wave or enemy) has its own private environment, so you can define functions and global variables.

Note that this does not prevent the scripts from pushing the CPU or memory too hard.


### 1.2 How (re)loading works
Loading is achieved in 4 steps:

1. First, the game binds the Lua api. This will allow scripts to access game functions and data.
2. Then the main script is loaded and executed: `EnemyManager.lua`. It defines a few functions and tables necesary to wave and enemy loading, and game management. **This is part of the game implementation, you should not alter this file.**
3. Enemy scripts are loaded
4. Wave scripts are loaded and executed

The enemy scripts are not executed yet, so this means only syntax error can be spotted at that time. The execution of the wave scripts will not call the functions defined in it, just run through the file. This is for initializing variables and such.


## 2. Enemy scripting
Enemy scripts are located in `resources/scripts/enemy_patterns/`.

An enemy script is a *pattern*: it defines how the enemy will be and behave. Enemies in game are *instances* of a pattern. They share the logic of the pattern, but have distinct executions of it.

### Building the enemy
Enemies follow the same rules that the player when building a ship, except that they have one more block slot.

Every enemy pattern is expected to define a global table named `BLOCKS` containing the values for the 25 blocks that a ship can have. Not more, not less, and in index range `[0,24]`.
Not all the blocks have to be filled, this is why there is the `None` block along with the colors. They are all accessible through the `blocks` table defined in the API.

### Mandatory functions
Enemy patterns require the definition of 2 functions : `init` and `update`. They have only one argument: the enemy object (instance of the pattern) to handle.

#### 1. `init`
The `init` function is called only once, at the creation of every enemy. This happens during the generation of enemies by a wave, and the enemy passed as argument is pretty much initialized already. Its position (according to the wave), blocks and hitboxes have been setup. Its skills have been determined by the influence of its blocks, so what's left ?

You can set his life (and maxLife), change its speed or init other things for your algorithm.

No return value required.

#### 2. `update`
The update function is called at every frame, for every enemy **on screen**. Others just move plain left at a constant speed.

This is where the logic for the enemy's behaviour belongs.

No return value required.

### Guidelines & tips
- With a lot of enemies on screen, updating them could become quite heavy. Although in its current state the game still has a lot of time for running scripts, beware of not wasting CPU power.
- Although you can set the position of an enemy directly, this is not recommended for dealing with smooth movement. Setting position will result in a teleport; use the speed of the enemy instead. The game will move the enemies in relation to their speed **and** their bonuses, if any (ie. blue blocks are handled automatically).
- Enemies usually go left. Speed and position are absolute, so the X speed of enemies should therefore be **negative**.
- The base speed of objects in game is `120`.
- Your scripts don't need to check fire-rate of the cannons, this is handled directly by the game too. So `enemy:shoot()` all you want.

### Planned features
- Ship rotation
- Cannon rotation: shoot at different angles and rotate them
- Individual cannon handling: choose what cannon to fire

## 3. Wave scripting
Wave scripts are located in `resources/scripts/wave_patterns/`.

### Generating enemies
A wave pattern must provide a `generate()` function. This function is mandatory and responsible for generating all the enemies making up the wave. It is called every time this particular wave is selected.

The `generate()` function is expected to return a table containing:

- `.name -> string` the name of the wave, only used for display in debug log
- `.enemies -> table` an array of *light enemies*, **all** iterable through `ipairs()`.

*This is subject to change slightly in later releases (especially the name thing).*

A *light enemy* simply describes the type of enemy to create, and where to put it. In other words, it is a table composed of :

- `.x -> float` x position of the enemy
- `.y -> float` y position of the enemy
- `.pattern -> int` pattern id of the enemy

Check out the wave `random.lua` for a very simple example.

### `require`

It is possible for waves to require the presence of specific enemy patterns. This is done through the `require` function. It accepts a string or a table of strings as arguments, and checks that the corresponding enemy pattern is loaded in the game. In case of a missing pattern, an error is reported to the user with indications.

The `require` function returns an integer for a single string, or a table with pattern names as keys and corresponding pattern ids as values for multiple strings. It can (and must) be stored in global scope (ie not inside the `generate()` function) to perform it only once when loading the wave.

Usage example:

We assume the following pattern environment
- scripts/
	- enemy_patterns/
		- enemy1.lua
		- myEnemy.lua
		- enemy2.lua
		- enemy36.lua
	- wave_patterns/
		- myWave.lua

Inside `myWave.lua`:

```lua
-- myWave.lua

local buddy = require 'myEnemy'

function generate()
	...
end
```

Or, when requiring multiple enemy patterns:

```lua
-- myWave.lua

local fellas = require { 'myEnemy', 'enemy36' }

function generate()
	...
	LOG("enemy36 id is:" .. fellas.enemy36)
end
```

## 4. API
The is the list of all variables, tables and functions that are available to scripts in the SHMµP API. They are all **read-only**, as modifying them could break the game (the scripting, more precisely). So please, don't do it.

### Time
`Time` objects represent time in-game and are directly mapped to `sf::Time`.

#### Constructors
They can be constructed with two functions :

- `seconds(float) -> Time`
- `milliseconds(float) -> Time`

#### Member functions
- `:asSeconds() -> float` returns the time as a number of seconds
- `:asMilliseconds() -> float` returns the time as a number of milliseconds
- `:since(Time) -> Time` computes the difference between two time points

-------------------------------

### Vec2
`Vec2` objects represent a two-dimensional floating-point vector and are directly mapped to `sf::Vector2f`.

#### Constructors
`Vec2(float, float) -> Vec2`

#### Members

- `.x -> float` the first coordinate of the vector
- `.y -> float` the second coordinate of the vector

-------------------------------

### Hitbox
`Hitbox` objects reprsent 2D hitboxes, ie. rectangles.

#### Constructors
`Hitbox(float, float, float, float) -> Hitbox` constructs a `Hitbox` object from *top*, *left*, *width* and *height* coordinates.

#### Members
- `.left -> float` left coordinate
- `.top -> float` top coordinate
- `.width -> float` width of the rectangle
- `.height -> float` height of the rectangle

-------------------------------

### Game state :
Game state is accessible through the `game` table. It has the following members:

- `.time -> Time` current time
- `.difficulty -> float` current difficulty (starts at 1.0, increases slowly)
- `.world -> Hitbox` a `Hitbox` representing the visible (rendered on screen) world.


### Player state :
Player state is accessible through the `player` table. It has the following members:

- `.skill -> float`	current skill-o-meter value
- `.position -> Vec2` current position of the ship

-------------------------------

### Enemy class

#### Member functions
All the functions callable on enemy objects are listed here for the sake of completness, but they are not all useful in scripts.

- `:getPosition() -> Vec2` get the position of the enemy
- `:setPosition(Vec2)` set the position of the enemy
- `:getLife() -> int` get the life level of the enemy
- `:setLife(int)` set the life level of the enemy, can get over `maxLife`
- `:getMaxLife() -> int` get the maximum life of the enemy
- `:setMaxLife(int)` set the maximum life of the enemy
- `:getSpeed() -> Vec2` get the speed of the enemy
- `:setSpeed(Vec2)` set the speed of the enemy
- `:setSpeedX(float)` set the speed on X axis
- `:setSpeedY(float)` set the speed on Y axis
- `:getScript() -> int` get the script id of the enemy
- `:setScript(int)` set the script id of the enemy (**breaks scripting**)
- `:getSkill() -> float` get the skill level of the enemy
- `:getId() -> int` get the internal id of the enemy
- `:updateSkills()` updates the characteristices of the enemy, useful after modifying blocks
- `:updateHitboxes()` updates the hitboxes of the enemy, useful after modifying blocks
- `:shoot()` request all cannons to fire, but the game will determine if they can or cannot, by the cooldown
- `:heal()` use a heal block if there is any
- `:intersects(Hitbox)` tests the intersection of the enemy with a `Hitbox`

-------------------------------

### RNGs
Pseudo-random numbers are very important, and if we want to play the exact same game with the same seed, they must all come from the same engine. This is why Lua's `random` is not accessible and has been replaced by the table `rand`:

- `.width() -> int` 0 to window width
- `.height() -> int` 0 to window height
- `.enemyPattern() -> int` random enemy pattern
- `.wavePattern() -> int` random wave pattern
- `.int(int, int) -> int` integer in [a,b]	

-------------------------------

### Free functions
- `LOG(string)` log to console under the namespace `Shoot::LUA`

### Lua built-ins
The following functions and tables (minus some few unsafe functions in `math` and `string`) from Lua are also available:

- `assert`
- `error`
- `ipairs`
- `math`
- `next`
- `pairs`
- `pcall`
- `select`
- `string`
- `tonumber`
- `tostring`
- `type`
- `unpack`
- `xpcall`
- `table`