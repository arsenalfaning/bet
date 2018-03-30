var BetContract = artifacts.require("BetContract");
module.exports = function(deployer) {
  deployer.deploy(BetContract);
};