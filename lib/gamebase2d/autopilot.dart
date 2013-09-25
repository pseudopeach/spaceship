part of gamebase2d;

class Autopilot{
  
  Dude host;
  LinearController controller;
  
  Autopilot(Dude host){
    this.host = host;
    controller = new LinearController(host);
  }
  
   
  bool setMission({Vector2 position, num theta, Vector2 velocity}){
    
  }
  
  void cancelMission(){
    
  }
  
  void checkCollisionForecast(CollidableBody other){
    
  }
  
  Vector3 getCommand() => controller.getCommand();
  
}