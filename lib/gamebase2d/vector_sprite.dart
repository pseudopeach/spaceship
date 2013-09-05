part of gamebase2d;

///something that has a definite shape and rotation that can be drawn on the map
class VectorSprite extends MapSprite implements Rotational{
  num _theta = 0;
  num omega; //only happens if it's set
  MapRect boundingRect;
  
  Matrix2 rotation = new Matrix2.identity();
  
  List<Vector2> points;
  
  num get theta => _theta;
  set theta(num value){
    rotation.setRotation(value);
    _theta = value;
  }
  
  void draw(CanvasRenderingContext2D context, [Matrix3 transform]){
    //transform = transform != null ? transform*rotation : rotation;
    //implement drawing
    Vector2 p = rotation * points[0] + position;
        
    context.beginPath();
    context.moveTo(p.x, p.y);
    for(int i=1;i<points.length;i++){
      p = rotation * points[i] + position;
      context.lineTo(p.x, p.y);
    }
    context.closePath();
    context..fill()
        ..stroke();
  }
  
  void updateBeforeDraw(dt){
    if(omega != null){
      theta += omega*dt;
    }
  }
  void updateAfterDraw(){}
}