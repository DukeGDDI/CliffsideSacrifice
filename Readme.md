# **Cliffside Sacrifice**

*A Playdate Arcade-Puzzle Game*
**Theme:** Pay to Win (interpreted as Sacrifice)
**Platform:** Playdate (Lua)
**GDD Version:** 1.0

---

# **1. High-Level Concept**

**Cliffside Sacrifice** is a physics-inspired arcade puzzle game where the player controls a team of tethered climbers attempting to ascend a cliff by swinging, launching, and catching new pivot points. Progress requires careful timing, mastery of pendulum motion, and strategic sacrifice of climbers to reach difficult pivots.

The game interprets the jam theme **"Pay to Win"** as paying with **sacrifice**—discarding parts of your team to overcome otherwise impossible obstacles. The player must finish each level with **at least two climbers** remaining.

---

# **2. Core Gameplay Loop**

1. Player begins a level with a rope composed of multiple segments, each ending with a climber.
2. The top climber is attached to a pivot point.
3. Player uses the **D-pad or crank** to **actively pump** the pendulum at the right moments to build momentum.
4. Pressing **A**:
   * Attempts to **grab** a pivot if within reach.
   * Or, if timed during a backswing, **releases** to sling the bottom climber toward a distant pivot.
5. If the climber reaches a new pivot and A is pressed at the right time, the rope **reattaches**, shifting the pivot upward.
6. Player continues ascending pivot by pivot until reaching a **finish pivot**.
7. Player may press **B** to **sacrifice** the lowest climber, shortening the rope for stronger swings.
8. Level ends when reaching a finish pivot with **≥2 climbers**.

---

# **3. Player Controls**

### **Movement & Pendulum Pumping**

* **D-pad Left/Right** or **Crank**
  Used to *pump* the swing. Timing matters: pumping at the apex or trough increases angular velocity.

### **Actions**

* **A Button**

  * Press near a pivot → attempt to **grab** it.
  * Press at the right time during an upward swing → **sling** the end climber for distance.
  * No auto-grab—manual grabbing only.

* **B Button**

  * Sacrifice (release) the **lowest climber**, shortening the rope by one segment.
  * Only allowed when the top climber is attached to a pivot.

### **Other**

* **Menu button** → Pause/settings
* Player can choose **D-pad** or **crank** control style.

---

# **4. Physics & Movement**

### **Pendulum Simulation**

* Simplified pendulum math (not full Box2D).
* Only the **end climber** has mass and determines swing motion.
* Intermediate climbers have no physical effect while the rope is anchored.

### **Swing Mechanics**

* Angular velocity increases when the player pumps effectively (timed inputs).
* Rope length affects swing frequency:

  * **Longer = slower, wider arc**
  * **Shorter = faster, tighter swing**

### **Launching**

* Releasing A on an upswing uses the current velocity vector to project the climber.
* If the climber trajectory enters a pivot’s **grab radius**, pressing A again catches the pivot.

### **Failure to Grab**

* Missing a pivot simply continues the trajectory.
* No auto-grab.

---

# **5. Climbers & Rope**

### **Climbers**

* Start with 2–5 climbers depending on level config.
* Represented initially with simple shapes; future stretch goal includes pixel art.
* Climbers correspond to rope segments.

### **Rope**

* Rope consists of multiple **segments**, each ending in a climber.
* Length determined by the sum of segment lengths defined in level JSON.
* Rope **reattaches instantly** when grabbing a pivot.
* Rope shortens when sacrificing the bottom-most climber.

### **Sacrifice**

* Pressing B removes the **lowest segment + climber**.
* Can be done while swinging, as long as the top climber is attached.
* Instantly affects physics (rope becomes shorter).

---

# **6. Sacrifice Mechanics (“Pay to Win”)**

The core thematic mechanic.

### **Triggers**

* Pressing **B** → intentional sacrifice.
* Missing a pivot → potential accidental loss (falling off-screen).
* Wobbly pivot breaking → all climbers fall (instant fail).

### **Rules**

* Must finish with **≥2 climbers**.
* Losing all climbers = instantaneous level failure.
* Sacrificing allows:

  * Stronger swings (shorter rope).
  * Tighter control.
  * Higher precision launches.

### **Risk/Reward**

* More climbers = more reach but less control.
* Fewer climbers = easier swinging but higher chance of total failure.

---

# **7. Pivots & Level Objects**

### **Pivot Types**

1. **Stable**

   * Permanent anchor point.
   * Never breaks.

2. **Wobbly**

   * Breaks under conditions:

     * After **time-to-break** OR
     * After **swing-count-to-break**
   * Once broken, all climbers fall.

### **Finish Pivots**

* Represent level completion.
* Marked in JSON as `isFinish: true`.
* Levels may contain multiple finish pivots.

---

# **8. Levels & Progression**

### **Structure**

* Levels are handcrafted using JSON.
* Designed primarily vertical but may be horizontally expansive.
* Camera always keeps **all climbers** within the view.

### **Progression**

* Early levels introduce:

  * Basic swinging
  * Basic grabs
  * Stable pivots
* Later levels introduce:

  * Wobbly pivots
  * Longer distances requiring launch mechanics
  * Precision timing challenges
  * Sacrifice puzzles

### **Reset Rules**

* Climbers, rope segments, and lengths **reset each level**.
* No persistent damage or level-to-level carryover.

### **Failure Conditions**

* All climbers lost.
* Reaching a finish pivot with <2 climbers.

---

# **9. Scoring**

### **Primary Score**

* Earn points for completing a level.
* Bonus points awarded based on:

  * Number of climbers remaining
  * Number of sacrifices avoided
  * Time to completion (optional, TBD)

### **Potential Additional Bonuses (Future)**

* Stylish long-distance grabs
* Consecutive successful grabs without falling
* Swing efficiency metrics

---

# **10. Art & Audio Style**

### **Art**

* Minimalist, slightly dark humor tone.
* Early versions use **geometric primitives**.
* Stretch goal: pixel-art climbers, pivots, rope, backgrounds.

### **Audio**

* Simple swing sounds, release chime, pivot snap, fall scream (if time permits).
* Minimalist background ambience.

---

# **11. Playdate Constraints**

* **Black & white**, 1-bit display.
* Must support **either crank or D-pad** for identical mechanics.
* Optimized for performance:

  * Simplified pendulum math
  * Single-body physics (only bottom climber)
  * Efficient rendering with primitives

---

# **12. Data Format (JSON Spec)**

### **Level File JSON Schema (Draft)**

```json
{
  "levelName": "Level 1",
  "background": "assets/bg1.png",

  "segments": [
    20, 20, 30
  ],

  "pivots": [
    { "x": 120, "y": 40, "type": "stable" },
    { "x": 180, "y": 80, "type": "wobbly", "timeToBreak": 3000, "swingLimit": 5 },
    { "x": 100, "y": -20, "type": "stable", "isFinish": true }
  ]
}
```

### **Field Definitions**

* **segments**
  List of rope segment lengths.
  Number of segments + 1 = number of climbers.

* **pivots[]**

  * `x, y`: pivot coordinates
  * `type`: `"stable"` or `"wobbly"`
  * Wobbly-specific:

    * `timeToBreak`: ms before pivot breaks
    * `swingLimit`: # swings allowed before breaking
  * `isFinish`: marks a pivot as a level goal

---

# **13. Future Extensions / Stretch Goals**

### **Art & Content**

* Pixel art climbers & animations
* Parallax backgrounds
* Custom rope graphics

### **Gameplay**

* New pivot types (moving, rotating, sliding)
* Environmental hazards (falling rocks, gusts of wind)
* Challenge modes and leaderboards
* Endless “infinite cliff” mode

### **Meta-Systems**

* Story mode with progression
* Unlockable climbers or rope skins
* Speedrun mode

