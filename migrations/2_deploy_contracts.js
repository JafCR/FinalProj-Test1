var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var ClassContract = artifacts.require("./ClassContract.sol");

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(ClassContract);
};
