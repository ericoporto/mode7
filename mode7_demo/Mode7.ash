// new module header
#define MAX_OBJECTS 100

enum eCameraTargetType {
  eCameraTarget_Behind, 
  eCameraTarget_Sides, 
};

managed struct Obj {
  float X;
  float Y;
  float Z;
  float Factor;
  int Graphic;
  
  int ScreenX;
  int ScreenY;
  int ScreenWidth;
  int ScreenHeight;
  bool ScreenVisible;
  int ScreenZOrder;
  
  float _RelX;
  float _RelY;
};

struct Mode7 {
  import void SetCamera(float x, float y, float z, float xa, float ya, float focal_length);
  import void SetViewscreen(int x, int y, int width, int height);
  import void SetGroundSprite(int ground_graphic);
  import void SetHorizonSprite(int horizon_graphic);
  import void AddObject(int x, int z, float factor, int slot);
  
  import void TargetCamera(float target_x, float target_y, float target_z, float teta_angle, eCameraTargetType camType = eCameraTarget_Behind);
  import void UpdateObjects();
  import void Draw();
  
  import void SetObj(int slot, float x, float y, float z);
  
  import void DebugKeyPress(eKeyCode k);
  
  // screen 
  writeprotected DynamicSprite* Screen;
  
  
  // objects    
  Obj* Object [MAX_OBJECTS];
  writeprotected int ObjectCount;  
  writeprotected int ObjectScreenVisibleCount;
  writeprotected int ObjectScreenVisibleOrder[MAX_OBJECTS];
  writeprotected int ObjectScreenVisibleID[MAX_OBJECTS];
  
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
  protected int _track_sprite_slot, _horizon_sprite_slot;
  protected DynamicSprite* _track_sprite;
  protected DynamicSprite* _ground_3d;
  protected DynamicSprite* _empty;
    
  // private methods
  import protected void _CameraTrack(eCameraTargetType camType, float target_x, float target_y, float target_z,  float teta_angle);
  import protected void _DrawTrackObjects(DrawingSurface* ds, float cam_y, int angle, int ox, int oy);
  import protected void _DrawTrack3D();
  import protected void _GenerateTrackSprite();
  import protected void _DrawObjects();
};