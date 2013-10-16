library gamebase2d;
//import 'dart:html';

//import everything in gamebase
import 'dart:html';
import 'dart:async';
import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart';

part 'gamebase2d/base.dart';
part 'gamebase2d/game_map.dart';
part 'gamebase2d/level.dart';
part 'gamebase2d/game_manager.dart';
part 'gamebase2d/quadtree.dart';
part 'gamebase2d/game_event.dart';

part 'gamebase2d/vector_sprite.dart';

part 'gamebase2d/disc.dart';
part 'gamebase2d/projectile.dart';
part 'gamebase2d/dude.dart';
part 'gamebase2d/weapon.dart';
part 'gamebase2d/linear_controller.dart';
part 'gamebase2d/autopilot.dart';

final double TWO_PI = 2*Math.PI;
num thetaDiff(th1, th2){
  num diff = (th1 - th2)%TWO_PI;
  if(diff < -Math.PI) diff += TWO_PI;
  else if(diff > Math.PI) diff -= TWO_PI;
  return diff;
}