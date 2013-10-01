part of gamebase2d;
typedef Projectile Builder();

class Weapon<T>{
  double firingDelay;
  double projectileRange;
  Dude host;
  
  static const double FIRING_SPEED = 150.0; //px/s
  Builder _projectileType;
  Timer fireer;
  
  Weapon({this.host, Builder projectileType}){
    this.projectileType = projectileType;
  }
  
  bool isInRange(CollidableBody body){
    return (body.position - host.position).length < projectileRange;
  }
  double firingAngle = 0.0;
  double getFiringSolution(CollidableBody target){
    Vector2 diff = target.position - host.position;
    double dist = diff.length;
    firingAngle = Math.atan2(diff.y, diff.x);
    
    if(target is InertialBody){
      Vector2 relV = (target as InertialBody).velocity - host.velocity;
      double relS = 1.0/relV.normalizeLength();
      //print("relS $relS");
      if(relS > .1){
        //correct for relative speed
        double sinCorr = relS/FIRING_SPEED * diff.cross(relV) / dist;
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
    if(!firingAngle.isNaN && (host.theta - firingAngle).abs()<.1)
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
  }
  
  
}