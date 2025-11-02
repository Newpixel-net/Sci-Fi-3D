# "THE LAST STAND" - Fortress Courtyard Design Plan

## 🎯 Vision
A medieval fortress courtyard (30x30 units) under siege by futuristic robot invaders. The player defends the ancient stronghold using advanced sci-fi weapons against endless mechanical waves.

## 🏛️ Core Concept
**Theme**: "Defending the Past from the Future"
- **Environment**: 60% Medieval architecture (warm stone, weathered wood)
- **Combat Elements**: 40% Sci-fi tech (robots, weapons, props)
- **Atmosphere**: Desperate last stand, hope vs overwhelming force

---

## 📐 Arena Layout (30x30 Grid)

```
                    NORTH (Z = -14)
        ╔═══════════════════════════════════╗
        ║  [GATE]  Enemy Spawn Zone        ║
WEST    ║  ┌───────────────────────┐       ║   EAST
(X=-14) ║  │ Medieval Building     │       ║  (X=14)
        ║  │ (West Tower)          │       ║
        ║  │                       │       ║
        ║  └───────────────────────┘       ║
        ║                                   ║
        ║       COURTYARD                   ║
        ║    (Combat Arena)                 ║
        ║    - Scattered crates             ║
        ║    - Barrels for cover            ║
        ║    - Central fountain/statue      ║
        ║                                   ║
        ║  ┌───────────────────────┐       ║
        ║  │ Medieval Building     │       ║
        ║  │ (East Tower)          │       ║
        ║  │                       │       ║
        ║  └───────────────────────┘       ║
        ║                                   ║
        ║  [Player Spawn & Base]           ║
        ╚═══════════════════════════════════╝
                    SOUTH (Z = 14)
```

---

## 🏗️ Structural Elements

### 1. FLOOR (Foundation)
**Current**: Gray CSGBox (boring!)
**Replace With**: Medieval cobblestone floor

**Assets to Use**:
- `Floor_Brick.gltf` - Main courtyard surface (6x6 grid = 36 tiles)
- `Floor_UnevenBrick.gltf` - Weathered patches (battle-worn areas)
- `Floor_WoodDark.gltf` - Near building entrances

**Layout**:
- Cover entire 30x30 area with brick flooring
- Add uneven brick patches near edges (weathering effect)
- Wooden planks near building doorways

---

### 2. PERIMETER WALLS (Enclosure)
**Purpose**: Define arena boundaries, create fortress atmosphere

**North Wall** (Enemy entrance - partial wall with gate):
- `Wall_UnevenBrick_Straight.gltf` x4 (left side)
- `Wall_Plaster_Door_Round.gltf` x1 (central gate - enemies enter here)
- `Wall_UnevenBrick_Straight.gltf` x4 (right side)
- `Overhang_UnevenBrick_Long.gltf` along top for detail

**East Wall** (Right side - complete defensive wall):
- `Wall_UnevenBrick_Straight.gltf` x8-10
- `Wall_UnevenBrick_Window_Thin_Round.gltf` x2 (arrow slits)
- `Corner_Exterior_Brick.gltf` at both ends

**West Wall** (Left side - complete defensive wall):
- `Wall_Plaster_Straight.gltf` x8-10
- `Wall_Plaster_Window_Wide_Flat.gltf` x2 (larger windows)
- `Corner_Exterior_Wood.gltf` at both ends

**South Wall** (Player base - open for access):
- `Wall_Plaster_Straight.gltf` x3 (left section)
- Open central area (player entry/exit)
- `Wall_UnevenBrick_Straight.gltf` x3 (right section)

**Wall Height**: 4-5 units (provides enclosure without blocking view)

---

### 3. CORNER TOWERS (Vertical Interest)
**Purpose**: Add verticality, strategic sniper positions (future update)

**Northwest Corner** (X=-14, Z=-14):
- Base: 3x3 stacked `Wall_UnevenBrick_Straight.gltf`
- Roof: `Roof_RoundTiles_4x4.gltf`
- Details: `Balcony_Simple_Corner.gltf` at 2nd level

**Northeast Corner** (X=14, Z=-14):
- Base: 3x3 stacked `Wall_Plaster_Straight.gltf`
- Roof: `Roof_RoundTiles_4x4.gltf`
- Details: `WindowShutters_Wide_Flat_Open.gltf`

**Southwest Corner** (X=-14, Z=14):
- Base: Smaller tower 2x2
- Roof: `Roof_Wooden_2x1.gltf`
- Details: `Prop_Vine2.gltf` (overgrown, aged look)

**Southeast Corner** (X=14, Z=14):
- Base: Matching SW tower
- Roof: `Roof_Wooden_2x1.gltf`
- Details: `Prop_Chimney.gltf`

---

### 4. CENTRAL COURTYARD PROPS (Combat Zone)

#### Medieval Elements (Atmosphere):
- **Position (0, 0, 0)**: `Prop_Wagon.gltf` - Abandoned supply cart (central cover)
- **Position (-5, 0, -3)**: `Prop_WoodenFence_Extension2.gltf` - Broken fence line
- **Position (6, 0, 4)**: `Prop_Crate.gltf` (medieval version) - Stacked supply crates
- **Position (-8, 0, 7)**: `Prop_ExteriorBorder_Straight1.gltf` - Decorative stone border
- **Scattered**: `Prop_Brick1-4.gltf` - Rubble from battle damage

#### Sci-Fi Props (Kept from current arena):
- **All existing crates, barrels, desks** remain (defender's supplies)
- **Health packs & ammo** stay in current positions
- **Satellite dish** repositioned to (-10, 0, -8) - tech outpost feel
- **Lockers** moved near south wall - player base area

#### New Mixed Elements:
- **Position (3, 0, -6)**: Medieval crate stack with sci-fi ammo box on top
- **Position (-4, 0, 8)**: Barrel cluster (2 medieval + 1 sci-fi)
- **Position (0, 0.5, 5)**: `Prop_Chest.gltf` (medieval) with health pack nearby (sci-fi)

---

### 5. DECORATIVE DETAILS (Atmospheric Polish)

#### Overgrown/Aged Elements:
- `Prop_Vine1.gltf`, `Prop_Vine2.gltf`, `Prop_Vine5.gltf` - Climbing walls
- Place on corners, around windows, near towers
- Suggests fortress is ancient, nature reclaiming

#### Architectural Trim:
- `Overhang_Plaster_Corner.gltf` - Top of walls for visual depth
- `Prop_Support.gltf` - Structural beams near doorways
- `WindowShutters` variations - Open/closed randomly for variety

#### Metal Details:
- `Prop_MetalFence_Ornament.gltf` - Along balconies
- `Prop_MetalFence_Simple.gltf` - Broken sections in courtyard

---

## 🎨 Visual Strategy

### Material Palette:
1. **Primary** (40%): Beige/tan uneven brick (aged fortress stone)
2. **Secondary** (30%): White/cream plaster (maintained buildings)
3. **Accent** (20%): Dark wood (doors, supports, roofs)
4. **Detail** (10%): Orange round tiles (roofs), green vines (nature)

### Contrast with Sci-Fi:
- **Medieval**: Warm (yellows, oranges, browns), organic, weathered
- **Sci-Fi**: Cool (blues, grays, whites), metallic, pristine
- **Result**: Visually striking, tells story without words

---

## 💡 Lighting Plan (For Later Phase)

**Directional Light** (Sun):
- Color: Warm orange (#FFA040) - Sunset/golden hour
- Angle: 45° from northwest
- Creates long shadows, dramatic atmosphere
- Symbolizes "last light of hope"

**Point Lights** (Accent):
- Cool blue lights from sci-fi props (satellite, lockers)
- Warm yellow lights from medieval windows
- Contrast reinforces old vs new theme

**Fog** (Atmosphere):
- Light volumetric fog
- Warmtone to match sunset
- Adds depth, mysterious mood

---

## 🎯 Gameplay Considerations

### Cover Positions:
- **High Cover** (Full protection): Walls, towers, wagon
- **Medium Cover** (Partial): Crates, barrels, desks
- **Low Cover** (Minimal): Broken fences, rubble

### Sightlines:
- Central courtyard: Open for combat
- Corners: Blind spots (tactical positioning)
- North gate: Clear enemy approach lane
- South area: Safe retreat zone

### Movement:
- Perimeter allows kiting enemies
- Central props force positioning choices
- No cramped corners (keep combat fluid)
- 30x30 size maintains intimate feel

---

## 📦 Asset Checklist

### Floors (36 tiles needed):
- [ ] Floor_Brick.gltf x30
- [ ] Floor_UnevenBrick.gltf x6
- [ ] Floor_WoodDark.gltf x4 (doorways)

### Walls (Perimeter):
- [ ] Wall_UnevenBrick_Straight.gltf x16
- [ ] Wall_Plaster_Straight.gltf x14
- [ ] Wall_UnevenBrick_Window_Thin_Round.gltf x2
- [ ] Wall_Plaster_Window_Wide_Flat.gltf x2
- [ ] Wall_Plaster_Door_Round.gltf x1 (gate)

### Corners:
- [ ] Corner_Exterior_Brick.gltf x2
- [ ] Corner_Exterior_Wood.gltf x2

### Roofs:
- [ ] Roof_RoundTiles_4x4.gltf x2 (towers)
- [ ] Roof_Wooden_2x1.gltf x2 (small towers)

### Props (Medieval):
- [ ] Prop_Wagon.gltf x1
- [ ] Prop_Crate.gltf (medieval) x3
- [ ] Prop_WoodenFence_Extension2.gltf x2
- [ ] Prop_Brick1.gltf, Prop_Brick2.gltf x5 (rubble)
- [ ] Prop_Vine1.gltf, Prop_Vine2.gltf, Prop_Vine5.gltf x8
- [ ] Prop_Chimney.gltf x1

### Details:
- [ ] Overhang_UnevenBrick_Long.gltf x4
- [ ] Overhang_Plaster_Corner.gltf x4
- [ ] Prop_Support.gltf x2
- [ ] WindowShutters variations x4
- [ ] Balcony_Simple_Corner.gltf x1

### Sci-Fi Props (Keep existing):
- [x] All crates, barrels, desks (24 items)
- [x] Health packs x2
- [x] Ammo boxes x2
- [x] Satellite dish x1
- [x] Lockers x3

---

## ⏱️ Implementation Timeline

### Phase A: Foundation (30 min)
1. Replace gray floor with brick tiles (grid layout)
2. Test material import and placement
3. Verify navigation mesh updates

### Phase B: Walls (45 min)
1. Build north wall with gate
2. Complete east and west walls
3. Add south wall sections
4. Place corner pieces

### Phase C: Towers (30 min)
1. Construct 4 corner towers (stacked walls)
2. Add roofs to each tower
3. Place balconies and windows

### Phase D: Courtyard Props (45 min)
1. Position central wagon and medieval props
2. Integrate existing sci-fi props
3. Add rubble and broken elements
4. Place decorative details

### Phase E: Polish (30 min)
1. Add vines and weathering
2. Place overhangs and trim
3. Final positioning adjustments
4. Test gameplay flow

**Total Estimated Time**: ~3 hours

---

## 🚀 Expected Result

### Visual Impact:
- **Before**: Empty gray plane with scattered props
- **After**: Rich, atmospheric medieval courtyard fortress

### Emotional Tone:
- Desperate defense of ancient heritage
- Technology vs tradition
- Hope (weapons) vs despair (endless enemies)

### Marketability:
- Unique genre fusion (fantasy + sci-fi)
- Screenshot-worthy from any angle
- Memorable visual identity
- Stands out from generic shooters

---

## ✅ Approval Checkpoints

Before proceeding to Phase 4 (Building), confirm:

1. ✅ Layout plan matches gameplay needs
2. ✅ Asset list covers all required elements
3. ✅ Visual concept is clear and achievable
4. ✅ Timeline is reasonable

**Once approved, proceed with implementation in game.tscn**

---

*Design by: Claude*
*Date: 2025-11-02*
*Project: Sci-Fi 3D Wave Defense (Medieval Expansion)*
