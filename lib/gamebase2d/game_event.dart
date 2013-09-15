part of gamebase2d;
class GameEvent{
  static const String BODY_ADDED = "dudeAdded";
  static const String BODY_REMOVED = "dudeRemoved";
  
  String type;
  CollidableBody body;
  Vector2 location;
  
  GameEvent({this.type, this.body, this.location});
}