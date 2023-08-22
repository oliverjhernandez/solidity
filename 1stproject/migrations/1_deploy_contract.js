const Inbox_Contract = artifacts.require("Inbox");

module.exports = function(deployer) {
  deployer.deploy(Inbox_Contract, "Hello world!");
};
