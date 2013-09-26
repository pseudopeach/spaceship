part of gamebase2d;
typedef Projectile Builder();

class Weapon<T>{
  double projectileSpeed = 50.0; //px/s
  double projectileLifespan = 5.0; //sec
  double firingDelay = 0.5; //sec
  double projectileRange;

  Dude host;
  
  Builder projectileType;
  Timer fireer;
  
  Weapon({this.host, this.projectileType});
  
  bool isInRange(CollidableBody body){
    
  }
  double firingAngle = 0.0;
  double getFiringSolution(CollidableBody target){
    Vector2 diff = target.position - host.position;
    double dist = diff.length;
    firingAngle = Math.atan2(diff.y, diff.x);
    
    if(target is InertialBody){
      Vector2 relV = (target as InertialBody).velocity - host.velocity;
      double relS = relV.normalizeLength();
    
      if(relS > .1){
        //correct for relative speed
        double sinCorr = relS/projectileSpeed * diff.cross(relV) / dist;
        //if(sinCorr.abs() > 1.0) return; //no firing solution
        firingAngle += Math.asin(sinCorr);
      }
    }
    //host.
    return firingAngle;
  }
  
  Vector2 getFiringPosition(CollidableBody target){
      Vector2 diff = host.position - target.position;
      diff.scale(0.4 * projectileRange / diff.length);
      diff.add(target.position);
      return diff;
  }
  
  void fireIfReady(){
    if(!firingAngle.isNaN && (host.theta - firingAngle).abs()<.2)
      fire();
  }
  
  void fire(){
    Projectile proj = projectileType();
    proj.movement.velocity.setValues(projectileSpeed, 0.0);
    host.rotation.transform( proj.movement.velocity ).add(host.velocity);
    proj.movement.position.setValues(host.actualBodyRadius+1.0, 0.0);
    host.rotation.transform( proj.movement.position ).add(host.position);
    GameManager.inst.map.addSprite(proj);
  }
  
  bool _fireAtWill = false;
  
  set fireAtWill(bool value){
    _fireAtWill = value;
    if(_fireAtWill){
      fireer = new Timer.periodic(
          new Duration(milliseconds: 100),(t) => fireIfReady());
    }else
      fireer.cancel();
  }
  
  
}