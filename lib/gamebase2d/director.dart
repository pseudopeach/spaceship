class Director{
  static Director _instance;
  num lastTime;
  GameMap map;
  
  static Director get inst{
    if(_instance == null)
      _instance = new Director();
    return _instance;
  }
  
  static void start() {
    window.animationFrame.then(firstFrame);
    //window.animationFrame.then(gameLoop);
  }
  
  
  static void pause(){
    
  }
  static void resume(){
    
  }
  void firstFrame(num time) {
    lastTime = time;
    window.animationFrame.then(gameLoop);  
  }
  
  
  void gameLoop(num time){
    num dt = (time - lastTime)/1000.0;
    lastTime = time;
    //showFps(1.0/dt);
    
    context.clearRect(0, 0, width, height);
    context..lineWidth = 0.5;
    
    collisionManager.update();
    collisionManager.checkCollisions();
    //debug();
    //bounceEdges();
    
    map.update(dt);
           
    window.animationFrame.then(gameLoop);
  }
}