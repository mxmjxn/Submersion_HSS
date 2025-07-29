# Weapon System Setup Guide

## Overview
This guide will help you set up the complete weapon and aiming system in your Godot TPS game.

## 1. Project Structure Setup

### Create the following folder structure:
```
tps_sample/
├── Weapons/
│   ├── Scripts/ (already created)
│   ├── Scenes/
│   └── Configs/
├── UI/
│   ├── Scripts/ (already created)
│   └── Scenes/
└── Player/
	└── Scenes/
```

## 2. Camera System Setup

### In your Player scene:
1. **Select your Camera node** (the one with camera.gd script)
2. **Add these properties in the Inspector:**
   - `camera_node`: Reference to your Camera3D node
   - `weapon_manager`: Reference to WeaponManager (we'll create this next)

### Camera Node Structure:
```
Player/
├── CharacterBody3D (player.gd)
├── Camera3D (camera.gd)
│   └── WeaponHolder (Node3D)
└── WeaponManager (Node3D, weapon_manager.gd)
```

## 3. Weapon Manager Setup

### Create WeaponManager:
1. **Add a Node3D as child of Player**
2. **Name it "WeaponManager"**
3. **Attach the weapon_manager.gd script**
4. **Set properties:**
   - `weapon_holder`: Reference to WeaponHolder node
   - `ui_manager`: Reference to your UI manager (we'll create this)

## 4. Weapon Scenes Setup

### Create Pistol Scene:
1. **Create new scene with Node3D as root**
2. **Name it "Pistol"**
3. **Attach pistol.gd script**
4. **Add child nodes:**
   ```
   Pistol (Node3D, pistol.gd)
   ├── WeaponModel (MeshInstance3D)
   ├── MuzzleFlash (Node3D)
   └── AimPoint (Node3D)
   ```
5. **Set properties in pistol.gd:**
   - `projectile_scene`: Reference to bullet.tscn
   - `camera_system`: Reference to camera node
   - `aim_config`: Create new WeaponAimConfig resource

### Create Rifle Scene:
1. **Similar to Pistol, but attach rifle.gd script**
2. **Set different properties for rifle characteristics**

## 5. Weapon Aim Configurations

### Create Aim Config Resources:
1. **Right-click in FileSystem → New Resource**
2. **Choose WeaponAimConfig**
3. **Save as "pistol_aim_config.tres"**
4. **Configure settings:**
   - `fov`: 65.0
   - `position_offset`: Vector3(0, -0.1, 0.2)
   - `sensitivity_multiplier`: 0.7
   - `recoil_strength`: Vector2(0.03, 0.06)

### Create rifle_aim_config.tres with:
- `fov`: 55.0
- `position_offset`: Vector3(0, -0.15, 0.3)
- `sensitivity_multiplier`: 0.5
- `recoil_strength`: Vector2(0.05, 0.1)

## 6. Projectile Setup

### Create Bullet Scene:
1. **Use the bullet.tscn template provided**
2. **Or create manually:**
   ```
   Bullet (Area3D, projectile.gd)
   ├── CollisionShape3D (SphereShape3D)
   └── MeshInstance3D (SphereMesh)
   ```

## 7. UI Setup

### Create Weapon UI Scene:
1. **Create new scene with Control as root**
2. **Name it "WeaponUI"**
3. **Attach weapon_ui.gd script**
4. **Add child nodes:**
   ```
   WeaponUI (Control, weapon_ui.gd)
   ├── AmmoLabel (Label)
   ├── WeaponNameLabel (Label)
   ├── HealthBar (ProgressBar)
   ├── Crosshair (TextureRect)
   └── AimIndicator (Control, aim_indicator.gd)
	   ├── AimOverlay (TextureRect)
	   └── ScopeOverlay (TextureRect)
   ```

### Configure UI References:
- Connect all UI elements to their respective @export variables
- Set `weapon_manager` and `player` references

## 8. Connecting Everything

### In Player Scene:
1. **Select Player node**
2. **Set weapon_manager reference**
3. **Select Camera node**
4. **Set camera_node and weapon_manager references**

### In WeaponManager:
1. **Add your weapon scenes to the weapons array**
2. **Set weapon_holder reference**
3. **Set ui_manager reference**

### In Weapon Scenes:
1. **Set projectile_scene reference**
2. **Set camera_system reference**
3. **Set aim_config reference**

## 9. Input Setup

### The following inputs are already configured:
- **Fire**: Left Mouse Button
- **Aim**: Right Mouse Button
- **Reload**: R key
- **Weapon 1/2/3**: 1, 2, 3 keys
- **Mouse Wheel**: Weapon switching

## 10. Testing the System

### Test Steps:
1. **Run the game**
2. **Press 1, 2, 3 to switch weapons**
3. **Hold Right Mouse Button to aim**
4. **Left Mouse Button to fire**
5. **R to reload**
6. **Mouse wheel to switch weapons**

## 11. Customization

### Adding New Weapons:
1. **Create new weapon scene**
2. **Extend WeaponBase class**
3. **Create aim configuration**
4. **Add to WeaponManager weapons array**

### Modifying Aim Settings:
1. **Edit aim_config resources**
2. **Or modify aim_settings in camera.gd**
3. **Use set_weapon_aim_settings() for runtime changes**

### Adding Effects:
1. **Modify play_fire_effects() in weapon scripts**
2. **Add sound effects with AudioStreamPlayer3D**
3. **Create particle effects for muzzle flash**

## 12. Troubleshooting

### Common Issues:
- **Weapons not firing**: Check projectile_scene reference
- **No recoil**: Check camera_system reference
- **UI not updating**: Check weapon_manager and player references
- **Aiming not working**: Check aim input action and camera references

### Debug Tips:
- Use `print()` statements in weapon scripts
- Check the Output panel for errors
- Verify all node references are set correctly

## 13. Advanced Features

### Scope System:
- Set `has_scope: true` in aim_config
- Configure scope_fov and scope_position_offset
- Add scope overlay UI

### Aim Assist:
- Enable `aim_assist_enabled` in aim_config
- Implement aim assist logic in camera system

### Weapon Attachments:
- Create attachment system
- Modify aim_config based on attachments
- Add attachment UI

This system is designed to be modular and easily extensible. You can add new weapon types, modify aiming characteristics, and add advanced features as needed. 
