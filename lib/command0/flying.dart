part of command0;

class Flying extends InertialBody{
  bool isGrounded = false;
  
  void update(num dt){
    if(isGrounded){
      velocity.scale(-velocity.length*500*dt);
    }
    super.update(dt);
  }
}