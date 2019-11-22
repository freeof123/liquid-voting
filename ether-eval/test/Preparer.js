var VNode = {
  createNew: function(
    address, stake, index, endpoint, leftbracket, rightbracket
  ){
　  var node = {};
    node.address = address;
    node.stake = stake;
    node.index = index;
    node.endpoint = endpoint;
    node.leftbracket = leftbracket;
    node.rightbracket = rightbracket;
    node.power = 0;
  　return node;
　}
}

var VGraph = {
  createNew: function(){
    var graph = {};
    graph.nodes = {};
    graph.v_to_parent = {};
    graph.v_to_children = new Map();

    graph.addNode = function(vnode){
      graph.nodes[vnode.address] = vnode;
      graph.v_to_children[vnode.address] = new Set();
    }

    graph.addEdge = function(addr1, addr2){
      this.v_to_parent[addr1] = addr2;
      this.v_to_children[addr2].add(addr1);
    }

    graph.preorder = function(){
      var n = 0;
      var n0 = 0;
      vs = this._find_roots();
      console.log('roots: ', vs);
      for(i = 0; i < vs.length; ++i){
        obj = this._local_preorder(this.nodes[vs[i]], n, n0);
        n = obj.n;
        n0 = obj.n0;
      }
    }
    graph.get_voter_info = function(addr){
      return this.nodes[addr];
    }

    graph._find_roots = function(){
      var ret = [];

      //console.log('this.nodes ');

      //console.log(this.v_to_parent);
      for(var n in this.nodes){
        //console.log('checking ', n, ' with parent: ', this.v_to_parent[n]);
        if(!(n in this.v_to_parent)){
          ret.push(n);
        }else{
          //console.log('got parent: ', this.v_to_parent[n]);
        }
      }
      return ret;
    }

    graph._local_preorder = function(node, n, n0){
      //console.log("node in _local_preorder ", node);
      n ++;
      n0 ++;
      node.leftbracket = n0;
      node.index = n;
      node.power = node.stake;
      children = this.v_to_children[node.address];
      for(var x of children){
        c = this.nodes[x];
        obj = this._local_preorder(c, n, n0);
        n = obj.n;
        n0 = obj.n0;
        c = this.nodes[x];
        node.power += c.power;
      }
      node.endpoint = n;
      n0 ++;
      node.rightbracket = n0;
      //this.nodes[node.address] = node;
      //console.log(node);
      return {n:n, n0:n0};
    }

    return graph;
  }
}

module.exports= { VNode, VGraph };
