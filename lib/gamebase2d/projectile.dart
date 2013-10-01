part of gamebase2d;

class Projectile extends MapSprite implements CollidableBody{
  
  num _radius = 1;
  ///lifespan of the projectile in seconds, negative for unlimited
  double get LIFESPAN => -1.0;
 
  String color = "black";
  InertialBody _movement;
  
  bool isCollidable = true;
  bool isBouncy = false;
  bool isColliding = false;
  num get radius => _radius;
  
  MapRect collisionProfile;
  Timer expirer;
  
  StreamController<GameEvent> eventCtrl;
  
  void arm(){
    if(LIFESPAN >= 0){
      expirer = new Timer(
        new Duration( milliseconds:(LIFESPAN*1000).toInt()),
        ()=>expire() );
    }
  }
  
  set radius(num value){
    _radius = value;
    collisionProfile..width = 2*value..height = 2*value;   
  } 
  
  Projectile(){
    _movement = new InertialBody();
    //this.position = _movement.position;
    collisionProfile = new MapRect(radius, radius);
    collisionProfile.center = position;
    eventCtrl = new StreamController<GameEvent>.broadcast();
  }
  
  void draw(CanvasRenderingContext2D context, [Matrix3 transform]){
    //***todo fix for zooming
    color = isColliding ? "#ff0000" : "#0000ff";
    context..fillStyle = color
      ..strokeStyle = color
      ..beginPath()
      ..arc(position.x, position.y, radius, 0, Math.PI * 2, false)
      ..fill()
      ..closePath();
  }
  
  void onApproach(CollidableBody other){
    //nothing
  }
  
  
  void onCollidedWith(CollidableBody other){
    isCollidable = false;
    expirer.cancel();
    GameManager.removeBody(this);
  }
  
  void updateAfterDraw(){
    isColliding = false;
  }
  
  void expire(){
    GameManager.removeBody(this);
  }
  
  Vector2 get position => _movement.position;
  set position(Vector2 value) => _movement.position = value;
  
  Vector2 get velocity => _movement.velocity;
  set velocity(Vector2 value) => _movement.velocity = value;
  
  void updateBeforeDraw(num dt){
    if(isBouncy){
      if(position.x > GameManager.inst.map.right && _movement.velocity.x > 0)
        _movement.bounceOff(new Vector2(0.0,1.0));
      if(position.x < GameManager.inst.map.left && _movement.velocity.x < 0)
        _movement.bounceOff(new Vector2(0.0,1.0));
      if(position.y < GameManager.inst.map.bottom && _movement.velocity.y > 0)
         _movement.bounceOff(new Vector2(1.0,0.0));
      if(position.y < GameManager.inst.map.top && _movement.velocity.y < 0)
        _movement.bounceOff(new Vector2(1.0,0.0));
    }
    _movement.update(dt);
    //super.updateBeforeDraw(dt);
  }
  
  Stream<GameEvent> watchFor(String type) => 
      eventCtrl.stream.where((e)=>e.type==type);
  MapRect get boundingRect => collisionProfile;
}