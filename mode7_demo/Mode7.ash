// new module header
#define MAX_OBJECTS 100

enum eCameraTargetType {
  eCameraTarget_Behind, 
  eCameraTarget_Sides, 
};

struct Mode7 {
  import void SetCamera(float x, float y, float z, float xa, float ya, float focal_length);
  import void SetViewscreen(int x, int y, int width, int height);
  import void SetGroundSprite(int ground_graphic);
  import void SetHorizonSprite(int horizon_graphic);
  import void AddObject(int x, int z, float factor, int slot);
  
  import void TargetCamera(float target_x, float target_y, float target_z, float teta_angle, eCameraTargetType camType = eCameraTarget_Behind);
  import void Draw();
  
  import void SetObj(int slot, float x, float y, float z);
  
  import void DebugKeyPress(eKeyCode k);
  
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
  
  // track
  protected int _track_sprite_slot, _horizon_sprite_slot;
  protected DynamicSprite* _track_sprite;
  
  // objects
  protected Overlay* _obj_ovr[MAX_OBJECTS];
  protected float _obj_x[MAX_OBJECTS];
  protected float _obj_y[MAX_OBJECTS];
  protected float _obj_z[MAX_OBJECTS];
  protected float _obj_factor[MAX_OBJECTS];
  protected int _obj_graphic[MAX_OBJECTS];
  protected int _obj_prev_graphic[MAX_OBJECTS];
  protected int _obj_order[MAX_OBJECTS];
  protected int _obj_count;  
  
  // private methods
  import protected void _CameraTrack(eCameraTargetType camType, float target_x, float target_y, float target_z,  float teta_angle);
  import protected void _DrawTrackObjects(DrawingSurface* ds, float cam_y, int angle, int ox, int oy);
  import protected void _DrawTrack3D();
  import protected void _GenerateTrackSprite();
  import protected void _DrawObjects();
};