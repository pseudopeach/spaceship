part of gamebase2d;

///moves and has awareness
class Dude extends VectorSprite implements CollidableBody, InertialBody{
  MapRect collisionProfile = new MapRect(50,50);
  InertialBody _movement;
  bool isCollidable = true;
  num inertia;
  
  LinearController controller;
  Vector3 controlInput;
  
  
  set observationRange(num value){
    collisionProfile.width = value*2;
    collisionProfile.height = value*2;
  }
  
  Dude(){
    _movement = new InertialBody();
    this.position = _movement.position;
  }
  
  void approach(CollidableBody other){
    
  }
  
  void collideWith(CollidableBody other){
    
  }
  
  
  void updateBeforeDraw(num dt){
    //controlInput = controller.getCommand();
    //_movement.force += controlInput.xy;
    //omega += dt*controlInput.z/inertia;
    
    _movement.update(dt);
    super.updateBeforeDraw(dt);
  }
  
  void update(num dt) => updateBeforeDraw(dt);
  
  num get mass => _movement.mass;
  set mass(num value) => _movement.mass = value;
  
  Vector2 get velocity => _movement.velocity;
  set velocity(Vector2 value)=> _movement.velocity = value;
  
  Vector2 get force => _movement.force;
  set force(Vector2 value)=> _movement.force = value;
}