pragma solidity >=0.4.21 <0.6.0;

contract LinkCutTree {
    mapping(address => uint32) public mAddr_number; // node’s address to number
     uint8[]  public vtag;
     uint32[] public vfather;
     // 数组的定义方式看起来是2行n列的形式，但是实际上是N行2列的矩阵，访问时vchild[a][b]表示第a行第b列，这里和c++不同
     uint32[2][] public vchild;
     uint32 public node_count;
    // uint[] weight;


    address public owner;

    modifier onlyOwner{
      require(msg.sender == owner, "only owner can call this");
      _;
    }

    function transferOwnership(address _new) public onlyOwner{
      owner = _new;
    }

    constructor() public {
        node_count = 0;
        vfather.push(0);
        vtag.push(0);
        vchild = new uint32[2][](0);
        vchild.push([uint32(0),0]);
        owner = msg.sender;
    }

    // judge x is a left child or a right child in a splay.
    function getch(uint32 x) internal view returns (uint32) {
        uint32 ans = 0;
        if (vchild[vfather[x]][1] == x) ans += 1;
        return ans;
    }

    // judge wheter x is the root of its splay.
    function isroot(uint32 x) public view returns(bool){
        require(x>0, "node num must greater than 0");
        return vchild[vfather[x]][0] != x && vchild[vfather[x]][1] != x;
    }

    // transmit information from x to its children.
    function pushdown(uint32 x) internal {
        if(vtag[x] == 1){
            if (vchild[x][0] > 0){
                uint32 temp = vchild[vchild[x][0]][0];
                vchild[vchild[x][0]][0] = vchild[vchild[x][0]][1];
                vchild[vchild[x][0]][1] = temp;
                vtag[vchild[x][0]] ^= 1;
            }
            if (vchild[x][1] > 0){
                uint32 temp = vchild[vchild[x][1]][0];
                vchild[vchild[x][1]][0] = vchild[vchild[x][1]][1];
                vchild[vchild[x][1]][1] = temp;
                vtag[vchild[x][1]] ^= 1;
            }
            vtag[x] = 0;
        }
    }

    // update info from its corresponding splay root to x.
    function update(uint32 x) internal {
        if(!isroot(x))
            update(vfather[x]);
        pushdown(x);
    }

    // rotate a node x
    function rotate(uint32 x) internal {
        if(isroot(x)){
            return;
        }
        uint32 y = vfather[x];
        uint32 z = vfather[y];
        uint32 chx = getch(x);
        uint32 chy = getch(y);
        vfather[x] = z;
        if (!isroot(y))
            vchild[z][chy] = x;
        uint32 idx = chx ^ 1;
        vchild[y][chx] = vchild[x][idx];
        vfather[vchild[x][idx]] = y;
        vchild[x][idx] = y;
        vfather[y] = x;
    }

    // rotate x to be the root of its splay
    function splay(uint32 x) public onlyOwner{
        // update information in the path which is from the root to x.
        update(x);
        uint32 f;
        // while 保证x一定可以旋转到根节点位置
        while (!isroot(x))
        {
            f = vfather[x];
            if (!isroot(f)){
                uint32 chx = getch(x);
                uint32 chf = getch(f);
                if(chx == chf){
                    rotate(f);
                }
                else{
                    rotate(x);
                }
            }
            rotate(x);
        }
    }

    // create a path from the root to x.
    function access(uint32 x) public onlyOwner{
        // 将最后一个点的右儿子变为0，即变为虚边
        uint32 son = 0;
        while(x>0){
            // 将x转换为当前树的树根
            splay(x);
            // 将x的右儿子设置为前一棵splay树的树根
            // require(vchild[1].length >x, "HZX--ARRAY LENGTH ERROR--HZX");
            vchild[x][1] = son;
            // son 保存当前splay树树根，x是其父节点
            son = x;
            x = vfather[x];
        }
    }

    // 将原来的树中x节点作为根节点
    function makeRoot(uint32 x) internal
    {
        access(x);
        // splay(x) 之后x在这个树的最右下角
        splay(x);
        // 交换x的左孩子节点和右孩子节点
        uint32 temp = vchild[x][0];
        vchild[x][0] = vchild[x][1];
        vchild[x][1] = temp;
        // 进行懒人标记，不再递归的进行翻转
        vtag[x] ^= 1;
    }

    // 寻找x节点在原树的根节点
    function findRoot(uint32 x) public onlyOwner returns (uint32)
    {
        access(x);
        splay(x);
        // 最左边的一定是根节点
        while (vchild[x][0]>0)
        {
            // 下传懒标记
            pushdown(x);
            x = vchild[x][0];
        }
        // 对根节点进行splay，保证时间复杂度
        splay(x);
        return x;
    }

    // 把x到y的路径拆成一棵方便的Splay树
    function split(uint32 x, uint32 y) internal
    {
        // 如果x和y根本不在同一条路径上，则跳过
        if (findRoot(x) != findRoot(y))
            return;
        makeRoot(x);
        access(y);
        splay(y);
    }

    // check wheter there is a path between _from and to
    function isConnected(address _from, address _to) public onlyOwner returns(bool){
        uint32 num_from = mAddr_number[_from];
        uint32 num_to = mAddr_number[_to];
        require(num_from != 0, "isConnected: _from address invalid");
        require(num_to != 0, "isConnected: _to address invalid");
        bool ans = false;
        if(num_from == num_to || findRoot(num_from) == findRoot(num_to)){
            ans = true;
        }
        return ans;
    }


 // 在x和y之间连接一条边
    function link(address _from, address _to) onlyOwner public returns(bool){
        require(_from!=address(0x0), "link: from node is invalid");
        require(_to!=address(0x0), "link: _to node is invalid");
        require(_from != _to, "link: from and to are a same node");
        // 此时两个点之间应该没有链接

        uint32 num_from = getAddrNum(_from);
        uint32 num_to = getAddrNum(_to);
        makeRoot(num_from);
        bool has_path = isConnected(_from, _to);
        require(!has_path, "link: _from and _to is connected");
        vfather[num_from] = num_to;
        return true;
    }

    // 断开from和to之间的边
    function cut(address _from, address _to) onlyOwner public returns(bool){
        uint32 x = getAddrNum(_from);
        uint32 y = getAddrNum(_to);
        makeRoot(x);
        // 如果y和x不在一棵树上，或者x和y之间不邻接(x的父亲不是y 或者x有左儿子)，不进行cut
        bool noConnected = (findRoot(y) != x || vfather[y] != x || vchild[y][0]>0);
        require(!noConnected, "two nodes no connected");
        vchild[x][1] = 0;
        vfather[y] = 0;
        update(x);
        return true;
    }


        // add a new address
    function getAddrNum(address addr) onlyOwner public returns(uint32){
        // 如果是0地址，返回0
        if(addr == address(0x0))
            return 0;
        // 如果是新地址，生成一个编号
        else if (mAddr_number[addr] == 0) {
            ++node_count;
            mAddr_number[addr] = node_count;
            vfather.push(0);
            vtag.push(0);
            vchild.push([uint32(0),0]);
        }
        return mAddr_number[addr];
    }

    function getVchildLen() public view returns(uint256){
        return vchild.length;
    }

    function getNodeCnt() public view returns(uint32){
        return node_count;
    }

    function getFather(uint32 x) public view returns(uint32){
        return vfather[x];
    }

    function getChild(uint32 pos, uint32 x) public view returns(uint32){
        if(pos == 1){
            return vchild[x][pos];
        }
        else{
            return vchild[x][pos];
        }
    }
}

contract LinkCutTreeFactory{
  event CreateLinkCutTree(address addr);
  function createLinkCutTree()  public returns(address){
    LinkCutTree addr = new LinkCutTree();
    emit CreateLinkCutTree(address(addr));
    addr.transferOwnership(msg.sender);

    return address (addr);
  }
}
