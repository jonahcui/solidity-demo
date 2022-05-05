var MutualTokenFactory = artifacts.require("./MutualTokenFactory.sol");

module.exports = function(deployer) {
  deployer.deploy(MutualTokenFactory, {
      from: '0x10B47Cc59e9697CC3E1e151e1F6cBEeb3187Bc53'
  });
};