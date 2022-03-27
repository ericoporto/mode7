# mode7
Adventure Game Studio mode7 script module

<img src="https://user-images.githubusercontent.com/2244442/160260167-0f6ab7a0-fd55-472a-839f-5332f3970476.gif"  alt="mode7 capture" width="640" height="360">

## usage

## Script API

### Mode7

#### `Mode7.SetCamera`
```
void Mode7.SetCamera(float x, float y, float z, float xa, float ya, float focal_length)
```

Sets the camera position, angle and focal length.


#### `Mode7.SetViewscreen`
```
void Mode7.SetViewscreen(int width, int height, optional int x,  optional int y)
```

Sets the screen area it will draw in.


#### `Mode7.SetGroundSprite`
```
void Mode7.SetGroundSprite(int ground_graphic)
```

Sets the ground sprite, this is the mode7 rendered sprite.


#### `Mode7.SetHorizonSprite`
```
void Mode7.SetHorizonSprite(int horizon_graphic, eHorizonType = eHorizonDynamic)
```

Sets a sprite that will roll around in the horizon, you can also make it static.


#### `Mode7.SetBgColor`
```
void Mode7.SetBgColor(int bg_color)
```

Sets the color of the background where the ground sprite doesn't reach.


#### `Mode7.SetSkyColor`
```
void Mode7.SetSkyColor(int sky_color)
```

Sets the color of the sky.


#### `Mode7.TargetCamera`
```
void Mode7.TargetCamera(float target_x, float target_y, float target_z, float teta_angle, eCameraTargetType camType = eCameraTarget_FollowBehind, bool is_lazy = true)
```

Target the camera to something.


#### `Mode7.Draw`
```
void Mode7.Draw()
```

Draws the ground sprite and horizon rendered in the Screen sprite.


#### `Mode7.Screen`
```
DynamicSprite* Mode7.Screen
```

The Dynamic Sprite that represents the screen where the Mode7 ground is draw to.


### Mode7World

---

### Obj

---

## Demo Graphics copyright

- Clouds: ansimuz - Sunnyland
- Water: zabin - The Battle for Wesnoth Water
- Ship: helianthus games - FREE pixel art Viking ship 16 directions
