import 'dart:html';
import "package:commando/gamebase2d.dart";
import "package:commando/command0.dart";
import 'package:vector_math/vector_math.dart';

ShootyTest level;
void main() {
  CanvasElement canvas = query("#area");
  level = new ShootyTest();
  GameManager.canvas = canvas;
  GameManager.loadLevel(level);
  window.setImmediate(GameManager.start);
}

void onClick(var e){
  print("click $e");
}

class ShootyTest implements Level{

  GameMap map = new GameMap();
  
  List<Hoverbot> bots = [];
  void start(){
    //make 5 bots
    
    
  }

}

Element notes = query("#fps");
num fpsAverage;
void showFps(num fps) {
  if (fpsAverage == null) fpsAverage = fps;
  fpsAverage = fps * 0.05 + fpsAverage * 0.95;
  notes.text = "${fpsAverage.round()} fps";
}

