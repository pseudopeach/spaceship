import 'dart:html';
import "package:commando/gamebase2d.dart";
import "package:commando/command0.dart";
import 'package:vector_math/vector_math.dart';

void main() {
  CanvasElement canvas = query("#area");
  window.setImmediate(new BotMap(canvas).start);
}

class BotMap extends GameMap{
BotMap(CanvasElement canvas): super(canvas);
  Hoverbot bot;
  void start(){
    bot = new Hoverbot();
    //bot.omega = .5;
    bot.controller.targetTheta = 2;
    bot.controller.natFreq = 1;
    bot.position.x = 100.0;
    bot.position.y= 100.0;
    bot.theta = 3.0;
    
    bot.controller.targetPosition = new Vector2(1000.0,300.0);
    addSprite(bot);
    
    super.start();
  }
num max = 0;
  void gameLoop(num time){
    if(bot.position.x>max) max = bot.position.x;
    //print("max $max");
    super.gameLoop(time);
    
  }
}

class BallMap extends GameMap{
  BallMap(CanvasElement canvas): super(canvas);
  
  void start(){
    for(int i=0;i<100;i++){
      Disc d = new Disc();
      d.position.x = 5.0*i;
      d.position.y = 5.0*i;
      d.movement.velocity.x = .2*(i*2305829.0)%50;
      d.movement.velocity.y = 1.0*i;
      d.radius = 30.0;//(5.0*i+10)/(.1*i+5);
      
      //d.radius = 30.0*i + 30.0;
      addSprite(d);
    }
    super.start();
  }
 
  
  void debug(){
    for(CollidableBody b1 in mapItems){
      if(!collisionManager.isCorrect(b1)){
        print("should be at ${collisionManager.getCorrectAddress(b1)}");
     
        String loob = collisionManager.getCorrectAddress(b1);
      }
      /*for(CollidableBody b2 in mapItems){
        if(b1==b2) continue;
        Disc d1 = b1;
        Disc d2 = b2;
        if(d1==null || d2==null)
          print("why is there null shit???");
        if((!d1.isColliding || !d2.isColliding) && ((d1.position-d2.position).length < (d1.radius+d2.radius))){
          String s1 = collisionManager.getAddress(d1);
          String s2 = collisionManager.getAddress(d2);
          num l = (d1.position-d2.position).length;
          print("*** problem $s1 and $s2");
        }
      }*/
    }
  }
  num lastTime2 = 0.0;
  void gameLoop(num time){
    bounceEdges();
    showFps(1000.0/(time-lastTime2));
    lastTime2 = time;
    QuadtreeNode.comparecount = 0;
    super.gameLoop(time);
    //print("compareCount ${QuadtreeNode.comparecount}");
  }
  
  void bounceEdges(){
    for(MapSprite item in mapItems){
      Disc disc = item as Disc;
      if(disc == null) continue;
      if(disc.collisionProfile.top < 0 || disc.collisionProfile.bottom > height)
        disc.movement.velocity.y *=-1;
      if(disc.collisionProfile.left < 0 || disc.collisionProfile.right > width)
        disc.movement.velocity.x *=-1;
    }
  }
  Element notes = query("#fps");
  num fpsAverage;
  void showFps(num fps) {
    if (fpsAverage == null) fpsAverage = fps;
    fpsAverage = fps * 0.05 + fpsAverage * 0.95;
    notes.text = "${fpsAverage.round()} fps";
  }
}
