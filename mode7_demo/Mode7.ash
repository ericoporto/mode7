// new module header
#define MAX_OBJECTS 512

enum eCameraTargetType {
  eCameraTarget_FollowBehind,
  eCameraTarget_FirstPerson,
  eCameraTarget_Sides,
};

enum eHorizonType {
  eHorizonStatic = 0,
  eHorizonDynamic = 1,
};

managed struct Mode7Object {
  /// Object World X Position
  float X;
  /// Object World Y Position
  float Y;
  /// Object World Z Position
  float Z;
  /// Object graphic scale
  float Factor;
  /// Object graphic
  int Graphic;
  /// Object angle, not used for rendering
  float Angle;
  /// Object visibility
  bool Visible;
  
  /// On-Screen Object X position when drawing, if visible
  int ScreenX;
  /// On-Screen Object Y position when drawing, if visible
  int ScreenY;
  /// On-Screen Object Width when drawing, if visible
  int ScreenWidth;
  /// On-Screen Object Height when drawing, if visible
  int ScreenHeight;
  /// If object should be drawn on screen
  bool ScreenVisible;
  /// ZOrder of the object when drawing on screen, smaller numbers are below, bigger numbers are on top
  int ScreenZOrder;
    
  /// Set's the object position
  import void SetPosition(float x, float y, float z);
  
  /// Draw the object in a DrawingSurface as it would look in a screen
  import void Draw(DrawingSurface* ds);
};

struct Mode7 {
  /// Sets the camera position, angle and focal length
  import void SetCamera(float x, float y, float z, float xa, float ya, float focal_length);
  /// Sets the screen area it will draw in
  import void SetViewscreen(int width, int height, int x = 0, int y = 0);
  /// Sets the ground sprite, this is the mode7 rendered sprite
  import void SetGroundSprite(int ground_graphic);
  /// Sets a sprite that will roll around in the horizon, you can also make it static
  import void SetHorizonSprite(int horizon_graphic, eHorizonType = eHorizonDynamic);
  /// Sets the color of the background where the ground sprite doesn't reach
  import void SetBgColor(int bg_color);
  /// Sets the color of the sky
  import void SetSkyColor(int sky_color);
  
  /// Target the camera to something
  import void TargetCamera(float target_x, float target_y, float target_z, float teta_angle, eCameraTargetType camType = eCameraTarget_FollowBehind, bool is_lazy = true);
  
  /// Draws the ground sprite and horizon rendered in the Screen sprite
  import void Draw();
  
  /// Clears the screen sprite
  import void ResetGround();
  
  
  import void DebugKeyPress(eKeyCode k);
  
  /// The camera angle that is normal to the ground plane (e.g.: up and down)
  import attribute float CameraAngleX;
  import float get_CameraAngleX(); //$AUTOCOMPLETEIGNORE$
  import void set_CameraAngleX(float value); //$AUTOCOMPLETEIGNORE$
  
  /// The camera angle that is on the ground plane (e.g.: left and right)
  import attribute float CameraAngleY;
  import float get_CameraAngleY(); //$AUTOCOMPLETEIGNORE$
  import void set_CameraAngleY(float value); //$AUTOCOMPLETEIGNORE$
  
  /// The Dynamic Sprite that represents the screen where the Mode7 ground is draw to 
  writeprotected DynamicSprite* Screen;  
  
  
  // EVERYTHING BELOW IS INTERNAL TO THE STRUCT AND YOU DON'T NEED TO TOUCH ///
  
  // camera
  // angle y: viewing direction
  // angle x: looking up or down
  protected float _camera_position_x;
  protected float _camera_position_y;
  protected float _camera_position_z;
  protected float _camera_angle_x;
  protected float _camera_angle_y;
  protected float _camera_dist;
  protected int _track_angle;
  
  // view screen
  protected int _bg_color;
  protected int _sky_color;
  protected int _screen_x, _screen_y, _screen_width, _screen_height;
  
  protected int _track_canvas_size;
  // camera position on track_canvas below center
  protected int _track_canvas_y_offset;

  // things to remember to avoid redrawing
  protected int _prev_ground_sprite_slot;
  protected float _prev_camera_position_x;
  protected float _prev_camera_position_y;
  protected float _prev_camera_position_z;
  protected float _prev_camera_angle_x;
  protected float _prev_camera_angle_y;

  // track
  protected bool _is_horizon_dynamic;
  protected int _track_sprite_slot, _horizon_sprite_slot;
  protected DynamicSprite* _track_sprite;
  protected DynamicSprite* _ground_3d;
  protected DynamicSprite* _empty;
    
  // private methods
  import protected void _DrawGroundSprites(DrawingSurface* ds, float cam_y, int angle, int ox, int oy);
  import protected void _DrawTrack3D();
  import protected void _GenerateTrackSprite();
};

struct Mode7World extends Mode7 {
  /// Adds an object, and sets it's x and z position. The y (vertical) position is always zero. You also must pass a scale factor and it's graphics.
  import Mode7Object* AddObject(int x, int z, float factor, int graphic);
  /// Adds an external object that is not managed by the Mode7World. It will still be updated and draw, but removing it from the world will probably not garbage collect it.
  import void AddExternalObject(Mode7Object* m7obj);
  
  /// Removes the object from the world, if there is no external pointers to it, it will be garbage collected. If you don't specify it will remove the top object.
  import void RemoveObject(int object_id = -1);
  /// Removes all objects from the world. Objects without external pointers get garbage collected.
  import void RemoveAllsObjects();
  /// Returns the angle in degrees between the camera and whatever angle is set to a specific object. Useful when you want to change the graphic of an object based on their relative angle.
  import int GetAngleObjectAndCamera(Mode7Object* m7obj);
  /// Update the screen transform of all objects world positions to their screen positions. You must call it before drawing any objects!
  import void UpdateObjects();
  /// Draws only the objects in the screen sprite. You can use when you need to draw additional things between the ground and the objects. Or when you don't need the ground at all.
  import void DrawObjects();
  /// Draws the ground sprite and the objects over it, in the screen sprite.
  import void DrawWorld();
  /// Gets a dynamic sprite with the world draw in top down view, useful for debugging.
  import DynamicSprite* DrawWorld2D();
  
  /// Let's you access a specific object in the mode7 world by it's index. Make sure to access a valid position.
  Mode7Object* Objects [MAX_OBJECTS];
  /// Gets how many objects are currently in the mode7 world.
  writeprotected int ObjectCount;  
  writeprotected int ObjectScreenVisibleCount;
  writeprotected int ObjectScreenVisibleOrder[MAX_OBJECTS];
  writeprotected int ObjectScreenVisibleID[MAX_OBJECTS];
};