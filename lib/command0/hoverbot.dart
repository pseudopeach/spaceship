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
    inertia = 10000.0;
    controller = new LinearController(this);
    controller.dampingRatio = 0.7071;
    controller.natFreq = 2.0;
    
  }
  
  LinearController controller;
  
  void updateBeforeDraw(num dt){
    Vector3 controlInput = controller.getCommand();
    force += controlInput.xy;
    //print(controlInput);
    //print("thrust ${controlInput.xy}");
    omega += controller.getCommand().z/inertia*dt;
    super.updateBeforeDraw(dt);
  }
}

