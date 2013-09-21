part of gamebase2d;

class QuadtreeNode{
static final int MAX_OBJECTS = 6;
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

static int nodecount = 1;
static int comparecount = 0;

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
  //if(debug_peercount >0 || debug_highercount > 0)
  //print("check lev:$level, peer:$debug_peercount, higher:$debug_highercount");
  //check objects in subnodes
  if(nodes != null){
    //add objects in this node to the objects of it's anscestors
    List<CollidableBody> toHere = 
        new List<CollidableBody> (higher.length+objects.length);
    toHere.setRange(0, higher.length, higher);
    toHere.setRange(higher.length,toHere.length,objects);
    for(QuadtreeNode node in nodes)
      node.checkCollisions(toHere);
  }
  num w = right-left;
  num h = bottom-top;
  num ar = 1 - 4*(w/2-40.0)*(h/2-40.0)/(w-40.0)/(h-40.0);
  num nr = objects.length.toDouble()/childCount.toDouble();
  
  comparecount += debug_highercount+debug_peercount;
  //if(!nr.isNaN && nodes != null)
  //print("lev:$level, ar:$ar, nr:$nr");
  //print("lev:$level hi:$debug_highercount =? ${higher.length*objects.length}");
}

String getAddress(CollidableBody obj){
  int index;
  if((index = objects.indexOf(obj))!=-1)
    return "ob"+index.toString();
  if(nodes == null || (index=getIndexOf(obj))==-1) return " not found ";
  return index.toString()+","+nodes[index].getAddress(obj);
}
String getCorrectAddress(CollidableBody obj){
  int index = getIndexOf(obj);
  if(nodes==null || index==-1) return "";
  
  return index.toString()+","+nodes[index].getCorrectAddress(obj);
}
bool isCorrect(CollidableBody obj){
  int index;
  if((index = objects.indexOf(obj))!=-1)
    return true;
  if(nodes == null || (index=getIndexOf(obj))==-1) return false;
  return nodes[index].isCorrect(obj);
}

void notifyOfApproach(CollidableBody body1, CollidableBody body2){
  body1.onApproach(body2);
  body2.onApproach(body1);
}

void split() {
  midX = (right + left) / 2;
  midY = (bottom + top) / 2;
  
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
  sift();
  nodecount += 4;
} //end split()

void sift(){
  int index;
  //push objects into lower nodes, if possible
  for(int i=objects.length-1;i>=0;i--){
    if((index = getIndexOf(objects[i]))!=-1)
      nodes[index].insert(objects.removeAt(i));
  }
}
  
void insert(CollidableBody obj) {
  int index;
  
  childCount++;

  if(nodes != null && (index = getIndexOf(obj))!=-1){
    //[obj] belongs in a subnode
    nodes[index].insert(obj);
    //print("insert lev:$level to i:$index");
    return;
  }
  
  //object added to this node 
  objects.add(obj);
  
  if(objects.length > MAX_OBJECTS && level < MAX_LEVELS && nodes == null){
    //node needs to be split
    split();
    String debug_s = nodes.map((n)=>n.objects.length).join(',');
    String debug_s2 = nodes.map((n)=>n.childCount).join(',');
    print("split lev:$level, n:${objects.length}, sn:$debug_s sncc:$debug_s cc:$childCount");
  }
}

bool remove(CollidableBody obj){
  int index;
  if(nodes == null || (index=getIndexOf(obj)) == -1){
    if(objects.remove(obj)){
      objectRemoved();
      return true;
    }else return false;
    
  }else return nodes[index].remove(obj);
}

void checkObjects(){
  int index;
  //orphan objects that have wandered out of bounds
  if(level!=0)
    for(int i=objects.length-1;i>=0;i--){
      if(objects[i].collisionProfile.top < top || objects[i].collisionProfile.bottom > bottom || 
       objects[i].collisionProfile.left < left || objects[i].collisionProfile.right > right){
        orphanObjects.add(objects.removeAt(i));
        objectRemoved();
      }
    }
  
  if(nodes != null){
    for(QuadtreeNode node in nodes)
      node.checkObjects(); //propagate a lower level
    sift();   //allow objects to fall to lower nodes
  }
}

void update(){
  //only intended to by called at top level
  checkObjects();
  //print("orphans: ${orphanObjects.length} tlos:${objects.length}");
  //reinsert orphans
  for(int i=orphanObjects.length-1;i>=0;i--){
    insert(orphanObjects.removeAt(i));
  }
  //print("after reinsert tlos:${objects.length}");
  cleanUp();
  //print("after cleanup nodes: ${nodecount} tlos:${objects.length}");
}

///unplit nodes if they no longer have enough objects in them
void cleanUp(){
  if(nodes != null){
    if(childCount < MIN_OBJECTS){
      unsplit();
      print("node at level $level was unsplit, count:${objects.length}");
      print("nodecount $nodecount avg:${100/nodecount},");
    }else
      for(QuadtreeNode node in nodes)
        node.cleanUp();
  }
}

///merges all objects from decendents into this one ([this] becomes a leaf)
List<CollidableBody> unsplit(){
  if(nodes != null){
    for(QuadtreeNode node in nodes){
      objects.addAll(node.unsplit());
      node.objects.clear();
    }  
    nodeCache.add(nodes);
    nodes = null;
    nodecount -= 4;
  }//**** there are still objects in it!!
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