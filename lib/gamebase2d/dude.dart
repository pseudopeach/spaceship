part of gamebase2d;

///moves and has awareness
class Dude extends VectorSprite implements CollidableBody, InertialBody{
  num hitPoints = 1.0;
  dynamic _task;
  StreamController<GameEvent> eventCtrl = 
      new StreamController<GameEvent>.broadcast();
  
  MapRect collisionProfile = new MapRect(50,50);
  num actualBodyRadius = 1.0;
  InertialBody _movement;
  bool isCollidable = true;
  bool isBouncy = false;
  num inertia;
  
  LinearController controller;
  Vector3 controlInput;
  
  Dude(){
    _movement = new InertialBody();
    this.position = _movement.position;
    collisionProfile.center = position;
  }
  
  // ==== Commando API ====
  void moveTo(Vector2 pos, [num tOri=null]){
    if(tOri!=null)
      _task = new Vector3(pos.x,pos.y,tOri);
    else
      _task = new Vector2.copy(pos);
  }
  
  void attack(Dude target){
    _task = target;
    target.watchFor(GameEvent.BODY_REMOVED).listen((e)=>beIdle());
  }
  
  void beIdle(){
    _task = null;
    GameEvent event = new GameEvent(type:GameEvent.BODY_IDLE,body:this);
    eventCtrl.add(event);
  }
  
  // ==== Callbacks ====
  void onApproach(CollidableBody other){
    
  }
  
  void onCollideWith(CollidableBody other){
    
  }
  
  void onDamage(num damageValue, [MapSprite attacker=null]){
    hitPoints -= damageValue;
  }
  
  void updateBeforeDraw(num dt){
    //controlInput = controller.getCommand();
    //_movement.force += controlInput.xy;
    //omega += dt*controlInput.z/inertia;
    
    if(isBouncy){
      if(position.x > GameManager.inst.map.right && velocity.x > 0)
        _movement.bounceOff(new Vector2(1.0,0.0));
      if(position.x < GameManager.inst.map.left && velocity.x < 0)
        _movement.bounceOff(new Vector2(1.0,0.0));
      if(position.y > GameManager.inst.map.bottom && velocity.y > 0)
         _movement.bounceOff(new Vector2(0.0,1.0));
      if(position.y < GameManager.inst.map.top && velocity.y < 0)
        _movement.bounceOff(new Vector2(0.0,1.0));
    }
    
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
  
  Stream<GameEvent> get allEvents => eventCtrl.stream;
  
  Stream<GameEvent> watchFor(String type) => 
      eventCtrl.stream.where((e)=>e.type==type);
  Stream<GameEvent> ffff(String type) => 
      eventCtrl.stream.where((e)=>e.type==type);
  void bounceOff(Vector2 surfDir) => _movement.bounceOff(surfDir);
}