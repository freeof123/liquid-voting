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

var MerkleTools = {
  createNew :function(){
    var MerkleTools = require('./merkle-tools/merkletools.js');
    var treeOptions = { hashType: 'KECCAK-256' };
		var merkleTools = new MerkleTools(treeOptions);
		var merkle_tools = {};

    merkle_tools.add_leaf = function(node){
      keccak256_enpacked = web3.utils.soliditySha3(node.address, node.stake,
          node.index, node.endpoint, node.leftbracket, node.rightbracket, node.power);
      merkleTools.addLeaf(keccak26_enpacked, false);
    }
    merkle_tools.make_tree = function(){
      merkleTools.makeTree(false);
    }
    merkle_tools.get_root = function(){
      return merkleTools.getMerkleRoot();
    }
    merkle_tools.get_proof = function(index){
      proof = merkleTools.getProof(index);
      return proof.map(item => Object.values(item)[0]);
    }

		return merkle_tools
  }
}

var VGraph = {
  createNew: function(){
    var graph = {};
    graph.nodes = {};
    graph.v_to_parent = {};
    graph.v_to_children = new Map();
    graph.merkle = MerkleTools.createNew()
    graph.merkle_root = {}

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

      node_obj = [];
      for (var n in this.nodes){
        node_obj.push(this.nodes[n])
      }
      node_obj.sort(function(n1, n2){
        return n1.index < n2.index;
      });
      for (i = 0; i < node_obj.length; i++){
        this.merkle.add_leaf(node_obj[i]);
      }
      this.merkle.make_tree();
      this.merkle_root = this.merkle.get_root();
    }

    graph.get_voter_info = function(addr){
      var ret = this.nodes[addr];
      ret.proof = this.merkle.get_proof(this.nodes[addr].index);
      return ret;
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


module.exports= { VNode, VGraph, Merkle_Tools};
