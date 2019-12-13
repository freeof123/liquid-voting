pragma solidity >=0.4.21 <0.6.0;
import "./LiquidDemocracyTools.sol";

contract VoteBase is LiquidDemocracyTools{
  address democracy;
  uint height;
  address owner;

  struct vote_result_t{
    uint total;
    bool exist;
  }

  mapping (bytes32 => vote_result_t) public voteResults;
  bytes32[] public allChoice;

  constructor(address _addr, uint _height) LiquidDemocracyTools(_addr, _height) public{
    democracy = _addr;
    height = _height;
    owner = msg.sender;
  }

  modifier isOwner{
    if(msg.sender == owner) _;
  }

  function addChoice(string memory c) public {
    bytes32 hash = keccak256(abi.encodePacked(c));
    voteResults[hash].total = 0;
    voteResults[hash].exist = true;
    allChoice.push(hash);
  }

  function getChoiceNumber() public view returns(uint){
    return allChoice.length;
  }

  function getChoiceVoteNumber(string memory c) public view returns(uint){
    bytes32 hash = normalize(c);
    require(voteResults[hash].exist, "choice not exist");
    return voteResults[hash].total;
  }
  function isChoiceExist(string memory c) public view returns(bool){
    bytes32 hash = normalize(c);
    return voteResults[hash].exist;
  }

  function addVoteNumberForChoice(bytes32 hash, uint n) internal{
    require(voteResults[hash].exist, "addVoteNumberForChoice, choice not exist");
    voteResults[hash].total += n;
  }

  function reduceVoteNumberForChoice(bytes32 hash, uint n) internal{
    require(voteResults[hash].exist, "reduceVoteNumberForChoice, choice not exist");
    voteResults[hash].total -= n;
  }

  function normalize(string memory c) internal pure returns(bytes32){
    return keccak256(abi.encodePacked(c));
  }
}
