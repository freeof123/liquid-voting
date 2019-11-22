pragma solidity >=0.4.21 <0.6.0;
import "./AddressArray.sol";

contract LiquidDemocracy{

  using AddressArray for address[];

  address public owner;

  mapping (address => uint) public vote_weight;
  mapping (address => address) public v_to_parent;
  mapping (address => address[]) public v_to_children;
  uint public voter_count;


  event Delegate(address from, address to, uint height);
  event Undelegate(address from, address to, uint height);
  event SetWeight(address addr, uint weight, uint height);
  event CreateVote(address addr, uint height);

  constructor() public{
    owner = msg.sender;
    voter_count = 0;
  }

  modifier isOwner{
    if(msg.sender == owner) _;
  }

  function setWeight(address addr, uint weight) public isOwner{
    require(weight > 0);
    require(addr != address(0x0));
    vote_weight[addr] = weight;
    voter_count ++;
    emit SetWeight(addr, weight, block.number);
  }

  mapping (address => uint) internal circle_path;

  function check_circle(address _from, address _to) internal returns(bool){
    uint n = block.number;
    circle_path[_from] = n;
    circle_path[_to] = n;

    address next = v_to_parent[_to];
    while(next != address(0x0)){
      if(circle_path[next] == n){
        return true;
      }
      circle_path[next] = n;
      next = v_to_parent[next];
    }
    return false;
  }

  function delegate(address _to) public {
    require(_to != msg.sender, "cannot be self");
    require(vote_weight[msg.sender] != 0, "no sender");
    require(vote_weight[_to] != 0, "no _to");
    //bool has_circle = check_circle(msg.sender, _to);
    //require(!has_circle, "cannot be circle");

    address old = v_to_parent[msg.sender];
    if(old != address(0x0)){
      address[] storage children = v_to_children[old];
      children.remove(msg.sender);
    }
    v_to_parent[msg.sender] = _to;
    v_to_children[_to].push(msg.sender);

    emit Delegate(msg.sender, _to, block.number);
  }

  function undelegate() public pure{
    require(false, "future work");
  }

  function getDelegator(address addr, uint height) public view returns(address ){
    //require(v_to_parent[addr] != address(0x0), "no parent");
    return v_to_parent[addr];
  }

  function getDelegatee(address addr, uint height) public view returns (address [] memory){
    return v_to_children[addr];
  }

  function getWeight(address addr, uint height) public view returns(uint) {
    return vote_weight[addr];
  }
  function getVoterCount(uint height) public view returns(uint){
    return voter_count;
  }
}
