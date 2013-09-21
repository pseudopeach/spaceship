part of gamebase2d;

class GameManager{
  static GameManager _instance;
  num _lastTime;
  GameMap map;
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
  
  static void loadLevel(Level level){
    level.map.canvas = inst._canvas;
    inst._currentLevel = level;
    inst._currentLevel.initLevel();
    inst.map = level.map;
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
    
    map.nextFrame(dt);
           
    window.animationFrame.then(gameLoop);
  }
  
  static void onBodyAdded(CollidableBody body){
    GameEvent event = new GameEvent(type:GameEvent.BODY_ADDED, body:body);
    event.location = new Vector2.copy(body.position);
    inst.eventCtrl.add(event);
  }
  static void removeBody(CollidableBody body){
    inst.map.removeSprite(body as MapSprite);
    GameEvent event = new GameEvent(type:GameEvent.BODY_REMOVED, body:body);
    event.location = new Vector2.copy(body.position);
    inst.eventCtrl.add(event);
  }
  
  static Stream<GameEvent> watchBody(CollidableBody body, [String type]){
    Stream<GameEvent> out = inst.eventCtrl.stream.where((e)=>e.body == body);
    if(type != null) out = out.where((e)=>e.type == type);
    return out;
  }
  
  static Stream<GameEvent> get mapEvents => inst.eventCtrl.stream;
  
  
  //void addGameEventListener(String type, 
}