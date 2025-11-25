# Desert Chaos

A small 2D arcade game made with **Godot 4**.  
Drive your car through a hostile desert, dodge enemies, and collect gold before you run out of lives.

---

## Overview

- **Genre:** 2D arcade / survival  
- **Engine:** Godot 4 (project name: *Dessert Chaos*)  
- **Goal:** Collect **10 gold coins** without losing all of your **3 lives**.  
- **Enemies:** Snakes, scorpions, and crabs chase the player around the map.

---

## How to Play

### Controls

- **Move:** `W`, `A`, `S`, `D` *(or Arrow Keys, if mapped)*  
  - `W` / Up – drive up  
  - `S` / Down – drive down  
  - `A` / Left – drive left  
  - `D` / Right – drive right
- **Start game (from main menu):**
  - Click the **Start** button with the mouse, **or**
  - Press `Enter` / `Return`, **or**
  - Press the **accept** key (e.g. `Space`).

The car keeps its momentum, so quick direction changes and short taps on the keys help with precise movement.

---

### Objective

- Gold coins spawn randomly in the desert.
- Drive over a coin to pick it up.
- Your current gold count is shown in the HUD (Score label).
- When you reach **10 coins** (`GOAL = 10`) without dying, the **Win** screen appears and you complete the run.

---

### Enemies & Damage

The desert is filled with:

- 🐍 **Snakes**  
- 🦂 **Scorpions**  
- 🦀 **Crabs**

All of them chase the player:

- If an enemy touches your car, you **take damage**.
- You start with **3 HP** (`MAX_HP = 3`).
- Each hit removes **1 heart** from the HUD.
- After taking damage you get a short **invulnerability** period and a small **knockback**.

If your HP reaches **0**:

- The **Game Over** (Lose) screen appears.
- You can click **Retry / Play Again** to restart the level.

---

## HUD

- **Hearts HUD** – shows how many lives you have left (up to 3 hearts).  
- **Score / Gold Counter** – shows how many coins you have collected out of 10.

---

## Running the Project

To open and run the game from source:

1. Install **Godot 4.x** (the project was created with Godot 4.5).
2. Clone or download this repository.
3. Open Godot and choose `project.godot` inside the project folder.
4. Set the main scene to `scenes/MainMenu.tscn` if it is not already set.
5. Press **F5** or click the **Run** button to start the game.

---

## Future Ideas

- More enemy types and behaviors  
- Different desert levels and layouts  
- Power-ups (temporary shield, speed boost, extra life)  
- Mobile controls and UI improvements

---

*Made as a university project and a practice game using Godot 4.*
