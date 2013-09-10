part of gamebase2d;

///moves and has awareness
class Dude extends VectorSprite implements CollidableBody, InertialBody{
  num hitPoints = 1.0;
  dynamic _task;
  
  
  MapRect collisionProfile = new MapRect(50,50);
  num actualBodyRadius = 1.0;
  InertialBody _movement;
  bool isCollidable = true;
  num inertia;
  
  LinearController controller;
  Vector3 controlInput;
  
  Dude(){
    _movement = new InertialBody();
    this.position = _movement.position;
  }
  
  // ==== Commando API ====
  void moveTo(Vector2 pos, [num tOri=null]){
    if(tOri!=null)
      _task = new Vector3(pos.x,pos.y,tOri);
    else
      _task = new Vector2.copy(pos);
  }
  
  void attack(MapSprite target){
    _task = target;
    Director.watch(target);
  }
  
  void beIdle(){
    _task = null;
  }
  
  // ==== Callbacks ====
  void onApproach(CollidableBody other){
    
  }
  
  void onCollideWith(CollidableBody other){
    
  }
  
  void onDamage(num damageValue, [MapSprite attacker=null]){
    hitPoints -= damageValue;
  }
  
  void onTaskComplete(){
    
  }
  
  
  void updateBeforeDraw(num dt){
    //controlInput = controller.getCommand();
    //_movement.force += controlInput.xy;
    //omega += dt*controlInput.z/inertia;
    
    _movement.update(dt);
    super.updateBeforeDraw(dt);
  }
  
  set observationRange(num value){
    collisionProfile.width = value*2;
    collisionProfile.height = value*2;
  }
  
  void update(num dt) => updateBeforeDraw(dt);
  
  num get mass => _movement.mass;
  set mass(num value) => _movement.mass = value;
  
  Vector2 get velocity => _movement.velocity;
  set velocity(Vector2 value)=> _movement.velocity = value;
  
  Vector2 get force => _movement.force;
  set force(Vector2 value)=> _movement.force = value;
}