part of gamebase2d;

class Disc extends Dude implements CollidableBody{
  
  String color = "black";
  num radius = 1.0;
  
  MapRect get boundingRect => collisionProfile;
  //String log = "";
  bool isColliding = false;
  
  StreamController<GameEvent> eventCtrl = 
      new  StreamController<GameEvent>.broadcast();
  
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
      other.onCollidedWith(this);
      takeDamage();
    }
  }
  
  void onCollidedWith(CollidableBody other){
    takeDamage();
  }
  
  void takeDamage(){
    //get smaller or die
    if(radius > 5)
      radius -= 5;
    else
      removeSelf();
  }
  
  void removeSelf(){
    print("disc removing self");
    GameEvent e = new GameEvent(body:this, type:GameEvent.BODY_REMOVED);
    eventCtrl.add(e);
    //****todo find a way to only create the event once
    GameManager.removeBody(this);
  }
 
}