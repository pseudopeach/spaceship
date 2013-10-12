part of gamebase2d;

class Autopilot{
  
  Dude host;
  LinearController controller;
  bool isLockedOnTarget = false;
  
  Autopilot(this.host){
    controller = new LinearController(host);
    controller.dampingRatio = 0.85;
    controller.natFreq = 2.0;
  }
  
  Vector2 missionPos = new Vector2.zero();
  Vector2 missionV = new Vector2.zero();
  num missionTheta;
  bool setMission({Vector2 position, num theta, Vector2 velocity}){
    controller._usingDirectionOverride = !isLockedOnTarget;
    if(theta != null && !theta.isNaN){
      missionTheta = theta;
      controller.targetTheta = theta;
    }
    if(position != null){
      //print("target position set: $position");
      missionPos = position;
      controller.targetPosition = position;
    }
    if(velocity != null){
      missionV = velocity;
      controller.targetVelocity = velocity;
    }else 
      controller.targetVelocity = null;
  }
  
  void seekFiringPosition(CollidableBody target, Weapon weapon){
    //close distance and orbit
    weapon.vectorToTarget.copyInto(missionPos);
    missionPos.negate().normalize();
    missionV.setValues(-missionPos.y,missionPos.x);
    num vCir = Math.sqrt(controller.thrustForwardMax/2 * weapon.preferredRange / host.mass);
    if(weapon.targetTravelDirection.cross(weapon.vectorToTarget) > 0.0)
      vCir *= -1.0;
    
    missionV.scale(vCir);
    if(target is InertialBody)
      missionV.add((target as InertialBody).velocity);
    missionPos.scale(weapon.preferredRange).add(target.position);
    
    controller.targetPosition = missionPos;
    controller.targetVelocity = missionV;
    num dot = (missionPos-target.position).cross(missionV);
    //print("eint:${controller.errorInt} ");
  }
  
  void cancelMission(){
    
  }
  
  void checkCollisionForecast(CollidableBody other){
    
  }
  
  Vector3 getCommand(num dt) => controller.getCommand(dt);
  Vector2 get bodyAlignedThrust => controller.bodyAlignedThrust;
  
}