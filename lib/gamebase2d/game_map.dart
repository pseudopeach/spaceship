part of gamebase2d;

class GameMap{
  List<MapSprite> mapItems = [];
  
  
  CanvasRenderingContext2D context;
  CanvasElement _canvas;
  num width;
  num height;
  
  num get top => 0.0;
  num get left => 0.0;
  num get right => width;
  num get bottom => height;
  
  QuadtreeNode collisionManager;
  
  void addSprite(MapSprite sprite){
    mapItems.add(sprite);
    CollidableBody collidable = sprite as CollidableBody;
    if(collidable != null){ 
      collisionManager.insert(collidable);
      GameManager.onBodyAdded(collidable);
    }
  }
  
  void removeSprite(MapSprite sprite){
    mapItems.remove(sprite);
    CollidableBody collidable = sprite as CollidableBody;
    if(collidable != null){ 
      if(!collisionManager.remove(collidable)){
        print("WARNING: could not find $collidable in quadtree");
      }
    }
  }
  
  void debug(){}
  
  
  void nextFrame(num dt){
    context.clearRect(0, 0, width, height);
    context..lineWidth = 0.5;
    
    collisionManager.update();
    collisionManager.checkCollisions();
  
    for(MapSprite item in mapItems)
      item.updateBeforeDraw(dt);
        
    for(MapSprite item in mapItems)
      item.draw(context);
        
    for(MapSprite item in mapItems)
      item.updateAfterDraw();
  }
  
  void set canvas(CanvasElement canv){
    _canvas = canv;
    width = _canvas.width;
    height = _canvas.height;
    
    Rect rect = _canvas.parent.client;
    width = rect.width;
    height = rect.height;
    _canvas.width = width;
    
    collisionManager = new QuadtreeNode(right:width, bottom:height);
    
    context = _canvas.context2D;
  }
  
  
} //GameMap