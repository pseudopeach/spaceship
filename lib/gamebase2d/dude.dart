part of gamebase2d;

///Dudes move and have AI. They can be in a base and can be killed.
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
  bool isTakingShot = false;
  num _inertia;
  
  //CollidableBody targetBody;
  
  Autopilot autoPilot;
  Vector3 controlInput;
  Weapon weapon;
  
  Dude(){
    _movement = new InertialBody();
    collisionProfile.center = position;
    autoPilot = new Autopilot(this);
  }
  
  // ==== Commando API ====
  void moveTo(Vector2 pos, [num tOri=null]){
    autoPilot.setMission(position:pos, theta:tOri, velocity: new Vector2.zero());
  }
  
  void attack(CollidableBody target){
    _task = target;
    target.watchFor(GameEvent.BODY_REMOVED).listen((e)=>beIdle());
  }
  
  void beIdle(){
    print("dude $this idle");
    _task = null;
    weapon.fireAtWill = false;
    autoPilot.cancelMission();
    GameEvent event = new GameEvent(type:GameEvent.BODY_IDLE,body:this);
    eventCtrl.add(event);
  }
  
  // ==== Callbacks ====
  void executeTask(){
    if(_task is CollidableBody){
      //seek and destroy body
      CollidableBody targetBody = _task;
      
      //check how good a shot we have
      num goodness = weapon.prepareToFire(targetBody);
      
      //switch modes according to shot goodness with a "deadband"
      if(goodness < .5){print("follow mode");
        isTakingShot = false;
      }else if(goodness > .75){
        isTakingShot = true;}
      
      //be shooting unless it's hopeless
      weapon.fireAtWill = goodness > .10;
    
      //if in shooting mode, lock theta to firing angle
      autoPilot.isLockedOnTarget = isTakingShot;
      if(isTakingShot)
        autoPilot.setMission(theta: weapon.firingAngle);
      
      //continue to manuver no matter what
      autoPilot.seekFiringPosition(targetBody, weapon);
  
    }else if(_task is Vector2){
      //seek position
      Vector2 targetPos = _task;
      autoPilot.setMission(position: targetPos, velocity:new Vector2.zero());
    }
  }
  
  void onApproach(CollidableBody other){
    autoPilot.checkCollisionForecast(other);
  }
  
  void onCollidedWith(CollidableBody other){
    //todo***
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
  set mass(num value){
    _movement.mass = value;
    autoPilot.controller.calcKGains();
  }
  
  num get inertia => _inertia;
  set inertia(num value){
    _inertia = value;
    autoPilot.controller.calcKGains();
  }
  
  Vector2 get position => _movement.position;
  set position(Vector2 value)=> _movement.position = value;
  
  Vector2 get velocity => _movement.velocity;
  set velocity(Vector2 value)=> _movement.velocity = value;
  
  Vector2 get force => _movement.force;
  set force(Vector2 value)=> _movement.force = value;
  
  Stream<GameEvent> get allEvents => eventCtrl.stream;
  
  Stream<GameEvent> watchFor(String type) => 
      eventCtrl.stream.where((e)=>e.type==type);
 
  void bounceOff(Vector2 surfDir) => _movement.bounceOff(surfDir);
}