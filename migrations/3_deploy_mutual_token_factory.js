var MutualTokenFactory = artifacts.require("./MutualTokenFactory.sol");

module.exports = function(deployer) {
  deployer.deploy(MutualTokenFactory);
};