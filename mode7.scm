AGSScriptModule    eri0o, Khris mode7 based on Khris AGS Kart mode7 0.3.0 S  // Track script
struct _m7Vector {
  float x, y, z;
};

// filter
bool filter;
int filter_t = 40;

// temporary variables
float _ox[2048];
float _oy[2048];
float _zd[2048];

float point_angle, _angle, z_t, dist, z_dist;
int t_x, t_z, t_w;  // texture coords

int precision = 1000000;


// math utilities
#region MATH_UTILITIES
int
_m7_max(int a, int b)
{
  if (a > b)
    return a;
  return b;
}

int
_m7_min(int a, int b)
{
  if (a < b)
    return a;
  return b;
}

int
_m7_clamp(int v, int min, int max)
{
  return _m7_min(max, _m7_max(v, min));
}

float
_m7_maxf(float a, float b)
{
  if (a > b)
    return a;
  return b;
}

float
_m7_minf(float a, float b)
{
  if (a < b)
    return a;
  return b;
}

float
_m7_clampf(float v, float min, float max)
{
  return _m7_minf(max, _m7_maxf(v, min));
}
#endregion //MATH_UTILITIES

int _NormalizeAngle(int theta) // I verified this is working
{
  
  if(theta >= 0 && theta <= 359) return theta;
  
  while (theta < 0) theta += 360;
  if (theta > 359) theta = theta % 360;
  return theta;
}

void Mode7Object::SetPosition(float x, float y, float z)
{
  this.X = x;
  this.Y = y;
  this.Z = z;  
}

void Mode7Object::Draw(DrawingSurface* ds)
{
  if(!this.Visible) return;
  if(this.ScreenWidth > Screen.Width*2 || this.ScreenHeight > Screen.Height*2) return;
  
  ds.DrawImage(this.ScreenX, this.ScreenY, this.Graphic, 0, this.ScreenWidth, this.ScreenHeight);  
}

void Mode7::SetBgColor(int bg_color)
{
  this._bg_color = bg_color;
  this._empty = DynamicSprite.Create(this._screen_width, this._screen_height, false);
  DrawingSurface* ds = this._empty.GetDrawingSurface();
  ds.Clear(this._bg_color);
  ds.Release();
}

void Mode7::SetSkyColor(int sky_color)
{
  this._sky_color = sky_color;
}

protected void Mode7::_DrawGroundSprites(DrawingSurface* ds, float cam_y, int angle, int ox, int oy)
{  
  float x = -356.0;
  float z = -194.0;
  int sl = 19;
  
  // move track sprite according to camera position
  float sin = Maths.Sin(cam_y);
  float cos = Maths.Cos(cam_y);
  int xx = FloatToInt(x * cos - z * sin, eRoundNearest);
  int zz = FloatToInt(x * sin + z * cos, eRoundNearest);

  DynamicSprite* temp = DynamicSprite.CreateFromExistingSprite(sl);
  if (angle > 0) temp.Rotate(angle);
  xx = ds.Width/2 +  xx - (temp.Width)/2;
  zz = ds.Height/2 + zz - (temp.Height)/2;
  ds.DrawImage(xx, zz, temp.Graphic);
  temp.Delete();
}

protected void Mode7::_GenerateTrackSprite()
{   
  // calculate track angle
  this._track_angle = FloatToInt(-this._camera_angle_y, eRoundNearest);
  this._track_angle = _NormalizeAngle(this._track_angle);
  // lblDebug.Text = String.Format("%d", this._track_angle);
  
  float cam_y = Maths.DegreesToRadians(IntToFloat(this._track_angle));
  
  this._track_sprite = DynamicSprite.CreateFromExistingSprite(this._track_sprite_slot);
  if (this._track_angle > 0) this._track_sprite.Rotate(this._track_angle);
    
  // sprite offset due to rotation
  int ox = (Game.SpriteWidth[this._track_sprite_slot]  - this._track_sprite.Width)  / 2;
  int oy = (Game.SpriteHeight[this._track_sprite_slot] - this._track_sprite.Height) / 2;
  
  // draw trackobjects
  DrawingSurface* ds = this._track_sprite.GetDrawingSurface();
  this._DrawGroundSprites(ds, cam_y, this._track_angle, ox, oy);
  ds.Release();

  // move track sprite according to camera position
  float sin = Maths.Sin(cam_y);
  float cos = Maths.Cos(cam_y);
  float cox_f = this._camera_position_x * cos - this._camera_position_z * sin;
  float coz_f = this._camera_position_x * sin + this._camera_position_z * cos;
  int cox = FloatToInt(cox_f, eRoundNearest);
  int coz = FloatToInt(coz_f, eRoundNearest);
  
  // final position of rotated track sprite on track canvas
  int x = (this._track_canvas_size/2 - Game.SpriteWidth[this._track_sprite_slot]/2  + ox) - cox;
  int y = (this._track_canvas_size/2 - Game.SpriteHeight[this._track_sprite_slot]/2 + oy) - coz + this._track_canvas_y_offset;
  this._track_sprite.ChangeCanvasSize(this._track_canvas_size, this._track_canvas_size, x, y); 
}


protected void Mode7::_DrawTrack3D()
{
  // avoid regenerating if parameters don't change
  if(  this._prev_ground_sprite_slot == this._track_sprite_slot &&
    this._prev_camera_position_x == this._camera_position_x &&
    this._prev_camera_position_y == this._camera_position_y &&
    this._prev_camera_position_z == this._camera_position_z &&
    this._prev_camera_angle_x == this._camera_angle_x &&
    this._prev_camera_angle_y == this._camera_angle_y)
  {
    return;  
  }  

  this._GenerateTrackSprite();
  
  if(this._empty == null) {
    this.SetBgColor(0);
  }
  
  this._ground_3d = DynamicSprite.CreateFromExistingSprite(this._empty.Graphic, false);
  int ground_graphic = this._track_sprite.Graphic;
  
  DrawingSurface* ds = this._ground_3d.GetDrawingSurface();

  // "skybox"
  ds.DrawingColor = this._sky_color;
  // calculate horizon
  int hor_y = this._screen_y + this._screen_height/2 - FloatToInt(Maths.Tan(Maths.DegreesToRadians(this._camera_angle_x)) * this._camera_dist, eRoundNearest);
  if (hor_y >= 0 && this._horizon_sprite_slot > 0) {
    ds.DrawRectangle(0, 0, this._screen_width - 1, hor_y - 1);
    if(this._is_horizon_dynamic) {
      int sbx = ((this._track_angle*256)/60) % 256 - 256;
      ds.DrawImage(sbx, hor_y - Game.SpriteHeight[this._horizon_sprite_slot], this._horizon_sprite_slot);
    } else {
      ds.DrawImage(0, hor_y - Game.SpriteHeight[this._horizon_sprite_slot], this._horizon_sprite_slot);
    }
  }

  int y = this._screen_y;
  float y_screen = -IntToFloat(this._screen_height - 1) / 2.0;
  
  // screen width, used for distance calculation
  float s_w = IntToFloat(this._screen_width);
  
  // main loop
  while (y < this._screen_y + this._screen_height) {
    
    // angle between camera's horizon and current scanline
    point_angle = Maths.ArcTan2(y_screen, this._camera_dist);
    // angle between line camera-scanline & ground
    _angle = Maths.DegreesToRadians(this._camera_angle_x) + point_angle;
    // z coordinate of respective ground line
    z_t = this._camera_position_y / Maths.Tan(_angle);
    // distance between camera and ground line
    dist = this._camera_position_y / Maths.Sin(_angle);
    // distance between camera's image plane and ground line, used to shrink scanline
    z_dist = dist * Maths.Cos(point_angle);
    
    // width and x of scan line
    float t_w_f = (s_w * z_dist) / this._camera_dist;
    t_w = FloatToInt(t_w_f, eRoundNearest);
    
    // too far away -> scan line to wide -> grab less, draw centered
    int f = 1;
    int draw_width = this._screen_width + 4; // saw tooth requires wider image
    if (t_w > this._track_canvas_size) {
      f = (precision * t_w) / this._track_canvas_size;
      t_w = this._track_canvas_size;
      t_w_f = IntToFloat(t_w);
      draw_width = (draw_width * precision) / f;
    }
    int draw_x = (this._screen_width - draw_width) / 2;
    
    t_x = (this._track_canvas_size - t_w) / 2;
    // saw tooth correction
    if (t_w % 2) draw_x -= 2;
    
    // calculate y coordinate of line on canvas
    t_z = this._track_canvas_size / 2 - FloatToInt(z_t, eRoundNearest) + this._track_canvas_y_offset;
    bool visible = draw_x > -6 && draw_x < this._screen_width; // 6 is 2 sawtooth plus 4 of wider image 
    if (z_t > 0.0 && t_z >= 0 && t_z < this._track_canvas_size && visible) {
      
      if (filter) {
        ds.DrawImage(draw_x+1, y-1, ground_graphic, filter_t, 
          draw_width-2, 1, 
          t_x, t_z, t_w, 1);
        ds.DrawImage(draw_x-1, y+1, ground_graphic, filter_t, 
          draw_width+2, 1, 
          t_x, t_z, t_w, 1);
      }
      ds.DrawImage(draw_x, y, ground_graphic, 0, 
        draw_width, 1, 
        t_x, t_z, t_w, 1);
    }
    
    y_screen += 1.0;
    y++;
    if (filter) {
      y_screen += 1.0;
      y++;
    }
  }  
  ds.Release();  
  
  this._prev_ground_sprite_slot = this._track_sprite_slot;
  this._prev_camera_position_x = this._camera_position_x;
  this._prev_camera_position_y = this._camera_position_y;
  this._prev_camera_position_z = this._camera_position_z;
  this._prev_camera_angle_x = this._camera_angle_x;
  this._prev_camera_angle_y = this._camera_angle_y;
}

void Mode7::SetCamera(float x, float y, float z, float xa, float ya, float focal_length)
{
  this._camera_position_x = x;
  this._camera_position_y = y;
  this._camera_position_z = z;
  this._camera_dist = focal_length;
}

void Mode7::TargetCamera(float target_x, float target_y, float target_z,  float teta_angle, eCameraTargetType camType, bool is_lazy) 
{  
  _m7Vector target;
  target.x = target_x;
  target.y = target_y;
  target.z = target_z;  
  
  float camera_angle_target = teta_angle;
  

  
  if (camType == eCameraTarget_FollowBehind)
  {
    // set camera behind target
    float behind = 64.0;
   
    // make it lazy
    if(is_lazy) this._camera_angle_y += (camera_angle_target - this._camera_angle_y) * 0.05;
    else this._camera_angle_y = camera_angle_target;
    
    float sin = Maths.Sin(Maths.DegreesToRadians(this._camera_angle_y));
    float cos = Maths.Cos(Maths.DegreesToRadians(this._camera_angle_y));
    this._camera_position_x = target.x - behind * sin;
    this._camera_position_z = target.z + behind * cos;
    
  }
  else if(camType ==  eCameraTarget_FirstPerson)
  {
    this._camera_angle_y = camera_angle_target;
    
    float sin = Maths.Sin(Maths.DegreesToRadians(this._camera_angle_y));
    float cos = Maths.Cos(Maths.DegreesToRadians(this._camera_angle_y));
    this._camera_position_x = target.x;
    this._camera_position_z = target.z;
    
    
  }
  else if (camType == eCameraTarget_Sides) 
  {
    this._camera_position_x = 100.0;
    this._camera_position_z = 100.0;
    float dx = this._camera_position_x-target.x;
    float dz = this._camera_position_z-target.z;
    this._camera_angle_y = -Maths.RadiansToDegrees(Maths.ArcTan2(dx, dz));
    float target_dist = Maths.Sqrt(dx * dx + dz * dz);
    this._camera_angle_x = Maths.RadiansToDegrees(Maths.ArcTan2(this._camera_position_y, target_dist));
    target_dist = target_dist * 3.0;
    if (target_dist < 100.0) target_dist = 100.0;
    this._camera_dist = target_dist;
    //lblDebug.Text = String.Format("%f", this._camera_angle_x);
  }
}

void Mode7::SetViewscreen(int width, int height, int x, int y)
{
  this._screen_x = x;
  this._screen_y = y;
  this._screen_width = width;
  this._screen_height = height;
  this._ground_3d = DynamicSprite.Create(this._screen_width, this._screen_height, false);
}

void Mode7::SetGroundSprite(int ground_graphic)
{
  this._track_canvas_size = 1024;
  this._track_canvas_y_offset = 512;  // camera position on track_canvas below center
  
  this._track_sprite_slot = ground_graphic;
}

void Mode7::SetHorizonSprite(int horizon_graphic, eHorizonType horizon_type)
{
  this._horizon_sprite_slot = horizon_graphic;
  this._is_horizon_dynamic = horizon_type;
}

void Mode7::DebugKeyPress(eKeyCode k)
{
  if (k == eKeyUpArrow   && this._camera_angle_x > -40.0) this._camera_angle_x -= 1.0;
  if (k == eKeyDownArrow && this._camera_angle_x <  55.0) this._camera_angle_x += 1.0;
  if (k == eKeyPlus   && this._camera_dist < 400.0) this._camera_dist += 1.0;
  if (k == eKeyHyphen && this._camera_dist >  10.0) this._camera_dist -= 1.0;
  if (k == eKeyI) this._camera_position_y += 1.0;
  if (k == eKeyK) this._camera_position_y -= 1.0;
  if (k == eKeyO) this._camera_position_x += 1.0;
  if (k == eKeyL) this._camera_position_x -= 1.0;

  // debug
  if (k == eKeyLeftArrow) this._camera_angle_y += 1.0;
  if (k == eKeyRightArrow) this._camera_angle_y -= 1.0;  
}

float Mode7::get_CameraAngleX()
{
  return this._camera_angle_x;
}

void Mode7::set_CameraAngleX(float value)
{
  this._camera_angle_x = _m7_clampf(value, -40.0, 55.0);
}

float Mode7::get_CameraAngleY()
{
  return this._camera_angle_y;
}

void Mode7::set_CameraAngleY(float value)
{
  this._camera_angle_y = _m7_clampf(value, 0.0, 360.0);
}

void Mode7::Draw() 
{  
  this._DrawTrack3D();
  
  this.Screen = DynamicSprite.CreateFromExistingSprite(this._ground_3d.Graphic, false);
}

void Mode7::ResetGround()
{
  if(this.Screen == null) {
    this.Screen = DynamicSprite.CreateFromExistingSprite(this._empty.Graphic, false);
  } else {
    DrawingSurface* surf = this.Screen.GetDrawingSurface();
    surf.DrawImage(0, 0, this._empty.Graphic);
    surf.Release();
  }
}

int Mode7World::GetAngleObjectAndCamera(Mode7Object* m7obj)
{
  float angle_target = m7obj.Angle;
  return _NormalizeAngle(FloatToInt(angle_target - this._camera_angle_y, eRoundNearest));
}

void Mode7World::UpdateObjects(bool do_sort)
{
  int fnd_objects = 0;
  
  // get object's position relative to camera and check distance
  _m7Vector o;
  for (int i=0; i < this.ObjectCount; i++) {
    o.x = this.Objects[i].X;
    o.z = this.Objects[i].Z;
    this.Objects[i].ScreenVisible = false;
   
    // translate object's x,z to camera's coords
    float cox = o.x - this._camera_position_x;
    float coz = -(o.z - this._camera_position_z);
    
    // rotate by negative camera's y angle
    float sin = Maths.Sin(Maths.DegreesToRadians(this._camera_angle_y));
    float cos = Maths.Cos(Maths.DegreesToRadians(this._camera_angle_y));
    o.x = cox * cos - coz * sin;
    o.z = cox * sin + coz * cos;
    
    // object is in front of camera
    if (o.z > 0.0) {
      
      // angle between line from camera to object and ground
      float obj_angle = Maths.ArcTan2(this._camera_position_y - this.Objects[i].Y, o.z);
      dist = o.z / Maths.Cos(obj_angle);
      // translate x angle to camera
      obj_angle -= Maths.DegreesToRadians(this._camera_angle_x);
      o.y = dist * Maths.Sin(obj_angle);
      z_dist = dist * Maths.Cos(obj_angle);
      
      if (z_dist > 0.1 && z_dist < 1024.0) {
        
        // add object to list
        _ox[fnd_objects] = o.x;
        _oy[fnd_objects] = o.y;
        _zd[fnd_objects] = z_dist;
        this.ObjectScreenVisibleID[fnd_objects] = i;
        
        // init z-buffer  
        this.ObjectScreenVisibleOrder[fnd_objects] = fnd_objects;
        fnd_objects++;
      }
    }
  }
  
  this.ObjectScreenVisibleCount = fnd_objects;
  
  // no object visible?
  if (fnd_objects == 0) return;

  // sort found objects
  
  if (do_sort && fnd_objects > 1) {
    // bubble sort   
    for(int i = 0; i < fnd_objects - 1; i++) {
      for (int j = i; j < fnd_objects; j++) {
        if (_zd[this.ObjectScreenVisibleOrder[i]] < _zd[this.ObjectScreenVisibleOrder[j]]) {
          int swap = this.ObjectScreenVisibleOrder[i];
          this.ObjectScreenVisibleOrder[i] = this.ObjectScreenVisibleOrder[j];
          this.ObjectScreenVisibleOrder[j] = swap;
        }
      }
    }
  }
  
  int in,  obin, slot, w, h; // in: fnd_list index, obin: all objects list index
  int x2d, y2d;
  
  
  for (int i=0; i < this.ObjectScreenVisibleCount; i++) {
    in = this.ObjectScreenVisibleOrder[i];
    obin = this.ObjectScreenVisibleID[in];    

    float f = this._camera_dist / _zd[in];
    float factor = this.Objects[obin].Factor;
    
    slot = this.Objects[obin].Graphic;   
    
    // turn into 2D coords
    x2d = this._screen_x + this._screen_width/2  + FloatToInt(_ox[in] * f, eRoundNearest);
    y2d = this._screen_y + this._screen_height/2 + FloatToInt(_oy[in] * f, eRoundNearest);
    // size
    w = FloatToInt(IntToFloat(Game.SpriteWidth[slot])  * f * factor, eRoundNearest);
    h = FloatToInt(IntToFloat(Game.SpriteHeight[slot]) * f * factor, eRoundNearest);
   
    int obj_d_x = x2d - w/2;
    int obj_d_y = y2d - (h*9/10);
    
    this.Objects[obin].ScreenX = obj_d_x;
    this.Objects[obin].ScreenY = obj_d_y;
    this.Objects[obin].ScreenWidth = w;
    this.Objects[obin].ScreenHeight = h;
    this.Objects[obin].ScreenVisible = this.Objects[obin].Visible;
    if(do_sort) {
      this.Objects[obin].ScreenZOrder = i;  
    } else {
      this.Objects[obin].ScreenZOrder = FloatToInt(10000.0 / _zd[in]); 
    }  
  }
}

void Mode7World::DrawObjects()
{ 
  // finally, draw sorted objects
  if(this.Screen == null) this.Screen = DynamicSprite.CreateFromExistingSprite(this._ground_3d.Graphic, false);
  
  DrawingSurface* ds = this.Screen.GetDrawingSurface();
  
  int in, obin,  slot;  // in: fnd_list index, obin: all objects list index
  for (int i=0; i < this.ObjectScreenVisibleCount; i++) {
    in = this.ObjectScreenVisibleOrder[i];
    obin = this.ObjectScreenVisibleID[in];
    
    this.Objects[obin].Draw(ds);
  }
  
  ds.Release();
}

void Mode7World::DrawObjectsOverlay()
{ 
  for (int i=0; i<this.ObjectCount; i++)
  {
    Mode7Object* obj = this.Objects[i];
       
    bool is_visible = obj.ScreenVisible;
    if(is_visible)
    {
      
      if(this.Overlays[i] == null || !this.Overlays[i].Valid) {
        this.Overlays[i] = Overlay.CreateGraphical(obj.ScreenX, obj.ScreenY, obj.Graphic, true);
        this.OverlaysGraphic[i] = obj.Graphic;
      } 
      else if(this.OverlaysGraphic[i] != obj.Graphic) {
        this.Overlays[i] = Overlay.CreateGraphical(obj.ScreenX, obj.ScreenY, obj.Graphic, true);
        this.OverlaysGraphic[i] = obj.Graphic;        
      }
      
      this.Overlays[i].Transparency = 0;
      Overlay* ovr = this.Overlays[i];
            
      if(ovr.X != obj.ScreenX) ovr.X = obj.ScreenX;
      if(ovr.Y != obj.ScreenY) ovr.Y = obj.ScreenY;
      if(ovr.Width != obj.ScreenWidth) ovr.Width = obj.ScreenWidth;
      if(ovr.Height != obj.ScreenHeight) ovr.Height = obj.ScreenHeight;
      if(ovr.ZOrder != obj.ScreenZOrder) ovr.ZOrder = obj.ScreenZOrder;
    } 
    else 
    {
      if(this.Overlays[i] != null) {
        this.Overlays[i].Transparency = 100;
        this.Overlays[i].X = Screen.Width;
        //this.Overlays[i].Remove();
        //this.Overlays[i] = null;
      }
    }
  }
}

void Mode7World::DrawWorld() 
{  
  this._DrawTrack3D();
  
  this.Screen = DynamicSprite.CreateFromExistingSprite(this._ground_3d.Graphic, false);
  
  this.DrawObjectsOverlay();
}

DynamicSprite* Mode7World::DrawWorld2D()
{
  DynamicSprite* dnspr = DynamicSprite.CreateFromExistingSprite(this._track_sprite_slot, false);
  DrawingSurface* surf = dnspr.GetDrawingSurface();
  
  for (int i=0; i < this.ObjectCount; i++) {
    
    Mode7Object* obj = this.Objects[i];
    
    int transparency = 70;
    if(obj.ScreenVisible) transparency = 0;
    
    int obj_x = FloatToInt(obj.X) - 8 + dnspr.Width/2;
    int obj_y = FloatToInt(obj.Z) - 8 + dnspr.Height/2;
    surf.DrawImage(obj_x, obj_y, obj.Graphic, transparency, 16, 16);
  }
  surf.Release();
  return dnspr;
}

Mode7Object* Mode7World::AddObject(int x, int z, float factor, int graphic)
{
  if (this.ObjectCount == MAX_OBJECTS) return null;
    
  Mode7Object* obj = new Mode7Object;
  obj.Visible = true;
  obj.X = IntToFloat(x);
  obj.Y = 0.0;
  obj.Z = IntToFloat(z);
  obj.Factor = factor;
  obj.Graphic = graphic;
  
  this.Objects[this.ObjectCount] = obj;
  this.OverlaysGraphic[this.ObjectCount] = graphic;
  this.Overlays[this.ObjectCount] = Overlay.CreateGraphical(Screen.Width, Screen.Height, graphic, true);
  this.ObjectCount++;
  return this.Objects[this.ObjectCount-1];
}

void Mode7World::AddExternalObject(Mode7Object* m7obj)
{
  if (this.ObjectCount == MAX_OBJECTS) return;
  this.Objects[this.ObjectCount] = m7obj;
  
  this.OverlaysGraphic[this.ObjectCount] = m7obj.Graphic;
  this.Overlays[this.ObjectCount] = Overlay.CreateGraphical(Screen.Width, Screen.Height, m7obj.Graphic, true);
  
  this.ObjectCount++;  
}

void Mode7World::RemoveObject(int object_id)
{
  if (this.ObjectCount == 0 || object_id >= this.ObjectCount) return;
  
  // removes object at the top
  if(object_id < 0) {
    this.ObjectCount--;
    
    this.Objects[this.ObjectCount] = null;
    if(this.Overlays[this.ObjectCount] != null && this.Overlays[this.ObjectCount].Valid) {
      this.Overlays[this.ObjectCount].Transparency = 100;
      this.Overlays[this.ObjectCount].Remove();
    }
    this.Overlays[this.ObjectCount] = null;
    
    return;
  }
  
  // removes object in the middle of array
  for(int i=object_id; i<this.ObjectCount; i++) {
    this.Objects[i] = this.Objects[i+1];
    this.Overlays[i] = this.Overlays[i+1];
  }
  
  this.ObjectCount--;
  
  this.Objects[this.ObjectCount] = null;
  if(this.Overlays[this.ObjectCount] != null && this.Overlays[this.ObjectCount].Valid) {
    this.Overlays[this.ObjectCount].Transparency = 100;
    this.Overlays[this.ObjectCount].Remove();
  }
  this.Overlays[this.ObjectCount] = null;
  
}

void Mode7World::RemoveAllsObjects()
{
  while(this.ObjectCount > 0) {
    this.RemoveObject(-1);
  }
} F  // new module header
#define MAX_OBJECTS 2048

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
  import void UpdateObjects(bool do_sort = true);
  /// Draws only the objects in the screen sprite. You can use when you need to draw additional things between the ground and the objects. Or when you don't need the ground at all.
  import void DrawObjects();
  /// Draws objects as overlays, without rasterizing at the screen sprite.
  import void DrawObjectsOverlay();
  
  /// Draws the ground sprite and the objects over it, in the screen sprite.
  import void DrawWorld();
  /// Gets a dynamic sprite with the world draw in top down view, useful for debugging.
  import DynamicSprite* DrawWorld2D();
  
  /// Let's you access a specific object in the mode7 world by it's index. Make sure to access a valid position.
  Mode7Object* Objects [MAX_OBJECTS];
  
  writeprotected int OverlaysGraphic [MAX_OBJECTS];
  writeprotected Overlay* Overlays [MAX_OBJECTS];
  /// Gets how many objects are currently in the mode7 world.
  writeprotected int ObjectCount;  
  writeprotected int ObjectScreenVisibleCount;
  writeprotected int ObjectScreenVisibleOrder[MAX_OBJECTS];
  writeprotected int ObjectScreenVisibleID[MAX_OBJECTS];
}; ?w!        fj????  ej??