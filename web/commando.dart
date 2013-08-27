import 'dart:html';
import "package:commando/gamebase2d.dart";

void main() {
  CanvasElement canvas = query("#area");
  window.setImmediate(new BallMap(canvas).start);
}

class BallMap extends GameMap{
  BallMap(CanvasElement canvas): super(canvas);
  
  void start(){
    for(int i=0;i<100;i++){
      Disc d = new Disc();
      d.position.x = 5.0*i;
      d.position.y = 5.0*i;
      d.movement.velocity.x = (i*2305829.0)%50;
      d.movement.velocity.y = 5.0*i;
      d.radius = (5.0*i+10)/(.1*i+5);
      //d.radius = (i*5.0+10.0);
      addSprite(d);
    }
    
    super.start();
  }
  
  void gameLoop(num time){
    bounceEdges();
    super.gameLoop(time);
  }
  
  void bounceEdges(){
    for(MapSprite item in mapItems){
      Disc disc = item as Disc;
      if(disc == null) continue;
      if(disc.position.y < 0 || disc.position.y > height)
        disc.movement.velocity.y *=-1;
      if(disc.position.x < 0 || disc.position.x > width)
        disc.movement.velocity.x *=-1;
    }
  }
}
