part of gamebase2d;

class GameMap{
  List<MapSprite> mapItems = [];
  
  
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
  
  void addSprite(MapSprite sprite){
    mapItems.add(sprite);
    CollidableBody collidable = sprite as CollidableBody;
    if(collidable != null) collisionManager.insert(collidable);
  }
  void debug(){}
  
  void update(num dt){
    for(MapSprite item in mapItems)
      item.updateBeforeDraw(dt);
        
    for(MapSprite item in mapItems)
      item.draw(context);
        
    for(MapSprite item in mapItems)
      item.updateAfterDraw();
  }
  
  
} //GameMap