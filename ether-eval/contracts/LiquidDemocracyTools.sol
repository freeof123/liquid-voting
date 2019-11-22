pragma solidity >=0.4.21 <0.6.0;

contract LiquidDemocracyInterface{
  function getVoterCount(uint height) public view returns(uint);
  function getWeight(address addr, uint height) public view returns(uint) ;
  function getDelegatee(address addr, uint height) public view returns (address [] memory);
  function getDelegator(address addr, uint height) public view returns(address );
}

contract LiquidDemocracyTools{

  LiquidDemocracyInterface public _democracy;
  uint public _height;

  constructor(address addr, uint height) public{
    _democracy = LiquidDemocracyInterface(addr);
    _height = height;
  }
  function getVoterCount() public view returns(uint){
    return _democracy.getVoterCount(_height);
  }
  function getWeight(address addr) public view returns(uint) {
    return _democracy.getWeight(addr, _height);
  }
  function getDelegatee(address addr) public view returns (address [] memory){
    return _democracy.getDelegatee(addr, _height);
  }
  function getDelegator(address addr) public view returns(address ){
    return _democracy.getDelegator(addr, _height);
  }
}
