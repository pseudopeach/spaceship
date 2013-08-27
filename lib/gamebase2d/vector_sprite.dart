part of gamebase2d;

///something that has a definite shape and rotation that can be drawn on the map
class VectorSprite extends MapSprite{
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
    transform = transform != null ? transform*rotation : rotation;
    //implement drawing
  }
  
  void updateBeforeDraw(dt){
    if(omega != null){
      _theta += omega;
    }
  }
  void updateAfterDraw(){}
}