part of gamebase2d;

abstract class Level{
  GameMap map;
  
  void initLevel();
  
  void startLevel();
  
  bool checkForEndCondition();
  
}