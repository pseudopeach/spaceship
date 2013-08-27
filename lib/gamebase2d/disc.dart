part of gamebase2d;

class Disc extends MapSprite implements CollidableBody{
  num _radius = 1;
  String color = "black";
  InertialBody movement;
  MapRect collisionProfile;
  bool isCollidable = true;
  num get radius => _radius;
  set radius(num value){
    _radius = value;
    collisionProfile.width = collisionProfile.height = 2*value;   
  }
  MapRect get boundingRect => collisionProfile;
  
  bool isColliding = false;
  
  Disc(){
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
  
  void approach(CollidableBody other){
    Disc otherDisc = other;
    //print("collision ${this.radius} with ${otherDisc.radius}");
    num d2 = (otherDisc.position - this.position).length2;
    num rsum2 = Math.pow(this.radius + otherDisc.radius,2);
    //print("sum is $d2, threshold is $rsum2");
    if(otherDisc==null) return;
    if((otherDisc.position - this.position).length2 < Math.pow(this.radius + otherDisc.radius,2))
      collideWith(otherDisc);
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