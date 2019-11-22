const AddressArray = artifacts.require("AddressArray");

module.exports = function(deployer) {
  deployer.deploy(AddressArray);
};
