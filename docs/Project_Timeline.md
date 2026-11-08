# Super Mario Engine – Module Plan and Timeline (2 Members)

**Course:** EL2003 – Computer Organization and Assembly Language
**Tools:** NASM, DOSBox, VGA Mode 13h (320 × 200), output `MARIO.COM`
**Plan written:** 7 November 2026
**Deadline:** 29 November 2026

---

## 1. Work split

| | Member 1 | Member 2 |
|---|---|---|
| **Name / Roll no.** | *to be filled* | *to be filled* |
| **Focus** | Screen, graphics, map, camera, HUD, menus | Input, timing, physics, collisions, enemies, blocks, restart/exit |
| **Modules** | 1, 2, 3, 4, 5, 6, 13, 14 | 7, 8, 9, 10, 11, 12, 15 |
| **Shared** | Integration, testing, README, report | Integration, testing, README, report |

Member 1 builds everything the player sees. Member 2 builds everything that decides what happens. Both sides meet at a few agreed procedures, listed in section 2.

### 1.1 Why it is split this way

- Modules 1–3 are the base everything else needs, so Member 1 finishes them first. Member 2 starts with the keyboard and timer, which do not depend on the screen.
- The heavy logic modules (9–12) all sit with Member 2. The drawing-heavy modules (4, 5, 6, 13, 14) sit with Member 1, which evens out the workload.
- Each member can test their own part alone: Member 2 can check physics and collisions with a plain rectangle drawn by `FillRect` before sprites exist.

---

## 2. Agreed interfaces

Decide and write these down on day one so both halves fit together. Parameters go on the stack.

| Procedure / data | Owner | Used by |
|------------------|-------|---------|
| `PutPixel(x, y, colour)`, `FillRect(x, y, w, h, colour)` | Member 1 | Everyone |
| `GetTile(px, py)` returns tile code | Member 1 | Collision, enemies, blocks |
| `SetTile(col, row, code)` writes to the working map | Member 1 | Blocks (Module 12) |
| `DrawSprite(x, y, address, flags)` | Member 1 | Drawing of Mario, enemies, items |
| `camera_x` (read-only for Member 2) | Member 1 | Enemy activation, removal |
| `AddScore(points)` | Member 1 | Stomps, coins, blocks, flag |
| Key-state table (128 bytes, 1 = held) | Member 2 | Menus, movement |
| Tick counter | Member 2 | Game loop, clock |
| Hero data: x, y, vx, vy, form, hp, on_ground, invuln_timer, stomp_chain | Member 2 | Camera, drawing, HUD |
| Enemy record table | Member 2 | Drawing |
| `game_state` variable | Member 1 | Main loop, death/win handling |

**Rule:** a procedure's owner is the only person who edits it. If the other member needs a change, they ask and the owner makes it. This avoids merge conflicts in Git.

---

## 3. Module-by-module plan

### Phase 1 – Foundation

#### Module 1 – Program skeleton and build setup (Member 1)
- **What:** project folder, `mario.asm`, `build.bat` (NASM `-f bin` → `build\MARIO.COM`). `ORG 100h` entry, DOS exit (`INT 21h, AH=4Ch`), text-mode restore. Constants with `EQU` for screen size, tile size, colours, scan codes and limits. Variables grouped by purpose.
- **Depends on:** nothing.
- **Done when:** assembles without warnings, runs, and returns to the DOS prompt.

#### Module 2 – Video mode and colours (Member 1)
- **What:** switch to Mode 13h on start and back to text mode on exit. Pick colours for sky, ground, brick, pipe, hero, enemies, text and HUD. `PutPixel` and `FillRect` with stack parameters; offset `y*320 + x` using shifts. A test screen showing every colour.
- **Depends on:** Module 1.
- **Done when:** the test screen shows all colours and rectangles with no stray pixels.

#### Module 3 – Level map and tile drawing (Member 1)
- **What:** level as a byte table, at least 60 × 12, using the tile codes (0 sky … 12 flag pole). `DrawTile`, `DrawMap`, `GetTile`. An original map and a working map, with `ResetMap` using a block move. The level must meet the minimums (2 pits, 2 pipes, 3 coin blocks, 2 mushroom blocks, 2 brick groups, 10 coins, stairs, 7-tile flag pole).
- **Depends on:** Module 2.
- **Done when:** any 20-column window can be drawn and `ResetMap` restores a changed map.

### Phase 2 – Graphics and memory

#### Module 4 – Sprites (Member 1)
- **What:** original 16 × 16 sprites (Small Mario stand/run/jump, Goomba walk/flat, Koopa, shell, mushroom, coin) and 16 × 32 Super Mario (stand/run/jump). Colour 0 is transparent. `DrawSprite` with mirroring, clipping on all four edges, and a blink option.
- **Depends on:** Module 2.
- **Done when:** every sprite shows correctly, mirrored, and partly off-screen on all four sides.

#### Module 5 – Frame buffer and block operations (Member 1)
- **What:** second segment as an off-screen frame buffer. Clear each frame with `REP STOSW`, copy to video memory with `REP MOVSW` once per timer tick. Record the memory choice for the README.
- **Depends on:** Modules 2, 4, 8 (tick).
- **Done when:** a sprite moves across the screen with no flicker.

#### Module 6 – Camera and scrolling (Member 1)
- **What:** `screen_x = world_x − camera_x`. Follow Mario past screen x = 160, clamp to 0 … 640, never move left, stop Mario at the left edge. Tile columns from `camera_x >> 4` with pixel offset `camera_x & 15`. Entities drawn only when `−16 < screen_x < 320`. Reset to 0 on every new life and new game.
- **Depends on:** Modules 3, 9 (hero position).
- **Done when:** every row of the camera table and the worked example give the same numbers.

### Phase 3 – Interrupts

#### Module 7 – Keyboard interrupt handler (Member 2)
- **What:** replace INT 09h, saving the old vector (`AH=35h`) and restoring it on every exit path (`AH=25h`). Read port 60h, treat bit 7 as release, ignore the `E0h` prefix. A 128-byte key-state table so Left, Right, Shift and Space work together. Send EOI (`OUT 20h, 20h`) and end with `IRET`.
- **Depends on:** Module 1.
- **Done when:** holding Right + Shift + Space shows all three as held, and the DOS prompt accepts typing after exit.

#### Module 8 – Timer and game clock (Member 2)
- **What:** hook INT 08h (or 1Ch), increment a tick counter, chain to the original handler. The game loop waits for the tick to change. Derive the one-second clock from ticks. Restore the original behaviour on exit.
- **Depends on:** Module 1.
- **Done when:** the HUD time drops by one every real second regardless of PC speed.

### Phase 4 – Game logic

#### Module 9 – Player movement and physics (Member 2)
- **What:** 8.8 fixed-point position and velocity. Walk and run limits, acceleration, friction, gravity, max fall speed, ground-only jump, variable jump height, facing and pose. Hero data kept together (`on_ground`, `form`, `hp`, `invuln_timer`, `stomp_chain`).
- **Depends on:** Modules 7, 8.
- **Done when:** Mario speeds up, slides to a stop, jumps higher when Space is held and cannot jump in midair.

#### Module 10 – Collision detection (Member 2)
- **What:** move horizontally then vertically, never more than one tile per frame. Test feet, head and sides with `GetTile`. Head hits trigger blocks, landing resets the stomp chain, pit at y ≥ 192, flag pole contact. A rectangle-overlap procedure and a stomp-or-hurt decision.
- **Depends on:** Modules 3, 9.
- **Done when:** at max fall speed Mario never passes through the floor, can stand on pipes and walk under blocks.

#### Module 11 – Enemies and shells (Member 2)
- **What:** fixed-size record table (type, state, x, y, speed, direction, timer) updated in a loop with indexed addressing. Goomba and Koopa speeds, turning rules, activation within one tile of the screen, removal, flat-Goomba timer, shell states, 8-frame kick grace, shell kills (+500), limit of 8 active enemies.
- **Depends on:** Modules 3, 10.
- **Done when:** a Goomba and a Koopa behave as specified and a shell defeats a Goomba for +500.

#### Module 12 – Blocks, coins and power-ups (Member 2)
- **What:** brick and "?" block behaviour on head hits (working map only), the mushroom entity (move, fall, turn, collect), Small → Super with feet fixed, map coins, extra life at 100 coins.
- **Depends on:** Modules 3, 10, 13 (`AddScore`).
- **Done when:** every block type reacts correctly and the working map changes while the original stays intact.

#### Module 13 – Score, health, lives and HUD (Member 1)
- **What:** 32-bit score (`ADD`/`ADC`), coins, lives, HP and time as binary numbers, clamped to limits. Decimal conversion by repeated division by 10, remainders pushed and popped. Digits and text from our own bitmap font, plus two hearts. One `AddScore(points)` procedure for all scoring rules.
- **Depends on:** Modules 4, 5.
- **Done when:** the HUD matches every scoring event and never shows a wrong digit.

### Phase 5 – Integration

#### Module 14 – Game states, screens and menus (Member 1)
- **What:** state machine with a `game_state` variable and jump table. Title, Playing, Paused, Dying, Life-lost, Level-complete and Game-over screens with borders and tidy layouts. The ten-step frame order in the Playing state.
- **Depends on:** Modules 5, 7, 13.
- **Done when:** every arrow of the state table works, including Esc and P.

#### Module 15 – Win, lose, restart and clean exit (Member 2)
- **What:** death sequence (freeze, animation, lives −1, Life-lost or Game Over) and win sequence (points by height, slide, walk, time × 50). `ResetLevel` and `NewGame`. On exit restore both vectors, return to text mode and exit to DOS without hanging.
- **Depends on:** Modules 7, 8, 11, 12, 14.
- **Done when:** a win, a loss and a quit can be played in a row and the DOS keyboard works afterwards.

---

## 4. Timeline

Today is Saturday 7 November. There are about three weeks to the deadline, so this plan is tighter than the 15-week suggestion in the manual. Both members work in parallel after day one.

| Dates | Member 1 | Member 2 | Meeting point |
|-------|----------|----------|---------------|
| **Sat 7 – Mon 9 Nov** | Repo, folders, `build.bat`. **Module 1**, start **Module 2** | Written notes of the plan. Read rules. Start **Module 7** in a separate test file | Agree the interfaces in section 2. Both push first commits |
| **Tue 10 – Thu 12 Nov** | Finish **Module 2**, then **Module 3** (map and tiles) | Finish **Module 7**, then **Module 8** (timer) | Merge. Check the build runs with the real keyboard and timer |
| **Fri 13 – Sun 15 Nov** | **Module 4** (sprites) | **Module 9** (physics), tested with a `FillRect` box | Mario box moves with real keys and gravity |
| **Mon 16 – Wed 18 Nov** | **Module 5** (frame buffer) and **Module 6** (camera) | **Module 10** (collisions) | Mario with sprite, flicker-free, scrolling over the real map |
| **Thu 19 – Sat 21 Nov** | **Module 13** (score, HUD, font) | **Module 11** (enemies and shells) | `AddScore` ready so stomps can score |
| **Sun 22 – Tue 24 Nov** | **Module 14** (states and screens) | **Module 12** (blocks, coins, mushroom) | Full playing state runs end to end |
| **Wed 25 – Thu 26 Nov** | Fix visual bugs, polish screens | **Module 15** (death, win, restart, clean exit) | Feature complete |
| **Fri 27 – Sat 28 Nov** | Run all 17 demo tests together. Fix bugs. Screenshots. Write README and report sections | Same: tests, fixes, report sections, source code section | Freeze the code. Final commits from both accounts |
| **Sun 29 Nov** | Final check and submission | Final check and submission | Submit report on GCR, repo link opens without login |

### 4.1 Buffer and fallback

- Wednesday 25 – Thursday 26 November is the only slack. If a module slips, cut bonus ideas first, never required rules.
- If Module 11 or 12 runs late, Member 1 can take over part of it after finishing Module 14, since Member 1 has the lighter load in the final week.
- Do the camera (Module 6) and the frame buffer (Module 5) early. Bugs in these affect every later screenshot.

---

## 5. Planning notes

### 5.1 Before writing code

- Write the rules in your own words on paper first: scoring, health, death, win. No diagrams are required.
- Decide the second-segment method for the frame buffer and record it for the README.
- Pick the tile codes, the sprite file layout and the register-preservation convention together.

### 5.2 Working habits

- **Comments:** every procedure gets a block with name, purpose, inputs, outputs and registers changed.
- **Naming:** meaningful labels and variables, for example `hero_vx`, `DrawSprite`, `enemy_table`.
- **Layout:** align instructions, operands and comments consistently.
- **Commits:** each member makes at least 4–5 meaningful commits from their own account, with messages like "Added keyboard handler" or "Fixed jump collision bug".
- **Testing:** test each module on its own against its "Done when" line before merging.
- **Restore everything:** keyboard and timer vectors must be restored on every exit path, including Esc and errors.

### 5.3 Common failure points

- Frame buffer not fitting in the `.COM` segment.
- Mario passing through floors at high fall speed.
- Working map and enemies not reset after a death.
- Keyboard or timer vector not restored, which hangs DOSBox.
- Rules differing from the manual without being listed in the README.

---

## 6. Deliverables checklist

| Item | Owner | Due |
|------|-------|-----|
| Source code, `MARIO.COM` and README on GitHub | Both | 29 Nov |
| README: members, modules, build/run steps, controls, memory choices, game states, deviations, limitations | Member 1 writes, Member 2 reviews | 28 Nov |
| Report sections 5 (Implementation) and 11 (source code) | Each member documents their own modules | 28 Nov |
| Rules verification table and screenshots (14-item checklist) | Both | 28 Nov |
| Team contribution and learning outcomes (different for each member) | Each member writes their own | 28 Nov |
| Report upload on GCR | Both check | 29 Nov |
| Live demo and viva | Both present, both must explain any line | Lab date |
