part of gamebase2d;

class GameMap{
  List<MapSprite> mapItems = [];
  
  num lastTime;
  CanvasRenderingContext2D context;
  CanvasElement canvas;
  num width;
  num height;
  
  QuadtreeNode collisionManager;
  
  GameMap(this.canvas){
    //CanvasElement canvas = query("#area");
    width = canvas.width;
    height = canvas.height;
    
    Rect rect = canvas.parent.client;
    width = rect.width;
    height = rect.height;
    canvas.width = width;
    
    collisionManager = new QuadtreeNode(right:width, bottom:height);
    
    context = canvas.context2D;
  }
  
  void start() {
    window.animationFrame.then(firstFrame);
    //window.animationFrame.then(gameLoop);
  }
  
  void firstFrame(num time) {
    lastTime = time;
    window.animationFrame.then(gameLoop);  
  }
  
  void addSprite(MapSprite sprite){
    mapItems.add(sprite);
    CollidableBody collidable = sprite as CollidableBody;
    if(collidable != null) collisionManager.insert(collidable);
  }
  void debug(){}
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
    
    for(MapSprite item in mapItems)
      item.updateBeforeDraw(dt);
        
    for(MapSprite item in mapItems)
      item.draw(context);
        
    for(MapSprite item in mapItems)
      item.updateAfterDraw();
           
    window.animationFrame.then(gameLoop);
  }
  
  
  
} //GameMap