pragma solidity >=0.4.21 <0.6.0;
import "./VoteBase.sol";
import "./AddressArray.sol";

contract SimpleVote is VoteBase{

  using AddressArray for address[];

  mapping(address => bytes32) voted_options;

  constructor(address _addr, uint _height) VoteBase(_addr, _height) public { }

  function voteChoice(string memory c) public{
    bytes32 option = normalize(c);
    require(voteResults[option].exist, "no such choice");
    uint power = get_total_power(msg.sender);
    bool voted_before = false;
    if(voted_options[msg.sender] != bytes32(0x0)){
      voted_before = true;
      bytes32 old = voted_options[msg.sender];
      if(old == option){
        return ;
      }else{
        reduceVoteNumberForChoice(old, power);
      }
    }

    addVoteNumberForChoice(option, power);
    voted_options[msg.sender] = option;

    address parent = get_voted_parent(msg.sender);
    if(!voted_before && parent != address(0x0)){
      bytes32 old = voted_options[parent];
      reduceVoteNumberForChoice(old, power);
    }
  }

  function get_total_power(address _addr) internal returns(uint){
    address[] memory to_visit = new address[](getVoterCount());
    uint power = 0;
    uint index = 0;
    to_visit[index] = _addr;
    index ++;
    while(index != 0){
      index --;
      address last = to_visit[index];
      power += getWeight(last);
      address[] memory children = getDelegatee(last);
      for(uint i = 0; i < children.length; i++){
        if(voted_options[children[i]] == bytes32(0x0)){
          to_visit[index] = children[i];
          index ++;
        }
      }
    }
    return power;
  }

  function get_voted_parent(address _addr) internal view returns(address){
    require(_addr != address(0x0));
    address next = getDelegator(_addr);
    while(next != address(0x0)){
      if(voted_options[next] != bytes32(0x0)){
        return next;
      }
      next = getDelegator(next);
    }
    return address(0x0);
  }

}

contract SimpleVoteFactory{
  event CreateSimpleVote(address addr);
  function createSimpleVote(address addr, uint height)  public returns(address){
      SimpleVote sv = new SimpleVote(addr, height);
      emit CreateSimpleVote(address(sv));
      return address (sv);
  }
}
