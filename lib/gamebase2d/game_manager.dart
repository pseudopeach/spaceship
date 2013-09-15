part of gamebase2d;

class GameManager{
  static GameManager _instance;
  num _lastTime;
  GameMap _map;
  Level _currentLevel;
  StreamController<GameEvent> eventCtrl =
    new StreamController<GameEvent>.broadcast();
  
  CanvasElement _canvas;
  //renderingContext _context;
  
  static GameManager get inst{
    if(_instance == null)
      _instance = new GameManager();
    return _instance;
  }
  
  static void loadLevel(level){
    level.map.canvas = inst._canvas;
    inst._currentLevel = level;
    inst._currentLevel.initLevel();
  }
  
  static void set canvas(CanvasElement value){
    inst._canvas = value;
    if(inst._currentLevel != null && inst._currentLevel.map != null)
      inst._currentLevel.map.canvas = value;
  }
  static CanvasElement get canvas => inst._canvas;
  
  static void start() {
    if(inst._canvas ==null || inst._currentLevel ==null) 
      throw "Can't start without canvas and level set.";
    
    window.animationFrame.then(_instance.firstFrame);
    //window.animationFrame.then(gameLoop);
  }
  
  
  static void pause(){
    
  }
  static void resume(){
    
  }
  void firstFrame(num time) {
    _lastTime = time;
    inst._currentLevel.startLevel();
    window.animationFrame.then(gameLoop);  
  }
  
  
  void gameLoop(num time){
    num dt = (time - _lastTime)/1000.0;
    _lastTime = time;
    //showFps(1.0/dt);
    
    
    //debug();
    //bounceEdges();
    
    _map.nextFrame(dt);
           
    window.animationFrame.then(gameLoop);
  }
  
  static void onBodyAdded(CollidableBody body){
    GameEvent event = new GameEvent(type:GameEvent.BODY_ADDED, body:body);
    event.location = new Vector2.copy(body.position);
    inst.eventCtrl.add(event);
  }
  static void removeBody(CollidableBody body){
    inst._currentLevel.map.removeSprite(body as MapSprite);
    GameEvent event = new GameEvent(type:GameEvent.BODY_REMOVED, body:body);
    event.location = new Vector2.copy(body.position);
    inst.eventCtrl.add(event);
  }
  
  //void addGameEventListener(String type, 
}