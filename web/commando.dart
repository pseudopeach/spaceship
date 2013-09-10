import 'dart:html';
import "package:commando/gamebase2d.dart";
import "package:commando/command0.dart";
import 'package:vector_math/vector_math.dart';

void main() {
  CanvasElement canvas = query("#area");
  window.setImmediate(Director.start());
  canvas.onClick.listen((e)=>onClick(e) );
}

void onClick(var e){
  print("click $e");
}

//Vector2 targetPoint = new 



Element notes = query("#fps");
num fpsAverage;
void showFps(num fps) {
  if (fpsAverage == null) fpsAverage = fps;
  fpsAverage = fps * 0.05 + fpsAverage * 0.95;
  notes.text = "${fpsAverage.round()} fps";
}

