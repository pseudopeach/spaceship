part of gamebase2d;
class LinearController{
  final num toopi = Math.PI*2.0;
  static const String CONTROL_MODE_STATION = "station";
  static const String CONTROL_MODE_CRUISE = "cruise";
  static const String CONTROL_MODE_ATTACK = "attack";
  static const String CONTROL_MODE_EVADE = "evade";
  
  num thrustForwardMax = 80000.0;
  num thrustBackwardMax = 20000.0;
  num thrustLateralMax = 20000.0;
  num thrustMomentMax = 20000.0;
  
  ///align the ship to the desired control force, overriding [targetTheta]
  bool useDirectionOverride = false;
  
  String mode = CONTROL_MODE_STATION; //station, cruise, attack, evade
  
  num _dampingRatio = 0.7071;
  num _natFreq = 0.1;
  
  //Vector2 targetPosition;
  num targetTheta;
  
  Vector2 _nextPosition;
  num _nextTheta;
  
  Vector2 kGains = new Vector2.zero();
  Matrix2 posState = new Matrix2.zero();
  
  Dude plant;
  
  LinearController(this.plant);
  
  Vector2 get targetPosition => _nextPosition;
  set targetPosition(Vector2 value) => _nextPosition = value;
  
  Vector3 getCommand(){
    //get desired force and moment
    Vector3 out = new Vector3.zero();
    Vector2 des;
    
    if(_nextPosition != null){
      posState.setColumns(plant.position-_nextPosition, plant.velocity);
    
      des = posState * kGains;
      
      Vector2 thrust = getThrusterOutput(des);
      //print("state:$posState gains:$kGains des:$des");
      out.xy = plant.rotation * thrust;
      //out.xy = des;
      if(!useDirectionOverride && thrust.length * 2.5 < des.length)
        useDirectionOverride = true;
      if(useDirectionOverride && des.length < thrustLateralMax)
        useDirectionOverride = false;
    }
    _nextTheta = useDirectionOverride && des!=null ?
        Math.atan2(des.y, des.x) : targetTheta;
    
    out.z = getMomentCommand();
      
    return out;
  }
  
  Vector2 getThrusterOutput(Vector2 desired){
    Vector2 bodyAligned = plant.rotation.transposed() * desired;
    if(bodyAligned.x > thrustForwardMax)
      bodyAligned.x = thrustForwardMax;
    else if(bodyAligned.x < -thrustBackwardMax)
      bodyAligned.x = -thrustBackwardMax;
    if(bodyAligned.y.abs() > thrustLateralMax)
      bodyAligned.y = thrustLateralMax * (bodyAligned.y>0?1:-1);
    return bodyAligned;
  }
  
  num getMomentCommand(){
    num error = (plant.theta - _nextTheta)%toopi;
    if(error < -Math.PI) error += toopi;
    else if(error > Math.PI) error -= toopi;
    
    num moment = -plant.inertia*(
        4.0*_dampingRatio*_natFreq*plant.omega +
        4.0*_natFreq*_natFreq*error
    );
    
    if(moment.abs() > thrustMomentMax)
      moment = thrustMomentMax * (moment>0?1.0:-1.0);
    //print("error:$error moment:$moment");
    return moment;
  }
 
  set dampingRatio(num value){
    _dampingRatio = value.toDouble();
    calcKGains(); 
  }
  num get dampingRatio => _dampingRatio;
  
  set natFreq(num value){
    _natFreq = value.toDouble();
    calcKGains();
  }
  num get natFreq => _natFreq;
  
  void calcKGains(){
    kGains.setValues(
        -_natFreq*_natFreq*plant.mass, 
        -2.0*_dampingRatio*_natFreq*plant.mass);
  }
  
}