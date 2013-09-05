part of gamebase2d;

///anything that can be drawn on the map
abstract class MapSprite{
  Vector2 position = new Vector2.zero();
  
  void draw(CanvasRenderingContext2D context, [Matrix3 transform]);
  void updateBeforeDraw(num dt);
  void updateAfterDraw();
  
  MapRect get boundingRect;
}

///embodies basic newtonian physics
class InertialBody{
  num mass = 1;
  Vector2 position = new Vector2.zero();
  Vector2 velocity = new Vector2.zero();
  Vector2 force = new Vector2.zero();
  void update(num dt){
    velocity.add(force.scale(dt/mass));
    position.add(velocity.scaled(dt));
    force.setZero();
  }
}

abstract class Rotational{
  num theta;
  num omega;
  Matrix2 get rotation;
}

class MapRect{
  MapRect(num width, num height){
    this.width = width;
    this.height = height;
  }
  num get top => center.y - _halfHeight;
  num get left => center.x - _halfWidth;
  num get bottom => center.y + _halfHeight;
  num get right => center.x + _halfWidth;
  num _width;
  num get width => _width;
  set width(num value){
    _width = value;
    _halfWidth = value/2;
  }
  num _height;
  num get height => _width;
  set height(num value){
    _height = value;
    _halfHeight = value/2;
  }
  num _halfHeight;
  num _halfWidth;
  Vector2 center;
  
  String toString()=>"t:$top, l:$left, b:$bottom, r:$right";
}

///can be added to the quadtree
abstract class CollidableBody{
  bool get isCollidable;
  void approach(CollidableBody other);
  MapRect get collisionProfile;
  Vector2 get position;
  //String log;
}