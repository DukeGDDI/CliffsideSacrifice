## 🧱 Code Architecture Rationale

The CliffsideSacrifice project is divided into multiple small Lua modules, each with a single, well-defined purpose.
This separation makes the codebase incremental, maintainable, and easy for both humans and AI systems to extend one feature at a time.

### 📁 File Structure

```plaintext
CliffsideSacrifice
├── source/
│   ├── scripts/
│   │   ├── game.lua
│   │   ├── draw.lua
│   │   ├── input.lua
│   │   ├── level.lua
│   │   ├── entities.lua
│   │   ├── sound.lua
│   │   └── constants.lua
│   ├── assets/
│   │   ├── fonts/
│   │   │   ├── <fontname>.png
│   │   │   └── <fontname>.fnt
│   │   ├── sfx/
│   │   │   ├── <filename>.wav
│   │   │   └── ...
│   │   └── images/
│   │       ├── splash.png
│   │       └── title_logo.png
│   ├── main.lua
│   └── pdxinfo
│
├── Support/
│   ├── ...
│   └── devguide.md
│
├── README.md
└── .gitignore
```


| File              | Responsibility                                                     | Reason for Separation                                                                              |
| ----------------- | ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| **main.lua**      | Entry point; connects update and draw cycles.                      | Keeps the Playdate SDK loop clean and stable while delegating logic elsewhere.                     |
| **game.lua**      | Central game controller that manages state and transitions.        | Allows new features to be added without touching lower-level logic.       |
| **constants.lua** | Holds all tunable variables and screen metrics.                    | Encourages data-driven design; difficulty and balance can be tuned without code changes.           |
| **input.lua**     | Reads crank and button inputs and translates them to game actions. | Simplifies event handling and allows new input mechanics to be added easily. |
| **draw.lua**      | Handles all rendering using `playdate.graphics`.                   | Keeps visuals independent from gameplay logic, enabling clean separation of model vs. view.        |
| **level.lua**     | Generates per-level parameters and difficulty settings.            | Supports procedural and handcrafted level creation without modifying core logic.                   |
| **entities.lua**  | Manages missiles, explosions, and cities.                          | Centralizes update logic and collisions; new entity types can be introduced in one place.          |
| **sound.lua**     | Plays and manages sound effects.                                   | Keeps audio independent, enabling quick iteration on game feel and performance.                    |

### 🔄 Incremental Development Flow

When building or extending the game, each new feature should map cleanly to a single file:

1. Start with constants.lua — define any new parameters.

2. Update entities.lua — implement new behavior or objects.

3. Extend draw.lua — render the new visuals.

4. Adjust input.lua — add new player actions if needed.

5. Update game.lua — integrate the feature into the main loop or scoring.

6. Playtest and iterate — ensure balance, sound, and feedback feel correct.

### ⚙️ Benefits of This Approach

* Isolation: Each file can be tested or expanded without breaking the others.

* Clarity: The purpose of each module is obvious to future developers (or AIs).

* Incrementality: Codex can safely “open” one file, add a feature, and close it — no global refactoring needed.

* Scalability: The structure supports easy additions like powerups, menu systems, or boss waves.


## 🧩 Module & Import Rules (Playdate-Style Global Objects)

To keep the codebase consistent, maintainable, and fully compatible with Playdate’s build system, **every script file defines exactly one global table**, and **no file returns a module**. All cross-file communication happens through these globals, and `main.lua` is responsible for importing every script in the correct order.

### 🔑 Core Principles

1. **Each file defines one global object**
   Example:

   ```lua
   -- draw.lua
   Draw = {}
   ```

   *Never* declare this as `local Draw = {}` and *never* return it.

2. **Playdate’s `import` does not return values**
   The expression:

   ```lua
   local x = import "scripts/draw"
   ```

   will always set `x` to `nil`.
   Therefore, only `main.lua` (or another top-level file) performs imports:

   ```lua
   import "scripts/constants"
   import "scripts/entities"
   import "scripts/draw"
   ```

3. **Modules must avoid importing each other**
   Because `import` concatenates files and does not return anything, chaining imports creates ordering problems.
   Instead, rely on globals:

   ```lua
   -- entities.lua
   local length = Constants.PENDULUM_LENGTH_DEFAULT
   ```

4. **Load order matters and is controlled by main.lua**
   `main.lua` must import files in this order:

   1. `constants.lua` (defines tunables needed everywhere)
   2. `entities.lua` (uses constants)
   3. `draw.lua` (uses constants and entities)
   4. `game.lua` (ties systems together)
   5. any additional modules (input, sound, level, etc.)

5. **No module returns anything**
   Playdate expects scripts to be side-effect-only.
   So **do not**:

   ```lua
   return Draw
   ```

6. **Cross-file usage always uses global tables**

   ```lua
   Entities.updatePendulum(pump)
   Draw.drawPendulum(Entities.pendulum)
   Game.update()
   ```

---

### ✅ Example Minimal Module

```lua
-- scripts/entities.lua

Entities = Entities or {}

Entities.pendulum = {
    angle = 0,
    length = Constants.PENDULUM_LENGTH_DEFAULT
}

function Entities.updatePendulum(pump)
    -- uses global Constants automatically
end
```

### 🚫 What NOT to do

```lua
local Constants = import "scripts/constants"   -- ❌ import returns nil
local Entities = {}                            -- ❌ stays local, not visible elsewhere
return Entities                                 -- ❌ Playdate ignores return values
```

---

## 🎯 Why This Standard Exists

* Ensures predictable load order
* Avoids Playdate-specific `import` pitfalls
* Keeps AI-generated code consistent and safe
* Prevents circular imports and nil-reference errors
* Makes every module immediately available to the entire codebase

---

If you’d like, I can insert this directly into your `devguide.md` for you—just say **“apply this to the devguide”**.
