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

---


### Mode7World

This is an extension of Mode7 and gives you tools to present billboard sprites, positioned in the world coordinates, using the concept of Mode7Objects. You don't have to use it to do the drawing, but it should help you if you want to!

#### `Mode7World.AddObject`
```
Obj* Mode7World.AddObject(int x, int z, float factor, int graphic)
```

Adds an object, and sets it's x and z position. The y (vertical position) is always zero. You also must pass a scale factor and it's graphics.


#### `Mode7World.RemoveObject`
```
void Mode7World.RemoveObject(int object_i = -1)
```

Remove a specific object from the world by it's index. If you don't pass a value, it will remove the last valid object added.


#### `Mode7World.RemoveAllsObjects`
```
void Mode7World.RemoveAllsObjects()
```

Removes all objects from the Mode7 World.


#### `Mode7World.GetAngleObjectAndCamera`
```
int Mode7World.GetAngleObjectAndCamera(int object_i)
```

Returns the angle in degrees between the camera and whatever angle is set to a specific object, pointed by their index.
Useful when you want to change the graphic of an object based on their relative angle.


#### `Mode7World.UpdateObjects`
```
void Mode7World.UpdateObjects()
```

Update the screen transform of all objects world positions to their screen positions. You must call it before drawing any objects!


#### `Mode7World.DrawObjects`
```
void Mode7World.DrawObjects()
```

Draws only the objects in the screen sprite. You can use when you need to draw additional things between the ground and the objects. 
Or when you don't need the ground at all.


#### `Mode7World.DrawWorld`
```
void Mode7World.DrawWorld()
```

Draws the ground sprite and the objects over it, in the screen sprite.


#### `Mode7World.Objects`
```
writeprotected Obj* Mode7World.Objects[i]
```

Let's you access a specific object in the mode7 world by it's index. Make sure to access a valid position.


#### `Mode7World.ObjectCount`
```
writeprotected int Mode7World.ObjectCount
```

Gets how many objects are currently in the mode7 world.


#### `Mode7World.ObjectScreenVisibleCount`
```
writeprotected int Mode7World.ObjectScreenVisibleCount
```

Gets how many objects are actually visible in the screen.

You can iterate through all the screen objects as follows:

```
for(int i=0; i < m7w.ObjectScreenVisibleCount; i++)
{
  // will make sure to access in order from far to closer
  int index = m7w.ObjectScreenVisibleID[m7w.ObjectScreenVisibleOrder[i]];
  Obj* m7object = m7w.Objects[index];
  
  // do as you you must with you m7object ...
}
```

---

### Mode7Object

A Mode7Object, you should create objects by using Mode7World.AddObject. After world coordinates are set, you can use Mode7World.UpdateObjects to transform it's coordinates and get updated values in it's Screen prefixed properties.

#### `Mode7Object.SetPosition`
```
void Mode7Object.SetPosition(float x, float y, float z)
```

A helper function to setting the Object world position in a single line.


#### `Mode7Object.Draw`
```
void Mode7Object.Draw(DrawingSurface* ds)
```

Draw the object in a DrawingSurface as it would look in a screen.


#### `Mode7Object.X`
```
float Mode7Object.X
```

Object World X Position on the plane.


#### `Mode7Object.Y`
```
float Mode7Object.Y
```

Object World Y Position, perpendicular to plane.


#### `Mode7Object.Z`
```
float Mode7Object.Z
```

Object World Z Position, orthogonal to X position.


#### `Mode7Object.Factor`
```
float Mode7Object.Factor
```

Object Scaling factor to it's graphics.


#### `Mode7Object.Angle`
```
float Mode7Object.Angle
```

Object angle, parallel to plane, not used for rendering.


#### `Mode7Object.Graphic`
```
int Mode7Object.Graphic
```

Object sprite slot, it's width and height is used to calculate the screen coordinates.


#### `Mode7Object.ScreenX`
```
int Mode7Object.ScreenX
```

On-Screen Object X position when drawing, if visible. It's regular top, left coordinates, similar to GUI, assumes a Graphic is set.


#### `Mode7Object.ScreenY`
```
int Mode7Object.ScreenY
```

On-Screen Object Y position when drawing, if visible. It's regular top, left coordinates, similar to GUI, assumes a Graphic is set.


#### `Mode7Object.ScreenWidth`
```
int Mode7Object.ScreenWidth
```

On-Screen Object Width when drawing, if visible. It's adjusted by the sprite used in Graphic, projection and scaling factor.


#### `Mode7Object.ScreenHeight`
```
int Mode7Object.ScreenHeight
```

On-Screen Object Height when drawing, if visible. It's adjusted by the sprite used in Graphic, projection and scaling factor.


#### `Mode7Object.ScreenVisible`
```
bool Mode7Object.ScreenVisible
```

True if object should be drawn on screen. Gets set to false if object is culled when projecting.


#### `Mode7Object.ScreenZOrder`
```
int Mode7Object.ScreenZOrder
```

ZOrder of the object when drawing on screen, smaller numbers are below, bigger numbers are on top.



---

## Demo Graphics copyright

- Clouds: ansimuz - Sunnyland
- Water: zabin - The Battle for Wesnoth Water
- Ship: helianthus games - FREE pixel art Viking ship 16 directions
