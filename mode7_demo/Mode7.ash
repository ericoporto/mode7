// new module header
#define MAX_OBJECTS 100

enum eCameraTargetType {
  eCameraTarget_FollowBehind,
  eCameraTarget_Sides,
};

enum eHorizonType {
  eHorizonStatic = 0,
  eHorizonDynamic = 1,
};

managed struct Obj {
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
};

struct Mode7 {
  import void SetCamera(float x, float y, float z, float xa, float ya, float focal_length);
  import void SetViewscreen(int x, int y, int width, int height);
  import void SetGroundSprite(int ground_graphic);
  import void SetHorizonSprite(int horizon_graphic, eHorizonType = eHorizonDynamic);
  import void SetBgColor(int bg_color);
  import void SetSkyColor(int sky_color);
  
  import void TargetCamera(float target_x, float target_y, float target_z, float teta_angle, eCameraTargetType camType = eCameraTarget_FollowBehind);
  import void Draw();
  
  import void DebugKeyPress(eKeyCode k);
  
  // screen 
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
  import protected void _CameraTrack(eCameraTargetType camType, float target_x, float target_y, float target_z,  float teta_angle);
  import protected void _DrawTrack3D();
  import protected void _GenerateTrackSprite();
};

struct Mode7World extends Mode7 {
  import void AddObject(int x, int z, float factor, int slot);
  import void UpdateObjects();
  import void SetObj(int slot, float x, float y, float z);
  import void DrawWorld();
    
  
  // objects
  Obj* Objects [MAX_OBJECTS];
  writeprotected int ObjectCount;  
  writeprotected int ObjectScreenVisibleCount;
  writeprotected int ObjectScreenVisibleOrder[MAX_OBJECTS];
  writeprotected int ObjectScreenVisibleID[MAX_OBJECTS];

  // private methods
  import protected void _DrawObjects();
};