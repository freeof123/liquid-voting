const LiquidDemocracy = artifacts.require("LiquidDemocracy")
const LiquidVoteFactory = artifacts.require("LiquidVoteFactory");

async function performMigration(deployer, network, accounts) {
  await deployer.deploy(LiquidVoteFactory);
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
