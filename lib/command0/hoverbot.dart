part of command0;

class Hoverbot extends Dude{
  Hoverbot(){
    Flying _movement = new Flying();
    mass = 1000.0;
    omega=0.0;
    points = [
      new Vector2(25.0,0.0), 
      new Vector2(25.0,10.0),
      new Vector2(-25.0,20.0),
      new Vector2(-25.0,-20.0),
      new Vector2(25.0,-10.0),
      new Vector2(25.0,0.0),
    ];
    thrusters ={
      "x+":[
      new Vector2(-25.0,4.0),  
      new Vector2(-25.0,-4.0)],
      "y-":[
      new Vector2(-5.0,15.0),  
      new Vector2(-7.0,15.0)],
      "y+":[
      new Vector2(-7.0,-15.0),
      new Vector2(-5.0,-15.0)],  
      "x-":[
      new Vector2(25.0,-1.0),
      new Vector2(25.0,1.0)]
      
    };
    inertia = 10000.0;
    controller = new LinearController(this);
    controller.dampingRatio = 0.7071;
    controller.natFreq = 2.0;
    
  }
  
  LinearController controller;
  Map<String,List<Vector2>> thrusters;
  String mainColor = "#cccccc";
  
  void updateBeforeDraw(num dt){
    Vector3 controlInput = controller.getCommand();
    force += controlInput.xy;
    //print(controlInput);
    //print("thrust ${controlInput.xy}");
    omega += controller.getCommand().z/inertia*dt;
    super.updateBeforeDraw(dt);
  }
 
  void draw(CanvasRenderingContext2D context, [Matrix3 transform]){
    
    if(controller.bodyAlignedThrust.x < 0)
      drawFlame(
          thrusters["x-"],
          -controller.bodyAlignedThrust.x/controller.thrustBackwardMax,
          context,transform);
    else
      drawFlame(
          thrusters["x+"],
          controller.bodyAlignedThrust.x/controller.thrustForwardMax,
          context,transform);
    if(controller.bodyAlignedThrust.y < 0)
      drawFlame(
          thrusters["y-"],
          -controller.bodyAlignedThrust.y/controller.thrustLateralMax,
          context,transform);
    else
      drawFlame(
          thrusters["y+"],
          controller.bodyAlignedThrust.x/controller.thrustLateralMax,
          context,transform);
    context.fillStyle = mainColor;
    super.draw(context);
  }
  
  var rng = new Math.Random();
  List<String> flameColors = ["#FFC425", "#FF9932", "#E86922" ,"#FF5325"];
  
  void drawFlame(List<Vector2> port, num percent, CanvasRenderingContext2D context, [Matrix3 transform]){
    
    context.fillStyle = flameColors[rng.nextInt(flameColors.length)];    
    context.beginPath();
    
    
    Vector2 p0 = port[0];
    Vector2 p1 = port[1]-p0;
    Vector2 pn = new Vector2(p1.y, -p1.x);
    pn.scale(100.0/p1.length);
    Vector2 pp = p0+p1.scale(0.5)+pn.scale(percent.toDouble());
    p0 = rotation * port[0] + position;
    pp = rotation * pp + position;
    p1 = rotation * port[1] + position;
    context.moveTo(p0.x, p0.y);
    context.lineTo(pp.x, pp.y);
    context.lineTo(p1.x, p1.y);
    
    context.closePath();
    context..fill()
        ..stroke();
  }
  
}

