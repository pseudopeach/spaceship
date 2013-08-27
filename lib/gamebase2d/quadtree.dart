part of gamebase2d;

class QuadtreeNode{
static final int MAX_OBJECTS = 5;
static final int MIN_OBJECTS = 4;
static final int MAX_LEVELS = 4;
static List<List<QuadtreeNode>> nodeCache = new List<List<QuadtreeNode>>();
static List<CollidableBody> orphanObjects= new List<CollidableBody>();


num top, left, bottom, right;
int level=0, childCount=0;
num midX, midY;

List<CollidableBody> objects = new List<CollidableBody>();
List<QuadtreeNode> nodes;
QuadtreeNode parent;

QuadtreeNode({this.top:0,this.left:0,this.bottom:0,this.right:0});

void checkCollisions([List<CollidableBody> higher]){
  CollidableBody body1;
  CollidableBody body2;
  
  int debug_peercount=0, debug_highercount=0;
  
  if(higher==null) higher = [];
  for(int i=0;i<objects.length;i++){
    body1 = objects[i];
    if(!body1.isCollidable) continue;
    for(int j=i+1;j<objects.length;j++){
      body2 = objects[j];debug_peercount++;
      //notify all unique pairs of objects in this node
      if(body2.isCollidable) notifyOfApproach(body1,body2);
    }
    //notify pairs: node1 and all higher objects
    for(CollidableBody body2 in higher){
      if(body2.isCollidable) notifyOfApproach(body1,body2); debug_highercount++;}
  }
  if(debug_peercount >0 || debug_highercount > 0)
  //print("check lev:$level, peer:$debug_peercount, higher:$debug_highercount");
  //check objects in subnodes
  if(nodes != null){
    //add objects in this node to the objects of it's anscestors
    higher.addAll(objects);
    for(QuadtreeNode node in nodes)
      node.checkCollisions(higher);
  }
}

String getAddress(CollidableBody obj){
  int index;
  if((index = objects.indexOf(obj))!=-1)
    return "ob"+index.toString();
  index = getIndexOf(obj);
  return index.toString()+","+nodes[index].getAddress(obj);
}

void notifyOfApproach(CollidableBody body1, CollidableBody body2){
  body1.approach(body2);
  body2.approach(body1);
}

void split() {
  midX = (right - left) / 2;
  midY = (bottom - top) / 2;
  
  //check if there's a premade list of 4 nodes ready
  if(nodeCache.length == 0){
    //if not, create some new nodes
    nodes = new List<QuadtreeNode>();
    for(int i=0;i<4;i++)
      nodes.add(new QuadtreeNode());
  }else
    nodes = nodeCache.removeLast();
  
  for(int i=0;i<4;i++){
    if(i<2){
      nodes[i]..top = top
        ..bottom = midY;
    }else{
      nodes[i]..bottom = bottom
        ..top = midY;
    }
    if(i%2==0){
      nodes[i]..left = left
        ..right = midX;
    }else{
      nodes[i]..right = right
        ..left = midX;
    }
    nodes[i]..parent = this
      ..level = level+1
      ..childCount = 0;
  }
  int index;
  for(int i=objects.length-1;i>=0;i--){
    if((index = getIndexOf(objects[i]))!=-1)
      nodes[index].insert(objects.removeAt(i));
  }
} //end split()
  
void insert(CollidableBody obj) {
  int index;
  
  childCount++;

  if(nodes != null && (index = getIndexOf(obj))!=-1 && (
      level!=0 || !(obj.collisionProfile.top<top || obj.collisionProfile.left<left || 
      obj.collisionProfile.bottom > bottom || obj.collisionProfile.right > right))
  ){
    //[obj] belongs in a subnode
    nodes[index].insert(obj);
    return;
  }
  
  //object added to this node 
  objects.add(obj);
  
  if(objects.length > MAX_OBJECTS && level < MAX_LEVELS && nodes == null){
    //node needs to be split
    split();
    String debug_s = nodes.map((n)=>n.objects.length).join(',');
    print("split lev:$level, n:${objects.length}, sn:$debug_s h:${bottom-top}");
  }
}

bool remove(CollidableBody obj){
  int index = getIndexOf(obj);
  if(nodes == null || index == -1){
    if(objects.remove(obj)){
      objectRemoved();
      return true;
    }else return false;
    
  }else return nodes[index].remove(obj);
}

void removeOrphans(){
  for(int i=objects.length-1;i>=0;i--){
    if(objects[i].collisionProfile.top < top || objects[i].collisionProfile.bottom > bottom || 
     objects[i].collisionProfile.left < left || objects[i].collisionProfile.right > right){
      orphanObjects.add(objects.removeAt(i));
      objectRemoved();
    }
  }
  if(nodes != null)
    for(QuadtreeNode node in nodes)
      node.removeOrphans();
}

void update(){
  removeOrphans();
  //insert orphans
  for(int i=orphanObjects.length-1;i>=0;i--){
    insert(orphanObjects.removeAt(i));
  }
  cleanUp();
}

void cleanUp(){
  if(nodes != null){
    if(childCount < MIN_OBJECTS){
      unsplit();print("node at level $level was unsplit, count:${objects.length}");}
    else
      for(QuadtreeNode node in nodes)
        node.cleanUp();
  }
}

///merges all objects from decendents into this one ([this] becomes a leaf)
List<CollidableBody> unsplit(){
  if(nodes != null){
    for(QuadtreeNode node in nodes)
      objects.addAll(node.unsplit());
      
    nodeCache.add(nodes);
    nodes = null;
  }
  return objects;
}

///find which subnode index (0-3) obj belongs in. -1 for none
int getIndexOf(CollidableBody obj){
  int out = 0;
  if(obj.collisionProfile.top > midY){
    //entirely in bottom row
    out = 2;
  } else if(obj.collisionProfile.bottom > midY) return -1;
  
  if(obj.collisionProfile.left > midX){
    //entirely in right column
    out++;
  }else if(obj.collisionProfile.right > midX) return -1;
  
  return out;
}

void objectRemoved(){
  childCount--;
  if(parent != null) parent.objectRemoved();
}



}