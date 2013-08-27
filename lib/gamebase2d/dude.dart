part of gamebase2d;

///moves and has awareness
class Dude extends VectorSprite implements CollidableBody, InertialBody{
  MapRect collisionProfile = new MapRect();
  InertialBody _movement;
  bool isCollidable = true;
  
  set observationRange(num value){
    collisionProfile.width = value*2;
    collisionProfile.height = value*2;
  }
  
  Entity(){
    _movement = new InertialBody();
    this.position = _movement.position;
  }
  
  void approach(CollidableBody other){
    
  }
  
  void collideWith(CollidableBody other){
    
  }
  
  void update(dt){
    _movement.update(dt);
    super.update(dt);
  }
}