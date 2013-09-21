part of gamebase2d;

class Projectile extends MapSprite implements CollidableBody{
  num _radius = 1;
  String color = "black";
  InertialBody movement;
  MapRect collisionProfile;
  bool isCollidable = true;
  bool isBouncy = false;
  num get radius => _radius;
  
  
  set radius(num value){
    _radius = value;
    collisionProfile..width = 2*value..height = 2*value;   
  }
  MapRect get boundingRect => collisionProfile;
  //String log = "";
  bool isColliding = false;
  
  Projectile(){
    movement = new InertialBody();
    this.position = movement.position;
    collisionProfile = new MapRect(radius, radius);
    collisionProfile.center = position;
    print("collision center ${collisionProfile.center}");
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
    if((other.position-position).length2 < radius*radius){
      if(radius > 10)
        radius -= 10;
      else
        GameManager.removeBody(this);
    }
  }
  
  
  void collideWith(CollidableBody other){
    isColliding = true;
  }
  
  void updateAfterDraw(){
    isColliding = false;
  }
  
  void updateBeforeDraw(num dt){
    if(isBouncy){
      if(position.x > GameManager.inst.map.right && movement.velocity.x > 0)
        movement.bounceOff(new Vector2(0.0,1.0));
      if(position.x < GameManager.inst.map.left && movement.velocity.x < 0)
        movement.bounceOff(new Vector2(0.0,1.0));
      if(position.y < GameManager.inst.map.bottom && movement.velocity.y > 0)
         movement.bounceOff(new Vector2(1.0,0.0));
      if(position.y < GameManager.inst.map.top && movement.velocity.y < 0)
        movement.bounceOff(new Vector2(1.0,0.0));
    }
    movement.update(dt);
    //super.updateBeforeDraw(dt);
  }
 
}