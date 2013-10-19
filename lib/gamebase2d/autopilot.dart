part of gamebase2d;

class Autopilot{
  
  num collisionWarningHorizon = 2.0;
  
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
  bool setMission({Vector2 position, num theta, Vector2 velocity, num omega:0.0}){
    controller._usingDirectionOverride = !isLockedOnTarget;
    if(theta != null && !theta.isNaN){
      missionTheta = theta;
      controller.targetTheta = theta;
      controller.targetOmega = omega;
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
    if(weapon.rangeAlignedVel.y < 0.0)
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
  
  bool _isAvoidingCollision = false;
  void checkCollisionForecast(CollidableBody other){
    Vector2 diff = host.position - other.position;
    Vector2 relVelUnit = host.velocity.clone().negate();
    if(other is InertialBody)
      relVelUnit.sub((other as InertialBody).velocity);   
    
    if(diff.dot(relVelUnit) > 0.0){
      //objects are closing distance
      num speed = 1.0/relVelUnit.normalizeLength();
      num minDist = diff.cross(relVelUnit)/speed;
      
      
      if(minDist < host.actualBodyRadius && diff.length/speed < collisionWarningHorizon){
        //objects will pass very close and that will happen soon
        _isAvoidingCollision = false;
      }
    }
  }
  
  Vector3 getCommand(num dt) => controller.getCommand(dt);
  Vector2 get bodyAlignedThrust => controller.bodyAlignedThrust;
  
}