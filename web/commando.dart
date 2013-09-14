import 'dart:html';
import "package:commando/gamebase2d.dart";
import "package:commando/command0.dart";
import 'package:vector_math/vector_math.dart';
import 'dart:math';

Level level;
void main() {
  CanvasElement canvas = query("#area");
  level = new ShootyTest();
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
      bot.position = new Vector2(200.0+30.0*i, 500.0);
      bot.mainColor = "red";
      bots.add(bot);
      map.addSprite(bot);
    }
  }
  
  void startLevel(){
      //set event listener
      GameManager.canvas.onClick.listen((e)=>onClick(e));
  }
  Random rand = new Random();
  void onClick(var e){
    print("click $e");
    Disc disc = new Disc();
    double vel = rand.nextDouble()*10;
    double th = rand.nextDouble()*6;
    disc.radius = 30.0;
    disc.color = "blue";
    disc.movement.velocity = new Vector2(vel*cos(th),vel*sin(th));
    targets.add(disc);
    map.addSprite(disc);
    bots.forEach((b)=>b.attack(disc));
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

