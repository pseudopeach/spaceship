part of gamebase2d;

class Autopilot{
  
  Dude host;
  LinearController controller;
  
  Autopilot(this.host){
    controller = new LinearController(host);
    controller.dampingRatio = 0.85;
    controller.natFreq = 2.0;
  }
  
  Vector2 missionPos;
  Vector2 missionV;
  num missionTheta;
  bool setMission({Vector2 position, num theta, Vector2 velocity}){
    if(theta != null && !theta.isNaN){
      missionTheta = theta;
      controller.targetTheta = theta;
    }
    if(position != null){
      print("target position set: $position");
      missionPos = position;
      controller.targetPosition = position;
    }
    if(velocity != null){
      missionV = velocity;
      controller.targetVelocity = velocity;
    }else 
      controller.targetVelocity = null;
  }
  
  void cancelMission(){
    
  }
  
  void checkCollisionForecast(CollidableBody other){
    
  }
  
  Vector3 getCommand() => controller.getCommand();
  Vector2 get bodyAlignedThrust => controller.bodyAlignedThrust;
  
}