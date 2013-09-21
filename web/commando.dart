import 'dart:html';
import "package:commando/gamebase2d.dart";
import "package:commando/command0.dart";
import 'package:vector_math/vector_math.dart';
import 'dart:math';

Level level;
void main() {
  CanvasElement canvas = query("#area");
  ShootyTest level = new ShootyTest();
  GameManager.canvas = canvas;
  GameManager.loadLevel(level);
  window.setImmediate(GameManager.start);
}


class ShootyTest implements Level{
  GameMap map = new GameMap();
  
  void initLevel(){
    //create 5 bots
    for(int i=0;i<5;i++){
      Hoverbot bot = new Hoverbot();
      bot.position.setValues(200.0+30.0*i, 500.0);
      bot.mainColor = "red";
      bots.add(bot);
      map.addSprite(bot);
      GameManager.mapEvents.where((e)=>e.type == GameEvent.BODY_ADDED).
        listen((e)=>bot.attack(e.body));
      bot.watchFor(GameEvent.BODY_IDLE).listen((e)=>onBotIdle(e));
    }
  }
  
  void onBotIdle(GameEvent e){
    if(targets.length > 0){
      Hoverbot bot = e.body as Hoverbot;
      bot.attack(targets.first);
    }
  }
  
  void startLevel(){
      //set event listener
      GameManager.canvas.onClick.listen((e)=>onClick(e));
      GameManager.mapEvents.listen((e)=>targets.remove(e.body) );
  }
  
  Random rand = new Random();
  void onClick(MouseEvent e){
    print("click $e");
    Disc disc = new Disc();
    disc.position.setValues(e.offset.x.toDouble(), e.offset.y.toDouble());
    double vel = rand.nextDouble()*50;
    double th = rand.nextDouble()*6;
    disc.radius = 30.0;
    disc.color = "blue";
    disc.isBouncy = true;
    disc.velocity.setValues(vel*cos(th),vel*sin(th));
    targets.add(disc);
    map.addSprite(disc);
  }
  
  bool checkForEndCondition(){
    return false;
  }
  
  List<Hoverbot> bots = [];
  List<MapSprite> targets = [];
  

}

Element notes = query("#fps");
num fpsAverage;
void showFps(num fps) {
  if (fpsAverage == null) fpsAverage = fps;
  fpsAverage = fps * 0.05 + fpsAverage * 0.95;
  notes.text = "${fpsAverage.round()} fps";
}

