part of gamebase2d;

class Projectile extends MapSprite implements CollidableBody{
  num _radius = 1;
  String color = "black";
  InertialBody movement;
  MapRect collisionProfile;
  bool isCollidable = true;
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
    movement.update(dt);
    //super.updateBeforeDraw(dt);
  }
}