pragma solidity >=0.4.21 <0.6.0;
import "./VoteBase.sol";

contract LiquidVote is VoteBase{
  struct Node {
    address voter;
    // address_t address;
    uint stake;
    uint64 index;     // preorder index
    uint64 endpoint;  // maximum preorder index among the node’s children
                        // (include multi-level).
    uint64 leftbracket; // The first index where the node appears in the bracket
                        // sequence.
    uint64 rightbracket; // The second index where the node appears in the
                         // bracket sequence.
    uint power; // Node’s total voting power (including its children’s).

    bytes32 candidate; // used for onchain.
    bool exists;           // used for onchain.
  }

  mapping(address => bytes32) voted_options;
  mapping(uint64 => Node) internal m_b; // Mapping from a node’s preorder index to the node.
  mapping (uint64 => uint64) internal m_nearest_parent; // Mapping from a node’s preorder index to its nearest
                        // voted parent’s preorder index.
  mapping (uint64 => uint64) internal m_lazy1;
  mapping (uint64 => uint) internal m_lazy2;
  mapping (uint64 => uint) internal m_score;

  bytes32 merkelRoot;

  constructor(address _addr, uint _height, bytes32 _merkelRoot) VoteBase(_addr, _height)
  public {
    merkelRoot = _merkelRoot;
  }

  function verify(bytes32[] memory proof, bytes32 root, uint index, bytes32 leaf) internal pure returns (bool) {
    bytes32 computedHash = leaf;

    uint256 path = index;
    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if(path & 0x01 == 1){
          computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }else{
          computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      }
      path /=2;
    }

    return computedHash == root;
  }
  function voteChoice(string memory c, uint stake, uint64 index,
                      uint64 endpoint, uint64 leftbracket, uint64 rightbracket,
                      uint power, uint proof_index, bytes32[] memory proof) public{
    bytes32 hash = keccak256(abi.encodePacked(msg.sender, stake, index, endpoint, leftbracket, rightbracket, power));
    bool checked = verify(proof, merkelRoot, proof_index, hash);
    require(checked, "invalid input data");
    _voteChoice(c, stake, index, endpoint, leftbracket, rightbracket, power);
  }

  function _voteChoice(string memory c, uint stake, uint64 index, uint64 endpoint,
                       uint64 leftbracket, uint64 rightbracket, uint power) internal {
    Node storage node = m_b[index];
    node.exists = true;
    node.voter = msg.sender;
    node.stake = stake;
    node.index = index;
    node.endpoint = endpoint;
    node.leftbracket = leftbracket;
    node.rightbracket = rightbracket;
    node.power = power;
    node.candidate = normalize(c);

    uint64 n = uint64(getVoterCount());
    _update2(node.leftbracket, node.leftbracket, 1, 2 * n, 1, 0);
    _update2(node.rightbracket, node.rightbracket, 1, 2 * n, 1, 0);
    uint t =
      node.power - m_score[node.leftbracket] + m_score[node.rightbracket];

    addVoteNumberForChoice(node.candidate, t);
    if(voted_options[node.voter] != bytes32(0x0)){
      bytes32 old = voted_options[node.voter];
      reduceVoteNumberForChoice(old, t);
      voted_options[node.voter] = node.candidate;
      return ;
    }

    _update1(node.index, node.index, 1, n, 1, 0);
    Node storage parent = m_b[m_nearest_parent[node.index]];
    if(parent.exists) {
      reduceVoteNumberForChoice(parent.candidate, t);
      _update1(node.index + 1, node.endpoint, 1, n, 1, node.index);
      _update2(parent.leftbracket, node.leftbracket - 1, 1, 2 * n, 1, t);
    } else {
      _update1(node.index + 1, node.endpoint, 1, n, 1, node.index);
      _update2(1, node.leftbracket - 1, 1, 2 * n, 1, t);
    }
    voted_options[node.voter] = node.candidate;
  }
  function max(uint64 a, uint64 b) private pure returns (uint64) {
        return a > b ? a : b;
  }
  function min(uint64 a, uint64 b) private pure returns (uint64) {
        return a > b ? b : a;
  }

  function _update1(uint64 L, uint64 R, uint64 l, uint64 r, uint64 k, uint64 v) internal {
    if (L == l && R == r) {
      if (v > m_lazy1[k]) {
        m_lazy1[k] = v;
      }
      if (L == R) {
        m_nearest_parent[L] = m_lazy1[k];
      }
    } else {
      uint64 m = (l + r) / 2;
      if (m_lazy1[2 * k] < m_lazy1[k]) {
        m_lazy1[2 * k] = m_lazy1[k];
      }
      if (m_lazy1[2 * k + 1] < m_lazy1[k]) {
        m_lazy1[2 * k + 1] = m_lazy1[k];
      }
      if (L <= m) {
        _update1(L, min(m, R), l, m, 2 * k, v);
      }
      if (R > m) {
        _update1(max(m + 1, L), R, m + 1, r, 2 * k + 1, v);
      }
    }
  }

  function _update2(uint64 L, uint64 R, uint64 l, uint64 r, uint64 k, uint v) internal{
    if(L > R){
      return ;
    }
    if (L == l && R == r) {
      m_lazy2[k] = m_lazy2[k] + v;
      if (L == R) {
        m_score[L] = m_lazy2[k];
      }
    } else {
      uint64 m = (l + r) / 2;
      m_lazy2[2 * k] = m_lazy2[2 * k] + m_lazy2[k];
      m_lazy2[2 * k + 1] = m_lazy2[2 * k + 1] + m_lazy2[k];
      m_lazy2[k] = 0;
      if (L <= m) {
        _update2(L, min(m, R), l, m, 2 * k, v);
      }
      if (R > m) {
        _update2(max(m + 1, L), R, m + 1, r, 2 * k + 1, v);
      }
    }
  }

}

contract LiquidVoteFactory{
  event CreateLiquidVote(address addr);
  function createLiquidVote(address addr, uint height, bytes32 merkelRoot)  public returns(address){
      LiquidVote lv = new LiquidVote(addr, height, merkelRoot);
      emit CreateLiquidVote(address(lv));
      return address (lv);
  }
}
