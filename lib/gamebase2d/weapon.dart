part of gamebase2d;
typedef Projectile Builder();

class Weapon{
  double firingDelay;
  double projectileRange;
  double projectileLifespan;
  Dude host;
  
  static const double FIRING_SPEED = 150.0; //px/s
  Builder _projectileType;
  Timer fireer;
  
  Weapon({this.host, Builder projectileType}){
    this.projectileType = projectileType;
  }
  
  double firingAngle = 0.0;
  Vector2 vectorToTarget;
  Vector2 targetTravelDirection;
  num targetRelSpeed;
  num rangeToTarget;
  num effectiveRange;
  num prepareToFire(CollidableBody target){
    vectorToTarget = target.position - host.position;
    rangeToTarget = vectorToTarget.length;
    effectiveRange = (host.velocity.dot(vectorToTarget) /
        rangeToTarget+FIRING_SPEED)*projectileLifespan;
    
    targetTravelDirection = (target as InertialBody).velocity - host.velocity;
    targetRelSpeed = 1.0/targetTravelDirection.normalizeLength();
    
    //no hope scenarios
    if(effectiveRange < rangeToTarget) return 0.0;
    num alignment = calcFiringSolution(target);
    if(firingAngle.isNaN) return 0.0;
    
    return Math.pow(alignment,2.0);
  }
  
  num get preferredRange => projectileRange*.6;
  bool isInRange(CollidableBody body){
    return (body.position - host.position).length < projectileRange;
  }
  
  double calcFiringSolution(CollidableBody target){
    firingAngle = Math.atan2(vectorToTarget.y, vectorToTarget.x);
    
    if(target is InertialBody){
      if(targetRelSpeed > .1){
        //correct for relative speed
        double alignment = vectorToTarget.cross(targetTravelDirection) / rangeToTarget;
        double sinCorr = targetRelSpeed/FIRING_SPEED * alignment;
            //vectorToTarget.cross(targetTravelDirection) / rangeToTarget;
        
        firingAngle += Math.asin(sinCorr);
        return alignment;
      }
    }
    return 1.0;
  }
  
  Vector2 getFiringPosition(CollidableBody target){
      Vector2 diff = host.position - target.position;
      diff.scale(0.4 * projectileRange / diff.length);
      diff.add(target.position);
      return diff;
  }
  
  void fireIfReady(){
    print("fire e:${thetaDiff(host.theta,firingAngle)}");
    if(!firingAngle.isNaN && thetaDiff(host.theta,firingAngle).abs()<1.0)
      fire();
  }
  //bool shot = false;
  void fire(){
    //print("firing with error ${firingAngle-host.theta}");
    Projectile proj = _projectileType();
    proj.velocity.setValues(FIRING_SPEED, 0.0);
    host.rotation.transform( proj.velocity ).add(host.velocity);
    proj.position.setValues(host.actualBodyRadius+1.0, 0.0);
    host.rotation.transform( proj.position ).add(host.position);
    GameManager.inst.map.addSprite(proj);
    proj.arm();
    //shot = true;
  }
  
  bool _fireAtWill = false;
  
  set fireAtWill(bool value){
    if(value && !_fireAtWill){
      print("firer created");
      fireer = new Timer.periodic(
          new Duration(milliseconds: 500),(t) => fireIfReady());
    }else if(!value && _fireAtWill){
      print("firer $fireer will be canceled");
      if(fireer!=null) fireer.cancel();
    }
    _fireAtWill = value;
  }
  
  Builder get projectileType => _projectileType;
  set projectileType(Builder value){
    _projectileType = value;
    projectileRange = FIRING_SPEED * value().LIFESPAN;
    projectileLifespan = value().LIFESPAN;
  }
  
  
}