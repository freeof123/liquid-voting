const LiquidDemocracy = artifacts.require("LiquidDemocracy")
const AddressArray = artifacts.require("AddressArray");
const SimpleVoteFactory = artifacts.require("SimpleVoteFactory");

async function performMigration(deployer, network, accounts) {
  await AddressArray.deployed();
  await deployer.link(AddressArray, SimpleVoteFactory);
  await deployer.deploy(SimpleVoteFactory);
}
module.exports = function(deployer, network, accounts){
deployer
    .then(function() {
      return performMigration(deployer, network, accounts)
    })
    .catch(error => {
      console.log(error)
      process.exit(1)
    })
};
