part of gamebase2d;
typedef Projectile Builder();

class Weapon{
  double firingDelay;
  double projectileRange;
  double projectileLifespan;
  Dude host;
  
  static const double FIRING_SPEED = 250.0; //px/s
  Builder _projectileType;
  Timer fireer;
  
  Weapon({this.host, Builder projectileType}){
    this.projectileType = projectileType;
  }
  
  double firingAngle = 0.0;
  double firingOmega = 0.0;
  Vector2 vectorToTarget;
  //Vector2 targetTravelDirection;
  Vector2 targetRelVel;
  Vector2 rangeAlignedVel;
  //num targetRelSpeed;
  num rangeToTarget;
  num effectiveRange;
  num rSpeed;
  Matrix2 transform = new Matrix2.zero();
  num prepareToFire(CollidableBody target){
    vectorToTarget = target.position - host.position;
    
    Vector2 tDir = vectorToTarget.clone();
    rangeToTarget = 1.0/tDir.normalizeLength();
    
    targetRelVel = (target as InertialBody).velocity - host.velocity;
    rSpeed = targetRelVel.length;
    
    transform.setRow(0, tDir);
    transform.setRow(1,new Vector2(-tDir.y, tDir.x));
    //print("x,y:$tDir, tr:$transform");
    
    rangeAlignedVel = transform * targetRelVel;
    
    effectiveRange = (FIRING_SPEED-rangeAlignedVel.x)*projectileLifespan;
    
    //no hope scenarios
    if(effectiveRange < rangeToTarget) return 0.0;
    num alignment = calcFiringSolution(target);
    if(firingAngle.isNaN) return 0.0;
    
    return alignment.abs();
  }
  
  num get preferredRange => projectileRange*.6;
  bool isInRange(CollidableBody body){
    return (body.position - host.position).length < projectileRange;
  }
  
  double calcFiringSolution(CollidableBody target){
    firingAngle = Math.atan2(vectorToTarget.y, vectorToTarget.x);
    
    if(target is InertialBody){
      if(rangeAlignedVel.y.abs() > .1){
        //correct for relative speed
        //alg = sin(ang(relVel, range))
        double alignment = rangeAlignedVel.y / rSpeed;
        double sinCorr = rSpeed / FIRING_SPEED * alignment;
        
        firingAngle += Math.asin(sinCorr);
        firingOmega = rangeAlignedVel.y / rangeToTarget;
        //print("firingOmega:$firingOmega");
        return alignment;
      }
    }
    return 1.0; //returns 1
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