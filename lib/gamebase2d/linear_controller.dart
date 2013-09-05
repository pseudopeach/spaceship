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
  bool _usingDirectionOverride = false;
  bool _usingCruiseMode = false;
  
  String mode = CONTROL_MODE_STATION; //station, cruise, attack, evade
  
  num _dampingRatio = 0.7071;
  num _natFreq = 0.1;
  num _cruisingSpeed = 150.0;
  num _stoppingDistance2;
  
  //Vector2 targetPosition;
  num targetTheta;
  
  Vector2 _nextPosition;
  Vector2 _nextVelocity;
  num _nextTheta;
  
  Vector2 kGains = new Vector2.zero();
  Matrix2 feedbackState = new Matrix2.zero();
  
  Dude plant;
  
  LinearController(this.plant);
  
  Vector2 get targetPosition => _nextPosition;
  set targetPosition(Vector2 value) => _nextPosition = value;
  
  ///determines control command to be applied to the plant
  Vector3 getCommand(){
    Vector3 out = new Vector3.zero();
    Vector2 des;
    
    //position seeking
    if(_nextPosition != null){
      Vector2 posError = plant.position-_nextPosition;
      
      //if we are far from _nextPosition, enter cruise mode
      
      _usingCruiseMode = posError.length2 > _stoppingDistance2;
      
      
      if(_usingCruiseMode){
        _nextVelocity = posError.scaled(-cruisingSpeed/posError.length);
        feedbackState.setZero();
        feedbackState.setColumn(1, plant.velocity-_nextVelocity);
      }else
        feedbackState.setColumns(plant.position-_nextPosition, plant.velocity);
    
      //calc thrust inputs
      des = feedbackState * kGains;
      //print(feedbackState);
      //print("desired force $des, cruise:$_usingCruiseMode");
      Vector2 thrust = getThrusterOutput(des);
      out.xy = plant.rotation * thrust;
      
      //apply _direction override (if applicable)
      if(!_usingDirectionOverride && thrust.length * 2.5 < des.length)
        _usingDirectionOverride = true;
      if(_usingDirectionOverride && des.length < thrustLateralMax)
        _usingDirectionOverride = false;
    }
    
    //calc rotation command
    _nextTheta = _usingDirectionOverride && des!=null ?
        Math.atan2(des.y, des.x) : targetTheta;
    
    out.z = getMomentCommand();
      
    return out;
  }
  
  Vector2 bodyAlignedThrust = new Vector2.zero();
  Vector2 getThrusterOutput(Vector2 desired){
    bodyAlignedThrust = plant.rotation.transposed() * desired;
    Vector2 bat = bodyAlignedThrust;
    if(bat.x > thrustForwardMax)
      bat.x = thrustForwardMax;
    else if(bat.x < -thrustBackwardMax)
      bat.x = -thrustBackwardMax;
    if(bat.y.abs() > thrustLateralMax)
      bat.y = thrustLateralMax * (bat.y>0?1:-1);
    return bat;
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
  
  set cruisingSpeed(num value){
    _cruisingSpeed = value.toDouble();
    calcKGains();
  }
  num get cruisingSpeed => _cruisingSpeed;
  
  void calcKGains(){
    kGains.setValues(
        -_natFreq*_natFreq*plant.mass, 
        -2.0*_dampingRatio*_natFreq*plant.mass);
    _stoppingDistance2 = Math.pow(
        1.1*(kGains.g*cruisingSpeed-thrustForwardMax)/kGains.r,
    2.0);
  }
  
}