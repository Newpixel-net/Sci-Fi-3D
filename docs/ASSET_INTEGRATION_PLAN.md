# Asset Integration Plan

## Available Assets Catalog

### 🤖 ENEMY MODELS (3 robots)
- **Enemy_EyeDrone.gltf** → Scout Robot (fast, low HP)
- **Enemy_QuadShell.gltf** → Soldier Robot (balanced)
- **Enemy_Trilobite.gltf** → Heavy Robot (tank, high HP)

### 🔫 WEAPON MODELS (5 weapons)
- **Gun_Pistol.gltf** → Pistol (semi-auto, starter weapon)
- **Gun_Revolver.gltf** → Alternative pistol
- **Gun_Rifle.gltf** → Assault Rifle (full-auto)
- **Gun_Sniper.gltf** → Sniper Rifle (high damage)
- **Gun_SMG_Ammo.gltf** → SMG with ammo
- **Gun_Sniper_Ammo.gltf** → Sniper with ammo

### 📦 ENVIRONMENT PROPS (28 props)
**Containers:**
- Prop_Crate.gltf
- Prop_Crate_Large.gltf
- Prop_Crate_Tarp.gltf
- Prop_Crate_Tarp_Large.gltf
- Prop_Chest.gltf
- Prop_Barrel1.gltf
- Prop_Barrel2_Closed.gltf
- Prop_Barrel2_Open.gltf

**Furniture:**
- Prop_Desk_L.gltf
- Prop_Desk_Medium.gltf
- Prop_Desk_Small.gltf
- Prop_Chair.gltf
- Prop_Locker.gltf
- Prop_Shelves_ThinShort.gltf
- Prop_Shelves_ThinTall.gltf
- Prop_Shelves_WideShort.gltf
- Prop_Shelves_WideTall.gltf

**Pickups:**
- Prop_Ammo.gltf
- Prop_Ammo_Closed.gltf
- Prop_Ammo_Small.gltf
- Prop_HealthPack.gltf
- Prop_HealthPack_Tube.gltf

**Tech:**
- Prop_SatelliteDish.gltf
- Prop_KeyCard.gltf
- Prop_Mug.gltf
- Prop_Syringe.gltf

**Combat:**
- Prop_Grenade.gltf
- Prop_Mine.gltf

### 🎨 TEXTURES (PBR Materials)
**Enemy Textures:**
- T_Enemies_BaseColor.png
- T_Enemies_Normal.png
- T_Enemies_ORM.png (Occlusion/Roughness/Metallic)
- T_Enemies_Emissive.png (glowing parts)
- T_Enemies_Large_* (for big enemies)

**Weapon Textures:**
- T_Guns_Batch1_* (BaseColor, Normal, ORM, Emissive)
- T_Guns_Batch2_* (BaseColor, Normal, ORM, Emissive)

**Prop Textures:**
- T_Props_Batch1_* (BaseColor, Normal, ORM)
- T_Props_Batch2_* (BaseColor, Normal, ORM, Emissive)
- T_Props_Crates_* (BaseColor, Normal, ORM)

**Trim Textures:**
- T_Trim_01_* (for surfaces/walls)
- T_Trim_02_* (pipes, panels)
- T_Trim_03_* (cables, technical details)

### 🎬 ANIMATIONS
- AnimationLibrary_Godot_Standard.glb (6.4MB)
  * Walk, run, idle cycles
  * Attack animations
  * Death animations
  * Ready to import into Godot

## Integration Priority

### PHASE 1: CRITICAL FIXES (Immediate)
1. ✅ Fix enemy spawner error
2. 🔄 Update enemy prefabs with real 3D models
3. 🔄 Add weapon models to player

### PHASE 2: VISUAL UPGRADE (30 min)
4. Replace player capsule with robot model (or use existing enemy model)
5. Build proper sci-fi arena with props
6. Apply PBR materials and textures
7. Add proper lighting

### PHASE 3: POLISH (20 min)
8. Add animations from AnimationLibrary
9. Create particle effects
10. Add environment details

## Model Assignment Plan

### Enemies (DONE in prefabs, need model integration)
✅ Scout → Enemy_EyeDrone.gltf (already in scene)
✅ Soldier → Enemy_QuadShell.gltf (already in scene)
✅ Heavy → Enemy_Trilobite.gltf (already in scene)

**Action:** Verify models are loading correctly

### Weapons (NEED TO ADD)
❌ Pistol → Gun_Pistol.gltf
❌ Rifle → Gun_Rifle.gltf
❌ Sniper → Gun_Sniper.gltf

**Action:** Replace BoxMesh placeholders with actual gun models

### Player (PLACEHOLDER)
❌ Currently: Gray capsule
🎯 Options:
  - Use one of the enemy models (Enemy_QuadShell?)
  - Or keep capsule for now (player is first-person view anyway)

**Decision:** Keep capsule for now, focus on weapons

### Arena Environment (BASIC)
Current: Flat gray plane
Target: Sci-fi platform with:
- Crates for cover (Prop_Crate_Large)
- Barrels (Prop_Barrel1)
- Tech props (Prop_SatelliteDish)
- Lockers/containers around edges
- Proper sci-fi floor material

## Texture Application Plan

1. **Enemies:** Already have materials in .gltf files
2. **Weapons:** Apply T_Guns_Batch1/2 textures
3. **Props:** Apply T_Props textures
4. **Floor:** Use T_Trim textures for sci-fi panels

## Next Actions

### Immediate (10 minutes)
- [x] Fix spawner error
- [ ] Verify enemy models load
- [ ] Replace weapon box mesh with Gun_Pistol.gltf

### Short term (30 minutes)
- [ ] Add Gun_Rifle and Gun_Sniper models
- [ ] Build arena with props
- [ ] Apply textures to floor

### Polish (20 minutes)
- [ ] Add lighting effects
- [ ] Import and test animations
- [ ] Create particle effects

Total time estimate: 1 hour to transform from prototype to polished game!
