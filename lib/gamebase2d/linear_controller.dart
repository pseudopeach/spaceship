part of gamebase2d;
class LinearController{
  //final num toopi = Math.PI*2.0;
  
  num thrustForwardMax = 80000.0;
  num thrustBackwardMax = 20000.0;
  num thrustLateralMax = 20000.0;
  num thrustMomentMax = 160000.0;
  final num thetaIntegralGain = 0.8;
  
  ///align the ship to the desired control force, overriding [targetTheta]
  bool _usingDirectionOverride = false;
  bool _usingCruiseMode = false;
  
  num _dampingRatio = 0.7071;
  num _natFreq = 0.1;
  Vector3 _thetaPID;
  num _overallThetaGain = 12.0;
  num _cruisingSpeed = 150.0;
  num _stoppingDistance2;
  
  Vector2 targetPosition;
  Vector2 targetVelocity;
  num targetTheta;
  num targetOmega;
  
  Vector2 kGains = new Vector2.zero();
  Matrix2 feedbackState = new Matrix2.zero();
  
  Dude plant;
  
  LinearController(this.plant);
  
  ///determines control command to be applied to the plant
  Vector3 getCommand(num dt){
    Vector3 out = new Vector3.zero();
    Vector2 des;
    
    //position seeking
    if(targetPosition != null){
      Vector2 posError = plant.position-targetPosition;
      
      //if we are far from targetPosition, enter cruise mode
      
      _usingCruiseMode = posError.length2 > _stoppingDistance2;
      
      if(false && _usingCruiseMode){
        Vector2 cruiseVel = posError.scaled(-cruisingSpeed/posError.length);
        feedbackState.setZero();
        feedbackState.setColumn(1, plant.velocity-cruiseVel);
      }else
        feedbackState.setColumns(posError, plant.velocity-targetVelocity);
    
      //calc thrust inputs
      des = feedbackState * kGains;
      //print("desired force $des, cruise:$_usingCruiseMode");
      Vector2 thrust = getThrusterOutput(des);
      out.xy = plant.rotation * thrust;
      
      //print("desired thrust des=$des, s=$feedbackState k=$kGains");
      //apply _direction override (if applicable)
      if(!_usingDirectionOverride && thrust.length * 2.5 < des.length)
        _usingDirectionOverride = true;
      if(_usingDirectionOverride && des.length < thrustLateralMax)
        _usingDirectionOverride = false;
    }
    
    //calc rotation command
    targetTheta = _usingDirectionOverride && des!=null ?
        Math.atan2(des.y, des.x) : targetTheta;
    
    out.z = getMomentCommand(dt);
     
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
  
  //List<num> thErrors = [0.0,0.0,0.0];
  //List<num> momentsPast = [0.0,0.0,0.0];
  //num overallThetaGain = 5.0;
  num _intThetaError = 0.0;
  num getMomentCommand(num dt){
    if(targetTheta == null) return 0.0;
    
    num error = thetaDiff(targetTheta, plant.theta);
    num errorD = (targetOmega != null ? targetOmega : 0.0) - plant.omega;
    _intThetaError += error * dt - .15*_intThetaError;
    //print("integrated:${_intThetaError} error:$error");
    
    //PID control
    //transfer function
    //K*(s^2+kp*s+ki)/s
    num moment = _thetaPID.dot(
        new Vector3(error, _intThetaError, errorD)
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
    _thetaPID = new Vector3(4.0,1.0,1.0);
    _thetaPID.scale(_overallThetaGain * plant.inertia);
  }
  
}